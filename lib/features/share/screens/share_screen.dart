import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/profile_provider.dart';

// ── Design tokens ──────────────────────────────────────────────────────────
const Color _primary = Color(0xFFFB7701);
const Color _background = Color(0xFFFAF5F0);
const Color _surface = Color(0xFFFFFFFF);
const Color _onBackground = Color(0xFF1A2433);
const Color _onSurfaceVariant = Color(0xFF8A8078);
const Color _cardBorder = Color(0xFFE8DDD3);
const Color _whatsappGreen = Color(0xFF25D366);
const Color _whatsappBubble = Color(0xFFDCF8C6);

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  static const String _referralLink = 'maamora.ma/join/amine-tabriquet';
  static const String _shortLink = 'maamora.ma/join/amin...';

  static const String _messageText =
      'Assalamu alaikum neighbors! 👋\n\nJoin my Maamora group for the best deals on bulk groceries in Tabriquet. We buy together, we save together! 🛒✨\n\nClick here to join my group:\nmaamora.ma/join/amine-tabriquet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: _background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (ambassador) {
          if (ambassador == null) return const Center(child: Text('Not logged in'));
          
          final fullLink = 'maamora.ma/join/${ambassador.referralSlug}';
          final shortLink = 'maamora.ma/join/${ambassador.referralSlug.substring(0, ambassador.referralSlug.length > 5 ? 5 : ambassador.referralSlug.length)}...';
          final messageText = 'Assalamu alaikum neighbors! 👋\n\nJoin my Maamora group for the best deals on bulk groceries in ${ambassador.city}. We buy together, we save together! 🛒✨\n\nClick here to join my group:\n$fullLink';

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
              _ReferralLinkBox(link: shortLink, fullLink: fullLink),
              const SizedBox(height: 24),

              // Message Preview
              _MessagePreviewSection(message: messageText),
              const SizedBox(height: 28),

              // WhatsApp Button
              _WhatsAppButton(link: fullLink),
              const SizedBox(height: 20),

              // Weekly stats
              _WeeklyStatsBar(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }),
    );
  }
}

// ── Referral Link Box ────────────────────────────────────────────────────────

class _ReferralLinkBox extends StatelessWidget {
  final String link;
  final String fullLink;
  const _ReferralLinkBox({required this.link, required this.fullLink});

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
            onTap: () {},
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

// ── Message Preview ──────────────────────────────────────────────────────────

class _MessagePreviewSection extends StatelessWidget {
  final String message;
  const _MessagePreviewSection({required this.message});

  @override
  Widget build(BuildContext context) {
    final lines = message.split('\n');
    // Last line is the clickable link
    final mainText = lines.sublist(0, lines.length - 1).join('\n');
    final linkLine = lines.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
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
                const SizedBox(height: 2),
                Text(
                  linkLine,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.blue.shade700,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '10:42 AM',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── WhatsApp Button ──────────────────────────────────────────────────────────

class _WhatsAppButton extends StatelessWidget {
  final String link;
  const _WhatsAppButton({required this.link});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {},
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

// ── Weekly Stats Bar ─────────────────────────────────────────────────────────

class _WeeklyStatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatChip(label: 'taps', value: '42'),
          _divider(),
          _StatChip(label: 'joins', value: '8'),
          _divider(),
          _StatChip(label: 'orders', value: '3'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: _cardBorder,
      );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$value ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
          ),
          TextSpan(
            text: label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
