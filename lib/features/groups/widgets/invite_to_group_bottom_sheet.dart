import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/my_groups_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kOrange = Color(0xFFFB7701);
const Color _kSurface = Color(0xFFFFF8F5);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kOnBg = Color(0xFF251912);
const Color _kOnSurfaceVariant = Color(0xFF584236);
const Color _kOutlineVariant = Color(0xFFE0C0B0);
const Color _kSurfaceContainerHigh = Color(0xFFFBE3D8);
const Color _kSurfaceContainerHighest = Color(0xFFF6DED2);

class InviteToGroupBottomSheet extends StatefulWidget {
  final GroupWithProduct groupData;
  final String? referralUrl;

  const InviteToGroupBottomSheet({
    super.key,
    required this.groupData,
    this.referralUrl,
  });

  static void show(
    BuildContext context, {
    required GroupWithProduct groupData,
    String? referralUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => InviteToGroupBottomSheet(
        groupData: groupData,
        referralUrl: referralUrl,
      ),
    );
  }

  @override
  State<InviteToGroupBottomSheet> createState() =>
      _InviteToGroupBottomSheetState();
}

class _InviteToGroupBottomSheetState extends State<InviteToGroupBottomSheet> {
  bool _linkCopied = false;

  String get _shareText {
    final name = widget.groupData.productName;
    final url = widget.referralUrl ?? 'https://maamora.app';
    final remaining = widget.groupData.group.seuilMin -
        widget.groupData.group.compteurActuel;
    return '🎁 Rejoins mon groupe sur Maamora pour *$name* et on économise ensemble!\n'
        'Plus que $remaining personne(s) pour débloquer le prix groupe 🔓\n\n$url';
  }

  Future<void> _shareWhatsApp() async {
    await Share.share(_shareText, subject: 'Invitation groupe Maamora');
  }

  Future<void> _shareInstagram() async {
    // Instagram doesn't support deep share via share_plus; use system share sheet
    await Share.share(_shareText, subject: 'Invitation groupe Maamora');
  }

  Future<void> _copyLink() async {
    final url = widget.referralUrl ?? 'https://maamora.app';
    await Clipboard.setData(ClipboardData(text: url));
    setState(() => _linkCopied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _linkCopied = false);
  }

  Future<void> _shareMore() async {
    await Share.share(_shareText, subject: 'Invitation groupe Maamora');
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.groupData.group;
    final productName = widget.groupData.productName;
    final current = group.compteurActuel;
    final target = group.seuilMin;
    final remaining = (target - current).clamp(0, target);
    final progress = group.progressRatio;
    final filledSlots = current.clamp(0, 5);
    final emptySlots = (target - filledSlots).clamp(0, 5);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag Handle ───────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: _kOutlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LIVE badge + product name
                            Row(
                              children: [
                                _LiveBadge(),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    productName,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF8A461E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Invite to Group',
                              style: GoogleFonts.plusJakartaSans(
                                color: _kOnBg,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              remaining > 0
                                  ? '$remaining slot${remaining == 1 ? '' : 's'} remaining for group discount!'
                                  : 'Group unlocked! 🎉 Share to earn more points.',
                              style: GoogleFonts.inter(
                                color: _kOnSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _kSurfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: _kOnBg, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Progress Card ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _kWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kOutlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Progress label row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$current/$target friends joined',
                              style: GoogleFonts.inter(
                                color: _kOnBg,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}% Complete',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8A461E),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: _kSurfaceContainerHighest,
                            color: _kOrange,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Avatar row
                        Row(
                          children: [
                            // Filled slots (coloured circles)
                            for (int i = 0; i < filledSlots && i < 5; i++) ...[
                              _FilledAvatar(index: i),
                              const SizedBox(width: 6),
                            ],
                            // Empty slots
                            for (int i = 0; i < emptySlots && (filledSlots + i) < 5; i++) ...[
                              _EmptySlot(),
                              const SizedBox(width: 6),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Share Buttons ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ShareButton(
                          label: 'WhatsApp',
                          backgroundColor: const Color(0xFFE8F5E9),
                          iconWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat,
                                color: Colors.white, size: 22),
                          ),
                          onTap: _shareWhatsApp,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          label: 'Instagram',
                          backgroundColor: const Color(0xFFFCE4EC),
                          iconWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFFDC80),
                                  Color(0xFFF56040),
                                  Color(0xFFC13584),
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 22),
                          ),
                          onTap: _shareInstagram,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShareButton(
                          label: _linkCopied ? 'Copied!' : 'Copy Link',
                          backgroundColor: _kSurfaceContainerHigh,
                          iconWidget: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _linkCopied ? _kOrange : _kWhite,
                              shape: BoxShape.circle,
                              border: Border.all(color: _kOutlineVariant),
                            ),
                            child: Icon(
                              _linkCopied ? Icons.check : Icons.link,
                              color: _linkCopied ? Colors.white : _kOnBg,
                              size: 22,
                            ),
                          ),
                          onTap: _copyLink,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Share to More Apps ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _kOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _shareMore,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_outlined,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Share to More Apps',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LIVE Badge ───────────────────────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9DEDC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _fade,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFB3261E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: GoogleFonts.inter(
              color: const Color(0xFFB3261E),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filled Avatar ────────────────────────────────────────────────────────────
class _FilledAvatar extends StatelessWidget {
  final int index;
  static const List<Color> _colors = [
    Color(0xFFFB7701),
    Color(0xFF1B6194),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFE91E63),
  ];

  const _FilledAvatar({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colors[index % _colors.length],
        border: Border.all(color: _kWhite, width: 2),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Empty Slot ───────────────────────────────────────────────────────────────
class _EmptySlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _kOutlineVariant,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_add_alt, color: _kOutlineVariant, size: 16),
      ),
    );
  }
}

// ─── Share Button Tile ────────────────────────────────────────────────────────
class _ShareButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Widget iconWidget;
  final VoidCallback onTap;

  const _ShareButton({
    required this.label,
    required this.backgroundColor,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            iconWidget,
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                color: _kOnBg,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
