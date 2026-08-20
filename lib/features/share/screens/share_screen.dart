import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../profile/providers/profile_provider.dart';
import '../services/native_share_service.dart';
import '../widgets/edit_message_bottom_sheet.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _whatsappGreen = Color(0xFF25D366);
const Color _whatsappBubble = Color(0xFFDCF8C6);

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
    return 'Assalamu alaikum neighbors! 👋\n\nJoin my Maamora group for the best deals on bulk groceries in $city. We buy together, we save together! 🛒✨\n\nClick here to join my group:\n$fullLink';
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

  void _onLinkChanged(String newLink) {
    final trimmedLink = newLink.trim();
    final oldLink = _activeLink;
    final currentMsg = _customMessage ?? _getDefaultMessage(_currentCity, oldLink.isNotEmpty ? oldLink : _defaultLink);

    String updatedMsg;
    if (oldLink.isNotEmpty && currentMsg.contains(oldLink)) {
      updatedMsg = currentMsg.replaceAll(oldLink, trimmedLink);
    } else {
      // If old link not directly found, replace existing URL pattern or append
      final urlRegex = RegExp(r'(https?://[^\s]+|maamora\.ma/[^\s]+)');
      if (urlRegex.hasMatch(currentMsg)) {
        updatedMsg = currentMsg.replaceAll(urlRegex, trimmedLink);
      } else {
        updatedMsg = currentMsg.trimRight().isEmpty
            ? trimmedLink
            : '${currentMsg.trimRight()}\n\n$trimmedLink';
      }
    }

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
                children: const [
                  Icon(Icons.content_paste_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Lien collé et message synchronisé ! ✨'),
                ],
              ),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Presse-papiers vide'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {}
  }

  void _resetLinkToDefault() {
    _linkController.text = _defaultLink;
    _onLinkChanged(_defaultLink);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lien réinitialisé au lien par défaut'),
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
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Message WhatsApp mis à jour !'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
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

  void _showQrDialog(BuildContext context, String fullLink, String referralSlug) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Votre QR Code Maamora',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Faites scanner ce code pour rejoindre directement votre groupe.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 180,
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 100, color: _primary),
                      const SizedBox(height: 8),
                      Text(
                        referralSlug,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _onBackground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fullLink));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lien copié dans le presse-papiers'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copier le lien'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
        loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (ambassador) {
          if (ambassador == null) return const Center(child: Text('Not logged in'));

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    'Share your link',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite your neighbors and start earning\ntogether.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lien copié dans le presse-papiers'),
                          duration: Duration(seconds: 2),
                        ),
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
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onBackground,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Collez ou saisissez votre lien ici...',
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
                message: 'Réinitialiser au lien par défaut',
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
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
              message: 'Coller depuis le presse-papiers',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
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
              message: 'Copier le lien',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy_rounded, color: _primary, size: 19),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // QR icon
          GestureDetector(
            onTap: onQrTap,
            child: Tooltip(
              message: 'Afficher le QR code',
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
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

    final escapedLink = activeLink.isNotEmpty ? RegExp.escape(activeLink) : '';
    final pattern = escapedLink.isNotEmpty
        ? '(?:$escapedLink|https?://[^\\s]+|maamora\\.ma/[^\\s]+)'
        : r'(?:https?://[^\s]+|maamora\.ma/[^\s]+)';

    final regex = RegExp(pattern);
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _onBackground,
            height: 1.5,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue.shade700,
          height: 1.5,
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: GoogleFonts.inter(
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
              'MESSAGE PREVIEW',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _onSurfaceVariant,
                letterSpacing: 1.0,
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
                      'Modifier',
                      style: GoogleFonts.inter(
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
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onEditTap,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: BoxDecoration(
                color: _whatsappBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
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
                            'Tap to edit',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: _onSurfaceVariant.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '10:42 AM',
                        style: GoogleFonts.inter(
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
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => NativeShareService.shareCustomMessage(message: message),
        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        label: Text(
          'Send to WhatsApp group',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _whatsappGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
