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
  String? _customMessage;
  bool _hasLoadedSavedMessage = false;

  String _getDefaultMessage(String city, String fullLink) {
    return 'Assalamu alaikum neighbors! 👋\n\nJoin my Maamora group for the best deals on bulk groceries in $city. We buy together, we save together! 🛒✨\n\nClick here to join my group:\n$fullLink';
  }

  Future<void> _loadSavedMessage(String ambassadorId) async {
    if (_hasLoadedSavedMessage) return;
    _hasLoadedSavedMessage = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('custom_share_message_$ambassadorId');
      if (saved != null && saved.trim().isNotEmpty && mounted) {
        setState(() {
          _customMessage = saved;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCustomMessage(String ambassadorId, String newMessage) async {
    setState(() {
      _customMessage = newMessage;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_share_message_$ambassadorId', newMessage);
    } catch (_) {}

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
    required String ambassadorId,
    required String currentMessage,
    required String defaultMessage,
    required String fullLink,
    required String city,
  }) {
    EditMessageBottomSheet.show(
      context: context,
      currentMessage: currentMessage,
      defaultMessage: defaultMessage,
      referralLink: fullLink,
      city: city,
      onSaved: (newMessage) => _saveCustomMessage(ambassadorId, newMessage),
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

          final fullLink = 'maamora.ma/join/${ambassador.referralSlug}';
          final shortLink =
              'maamora.ma/join/${ambassador.referralSlug.substring(0, ambassador.referralSlug.length > 5 ? 5 : ambassador.referralSlug.length)}...';
          final defaultMessage = _getDefaultMessage(ambassador.city, fullLink);

          // Trigger loading saved custom message once
          _loadSavedMessage(ambassador.id);

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

                  // Referral Link Box
                  _ReferralLinkBox(
                    link: shortLink,
                    fullLink: fullLink,
                    onQrTap: () => _showQrDialog(context, fullLink, ambassador.referralSlug),
                  ),
                  const SizedBox(height: 24),

                  // Message Preview Section with Edit Button
                  _MessagePreviewSection(
                    message: activeMessage,
                    link: fullLink,
                    onEditTap: () => _openEditSheet(
                      context: context,
                      ambassadorId: ambassador.id,
                      currentMessage: activeMessage,
                      defaultMessage: defaultMessage,
                      fullLink: fullLink,
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

// ── Referral Link Box ────────────────────────────────────────────────────────

class _ReferralLinkBox extends StatelessWidget {
  final String link;
  final String fullLink;
  final VoidCallback onQrTap;

  const _ReferralLinkBox({
    required this.link,
    required this.fullLink,
    required this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Expanded(
            child: Text(
              link,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Copy icon
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: fullLink));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded, color: _primary, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // QR icon
          GestureDetector(
            onTap: onQrTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.qr_code_rounded, color: _primary, size: 20),
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

  @override
  Widget build(BuildContext context) {
    // Separate link and main text if present
    String mainText = message;
    String? linkText;

    if (message.contains(link)) {
      final index = message.lastIndexOf(link);
      mainText = message.substring(0, index).trimRight();
      linkText = link;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Title and "Edit" action button
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
                  Text(
                    mainText,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _onBackground,
                      height: 1.5,
                    ),
                  ),
                  if (linkText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      linkText,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note_rounded, size: 13, color: _onSurfaceVariant.withValues(alpha: 0.7)),
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
