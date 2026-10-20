import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/design_kit.dart';

/// Prototype screen (not yet wired to Supabase) — restyled to match the
/// Maamora Ambassador design system: same colors, same rounded cards,
/// same icons and badges as the rest of the app.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SharedAppBar(pageTitle: 'Community'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: StatBox(value: '47', label: 'Neighbors', icon: Icons.groups_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '12', label: 'Active this week', icon: Icons.bolt_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '89%', label: 'Retention', icon: Icons.favorite_outline)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip('All', true),
                    _chip('Active', false),
                    _chip('New', false),
                    _chip('At risk', false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    _MemberRow(name: 'Hiba B.', isActive: true, details: 'joined 2w ago · 4 buys', action: 'message'),
                    _MemberRow(name: 'Soufiane M.', isActive: false, details: 'joined 5d ago · 2 buys', action: 'message'),
                    _MemberRow(name: 'Amal K.', isActive: true, details: 'joined 1mo ago · 7 buys', action: 'message'),
                    _MemberRow(name: 'Karim T.', isActive: false, details: 'joined 3d ago · 1 buy', action: 'message'),
                    _MemberRow(name: 'Salma R.', isActive: false, details: 'joined 6w ago · quiet · 0 buys', action: 'nudge', isPale: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool active) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.secondary : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? AppColors.secondary : AppColors.cardBorder),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      );
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.name,
    required this.isActive,
    required this.details,
    required this.action,
    this.isPale = false,
  });
  final String name;
  final bool isActive;
  final String details;
  final String action;
  final bool isPale;

  @override
  Widget build(BuildContext context) {
    final nudge = action == 'nudge';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isPale ? const Color(0xFFFFF0E3) : const Color(0xFFFFE7DA),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: GoogleFonts.cairo(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                      if (isActive) const Padding(padding: EdgeInsetsDirectional.only(start: 6), child: Text('🔥', style: TextStyle(fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(details, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: nudge ? const Color(0xFFFFF0E3) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: nudge ? AppColors.primary.withValues(alpha: 0.35) : AppColors.cardBorder),
              ),
              child: Text(
                nudge ? 'Nudge' : 'Message',
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: nudge ? AppColors.primary : AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
