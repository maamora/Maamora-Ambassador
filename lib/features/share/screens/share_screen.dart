import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../profile/providers/profile_provider.dart';
import '../services/native_share_service.dart';
import '../widgets/edit_message_bottom_sheet.dart';
import '../../../shared/widgets/design_kit.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

// ── Design tokens: mapped to the central charte (zero hardcoded hex) ────────
const Color _primary = MaamoraColors.primary;
const Color _background = MaamoraColors.scaffold;
const Color _surface = MaamoraColors.surface;
const Color _onBackground = MaamoraColors.textPrimary;
const Color _onSurfaceVariant = MaamoraColors.textSecondary;
const Color _cardBorder = MaamoraColors.border;
// Derived from the charte: WhatsApp green + bubble are semantic third-party
// brand colors, kept as derivatives of the success container family.
const Color _whatsappBubble = MaamoraColors.successSoft;

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  late final TextEditingController _linkController;
  String? _customMessage;
  String _activeLink = '';
  String _defaultLink = '';
  String _currentAmbassadorId = '';
  String _currentCity = '';
  bool _hasLoadedSavedData = false;

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  String _getDefaultMessage(String city, String fullLink) {
    return context.tr('share_default_msg',
        args: {'city': city, 'link': fullLink});
  }

  Future<void> _loadSavedData({
    required String ambassadorId,
    required String defaultFullLink,
    required String city,
  }) async {
    if (_hasLoadedSavedData && _currentAmbassadorId == ambassadorId) return;
    _hasLoadedSavedData = true;
    _currentAmbassadorId = ambassadorId;
    _currentCity = city;
    _defaultLink = defaultFullLink;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLink = prefs.getString('custom_share_link_$ambassadorId');
      final savedMsg = prefs.getString('custom_share_message_$ambassadorId');

      final effectiveLink = (savedLink != null && savedLink.trim().isNotEmpty)
          ? savedLink.trim()
          : defaultFullLink;

      final effectiveMsg = (savedMsg != null && savedMsg.trim().isNotEmpty)
          ? savedMsg
          : _getDefaultMessage(city, effectiveLink);

      if (mounted) {
        setState(() {
          _activeLink = effectiveLink;
          _linkController.text = effectiveLink;
          _customMessage = effectiveMsg;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _activeLink = defaultFullLink;
          _linkController.text = defaultFullLink;
          _customMessage = _getDefaultMessage(city, defaultFullLink);
        });
      }
    }
  }

  String _updateMessageWithLink(String message, String oldLink, String newLink) {
    final trimmedNew = newLink.trim();
    if (message.isEmpty) return trimmedNew;

    // 1. If oldLink was non-empty, try to replace it precisely
    if (oldLink.isNotEmpty) {
      final trimmedOld = oldLink.trim();
      final trimmedMsg = message.trimRight();

      // Check if message ends with oldLink
      if (trimmedOld.isNotEmpty && trimmedMsg.endsWith(trimmedOld)) {
        final prefix = trimmedMsg.substring(0, trimmedMsg.length - trimmedOld.length);
        return '$prefix$trimmedNew';
      }

      // Check if oldLink appears as an isolated token separated by whitespace / newlines / punctuation
      if (trimmedOld.isNotEmpty) {
        final isolatedPattern = RegExp(
          r'(^|[\s\n:])' + RegExp.escape(trimmedOld) + r'($|[\s\n.,!?])',
        );
        if (isolatedPattern.hasMatch(message)) {
          return message.replaceFirstMapped(isolatedPattern, (match) {
            final prefix = match.group(1) ?? '';
            final suffix = match.group(2) ?? '';
            return '$prefix$trimmedNew$suffix';
          });
        }
      }
    }

    // 2. Check for standard URL / maamora pattern in message
    final urlRegex = RegExp(r'(https?://[^\s]+|maamora\.ma/[^\s]+)');
    final matches = urlRegex.allMatches(message);
    if (matches.isNotEmpty) {
      final lastMatch = matches.last;
      return message.substring(0, lastMatch.start) + trimmedNew + message.substring(lastMatch.end);
    }

    // 3. Fallback: append at the end
    return '${message.trimRight()}\n\n$trimmedNew';
  }

  void _onLinkChanged(String newLink) {
    final trimmedLink = newLink.trim();
    final oldLink = _activeLink;
    final baseMsg = _customMessage ?? _getDefaultMessage(_currentCity, oldLink.isNotEmpty ? oldLink : _defaultLink);
    final updatedMsg = _updateMessageWithLink(baseMsg, oldLink, trimmedLink);

    setState(() {
      _activeLink = trimmedLink;
      _customMessage = updatedMsg;
    });

    _persistData(_currentAmbassadorId, trimmedLink, updatedMsg);
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text != null && text.isNotEmpty) {
        _linkController.text = text;
        _onLinkChanged(text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.content_paste_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(context.tr('share_pasted_synced')),
                ],
              ),
              backgroundColor: MaamoraColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('share_clipboard_empty')),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _resetLinkToDefault() {
    _linkController.text = _defaultLink;
    final defaultMsg = _getDefaultMessage(_currentCity, _defaultLink);
    setState(() {
      _activeLink = _defaultLink;
      _customMessage = defaultMsg;
    });
    _persistData(_currentAmbassadorId, _defaultLink, defaultMsg);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('share_reset_done')),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _persistData(String ambassadorId, String link, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_share_link_$ambassadorId', link);
      await prefs.setString('custom_share_message_$ambassadorId', message);
    } catch (_) {}
  }

  Future<void> _saveCustomMessage(String newMessage) async {
    setState(() {
      _customMessage = newMessage;
    });
    _persistData(_currentAmbassadorId, _activeLink, newMessage);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(context.tr('share_msg_updated')),
            ],
          ),
          backgroundColor: MaamoraColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openEditSheet({
    required BuildContext context,
    required String currentMessage,
    required String defaultMessage,
    required String activeLink,
    required String city,
  }) {
    EditMessageBottomSheet.show(
      context: context,
      currentMessage: currentMessage,
      defaultMessage: defaultMessage,
      referralLink: activeLink,
      city: city,
      onSaved: _saveCustomMessage,
    );
  }

  String _getQrCodeData(String link, String defaultSlug) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) {
      return 'https://maamora.ma/join/$defaultSlug';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.contains('.')) {
      return 'https://$trimmed';
    }
    return 'https://maamora.ma/join/$trimmed';
  }

  String _getDisplaySlug(String link, String defaultSlug) {
    final trimmed = link.trim();
    if (trimmed.isEmpty) return defaultSlug;
    try {
      final uriStr = trimmed.startsWith('http') ? trimmed : 'https://$trimmed';
      final uri = Uri.parse(uriStr);
      if (uri.pathSegments.isNotEmpty) {
        final lastSeg = uri.pathSegments.last;
        if (lastSeg.isNotEmpty) return lastSeg;
      }
    } catch (_) {}
    return trimmed;
  }

  void _showQrDialog(BuildContext context, String currentLink, String defaultSlug) {
    final qrData = _getQrCodeData(currentLink, defaultSlug);
    final displaySlug = _getDisplaySlug(currentLink, defaultSlug);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      context.tr('share_qr_title'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _onBackground,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: MaamoraColors.surfaceLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: _onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('share_qr_sub'),
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: _onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: _onBackground,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: _onBackground,
                      ),
                      errorStateBuilder: (cxt, err) {
                        return Center(
                          child: Text(
                            context.tr('share_qr_error'),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.red),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        displaySlug,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final linkToCopy = currentLink.trim().isNotEmpty ? currentLink.trim() : qrData;
                    Clipboard.setData(ClipboardData(text: linkToCopy));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('share_copied_clipboard')),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.content_copy_outlined, size: 18),
                  label: Text(context.tr('share_copy_link')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: _background,
      body: profileAsync.when(
        loading: () => const AppLoader(),
        error: (err, _) => Center(child: Text(context.tr('common_error', args: {'e': err.toString()}))),
        data: (ambassador) {
          if (ambassador == null) return Center(child: Text(context.tr('common_not_logged_in')));

          final defaultFullLink = 'maamora.ma/join/${ambassador.referralSlug}';

          // Load persisted custom data once
          _loadSavedData(
            ambassadorId: ambassador.id,
            defaultFullLink: defaultFullLink,
            city: ambassador.city,
          );

          final effectiveLink = _activeLink.isNotEmpty ? _activeLink : defaultFullLink;
          final defaultMessage = _getDefaultMessage(ambassador.city, effectiveLink);
          final activeMessage = _customMessage ?? defaultMessage;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    context.tr('share_title'),
                    style: MaamoraTheme.screenTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('share_subtitle'),
                    style: MaamoraTheme.support(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // ⭐ Premium share card — flip 3D au tap pour révéler le code.
                  _FlipShareCard(
                    displayName:
                        (ambassador.fullName.split(' ').first),
                    referralSlug: ambassador.referralSlug,
                    link: effectiveLink,
                  ),
                  const SizedBox(height: 20),

                  // Editable & Pasteable Referral Link Box
                  _ReferralLinkBox(
                    controller: _linkController,
                    currentLink: effectiveLink,
                    defaultLink: defaultFullLink,
                    onChanged: _onLinkChanged,
                    onPaste: _pasteFromClipboard,
                    onReset: _resetLinkToDefault,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: effectiveLink));
                      MaamoraToast.success(
                        context,
                        context.tr('share_link_copied'),
                        subtitle: context.tr('share_ready_whatsapp'),
                      );
                    },
                    onQrTap: () => _showQrDialog(context, effectiveLink, ambassador.referralSlug),
                  ),
                  const SizedBox(height: 24),

                  // Message Preview Section with Edit Button
                  _MessagePreviewSection(
                    message: activeMessage,
                    link: effectiveLink,
                    onEditTap: () => _openEditSheet(
                      context: context,
                      currentMessage: activeMessage,
                      defaultMessage: defaultMessage,
                      activeLink: effectiveLink,
                      city: ambassador.city,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // WhatsApp Send Button
                  _WhatsAppButton(message: activeMessage),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Flip Share Card ⭐ — face ou code+QR, flip 3D au tap ─────────────────────

class _FlipShareCard extends StatefulWidget {
  const _FlipShareCard({
    required this.displayName,
    required this.referralSlug,
    required this.link,
  });

  final String displayName;
  final String referralSlug;
  final String link;

  @override
  State<_FlipShareCard> createState() => _FlipShareCardState();
}

class _FlipShareCardState extends State<_FlipShareCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool _showBack = false;

  void _flip() {
    HapticFeedback.lightImpact();
    if (_showBack) {
      _c.reverse();
    } else {
      _c.forward();
    }
    _showBack = !_showBack;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final angle = _c.value * pi;
          final front = _FrontShareCard(
            displayName: widget.displayName,
            referralSlug: widget.referralSlug,
          );
          final back = _BackShareCard(
            referralSlug: widget.referralSlug.toUpperCase(),
            link: widget.link,
            onCopy: () {
              Clipboard.setData(ClipboardData(text: widget.link));
              MaamoraToast.success(context, context.tr('share_code_copied'));
              _flip();
            },
          );
          // 3D flip with perspective; front shows while angle < 90°.
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: angle < pi / 2
                ? _RoundWrap(child: front)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _RoundWrap(child: back),
                  ),
          );
        },
      ),
    );
  }
}

class _RoundWrap extends StatelessWidget {
  const _RoundWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MaamoraRadius.card),
        boxShadow: MaamoraShadows.raised,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MaamoraRadius.card),
        child: child,
      ),
    );
  }
}

class _FrontShareCard extends StatelessWidget {
  const _FrontShareCard({
    required this.displayName,
    required this.referralSlug,
  });

  final String displayName;
  final String referralSlug;

  @override
  Widget build(BuildContext context) {
    final code =
        referralSlug.length > 6 ? referralSlug.toUpperCase() : referralSlug;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MaamoraGradients.heroNavyFrom, MaamoraColors.textPrimary],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: MaamoraParticles(count: 10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: MaamoraColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: MaamoraShadows.glow(MaamoraColors.primary),
                    ),
                    child: const Icon(
                      MaamoraIcons.crown,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$displayName · Maamora Ambassador',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          context.tr('share_card_tag'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'MAAMORA.MA/J',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                        color: MaamoraColors.tierGold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  MaamoraIcons.qrCode,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackShareCard extends StatelessWidget {
  const _BackShareCard({
    required this.referralSlug,
    required this.link,
    required this.onCopy,
  });

  final String referralSlug;
  final String link;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MaamoraGradients.heroOrangeTo, MaamoraColors.primary],
        ),
      ),
      child: Column(
        children: [
          Text(
            context.tr('share_my_code'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: MaamoraShadows.soft,
            ),
            child: Text(
              referralSlug,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: MaamoraColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          MaamoraButton(
            label: context.tr('share_copy_link'),
            leadingIcon: MaamoraIcons.copy,
            onPressed: onCopy,
            height: 44,
          ),
        ],
      ),
    );
  }
}

// ── Referral Link Box (Editable & Pasteable) ──────────────────────────────────

class _ReferralLinkBox extends StatelessWidget {
  final TextEditingController controller;
  final String currentLink;
  final String defaultLink;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;
  final VoidCallback onReset;
  final VoidCallback onCopy;
  final VoidCallback onQrTap;

  const _ReferralLinkBox({
    required this.controller,
    required this.currentLink,
    required this.defaultLink,
    required this.onChanged,
    required this.onPaste,
    required this.onReset,
    required this.onCopy,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomized = currentLink != defaultLink && currentLink.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _primary,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          // Editable Link Field
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onBackground,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: context.tr('share_paste_hint'),
                hintStyle: TextStyle(
                  color: _onSurfaceVariant,
                  fontSize: 13,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reset button (visible when customized)
          if (isCustomized) ...[
            GestureDetector(
              onTap: onReset,
              child: Tooltip(
                message: context.tr('share_reset'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: MaamoraColors.surfaceLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.restart_alt_rounded, color: _onSurfaceVariant, size: 18),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Paste icon button
          GestureDetector(
            onTap: onPaste,
            child: Tooltip(
              message: context.tr('share_paste_clipboard'),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MaamoraColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.content_paste_rounded, color: _primary, size: 19),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Copy icon
          GestureDetector(
            onTap: onCopy,
            child: Tooltip(
              message: context.tr('share_copy_link'),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MaamoraColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.content_copy_outlined, color: _primary, size: 19),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // QR icon
          GestureDetector(
            onTap: onQrTap,
            child: Tooltip(
              message: context.tr('share_show_qr'),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MaamoraColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code_rounded, color: _primary, size: 19),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Preview Section ──────────────────────────────────────────────────

class _MessagePreviewSection extends StatelessWidget {
  final String message;
  final String link;
  final VoidCallback onEditTap;

  const _MessagePreviewSection({
    required this.message,
    required this.link,
    required this.onEditTap,
  });

  List<InlineSpan> _buildMessageSpans(String text, String activeLink) {
    final spans = <InlineSpan>[];
    if (text.isEmpty) return spans;

    final trimmed = activeLink.trim();
    final patterns = <String>[
      r'https?://[^\s]+',
      r'maamora\.ma/[^\s]+',
    ];

    if (trimmed.isNotEmpty) {
      patterns.insert(
        0,
        r'(?:(?<=[\s\n:]|^)' + RegExp.escape(trimmed) + r'(?=[\s\n.,!?]|$))',
      );
    }

    final regex = RegExp(patterns.join('|'), multiLine: true);
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _onBackground,
            height: 1.5,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _primary,
          decoration: TextDecoration.underline,
          decorationColor: _primary,
          height: 1.5,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _onBackground,
          height: 1.5,
        ),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Title and "Modifier" action button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('share_msg_preview'),
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _onSurfaceVariant,
              ),
            ),
            InkWell(
              onTap: onEditTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_outlined, size: 14, color: _primary),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('share_edit'),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // WhatsApp Chat Bubble (Tappable to Edit)
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: GestureDetector(
            onTap: onEditTap,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 8),
              decoration: BoxDecoration(
                color: _whatsappBubble,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(16),
                  topEnd: Radius.circular(4),
                  bottomStart: Radius.circular(16),
                  bottomEnd: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: _buildMessageSpans(message, link),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 13,
                            color: _onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            context.tr('share_edit'),
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: _onSurfaceVariant.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '10:42 AM',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: _onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── WhatsApp Button ──────────────────────────────────────────────────────────

class _WhatsAppButton extends StatelessWidget {
  final String message;
  const _WhatsAppButton({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaamoraButton(
      label: context.tr('share_send_group'),
      leadingIcon: MaamoraIcons.send,
      variant: MaamoraButtonVariant.whatsapp,
      gradient: const [
        MaamoraColors.whatsappLight, // WhatsApp green lightened (brand brand)
        MaamoraColors.whatsapp,
      ],
      onPressed: () {
        HapticFeedback.mediumImpact();
        NativeShareService.shareCustomMessage(message: message);
      },
    );
  }
}
