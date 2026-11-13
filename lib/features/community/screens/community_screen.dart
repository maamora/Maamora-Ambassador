import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/widgets/design_kit.dart';
import '../../../core/l10n/app_strings.dart';

/// Prototype screen (not yet wired to Supabase) — restyled to match the
/// Maamora Ambassador design system: same colors, same rounded cards,
/// same icons and badges as the rest of the app.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SharedAppBar(pageTitle: context.tr('community_title')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: StatBox(value: '47', label: context.tr('community_stat_neighbors'), icon: Icons.groups_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '12', label: context.tr('community_stat_active'), icon: Icons.bolt_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: StatBox(value: '89%', label: context.tr('community_retention'), icon: Icons.favorite_outline)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip(context.tr('community_all'), true),
                    _chip(context.tr('community_active'), false),
                    _chip(context.tr('community_new'), false),
                    _chip(context.tr('community_risk'), false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _MemberRow(
                      name: 'Hiba B.',
                      isActive: true,
                      details: context.tr('community_details', args: {
                        'when': context.tr('time_2w'),
                        'n': '4',
                      }),
                      action: 'message',
                    ),
                    _MemberRow(
                      name: 'Soufiane M.',
                      isActive: false,
                      details: context.tr('community_details', args: {
                        'when': context.tr('time_5d'),
                        'n': '2',
                      }),
                      action: 'message',
                    ),
                    _MemberRow(
                      name: 'Amal K.',
                      isActive: true,
                      details: context.tr('community_details', args: {
                        'when': context.tr('time_1mo'),
                        'n': '7',
                      }),
                      action: 'message',
                    ),
                    _MemberRow(
                      name: 'Karim T.',
                      isActive: false,
                      details: context.tr('community_details_one',
                          args: {'when': context.tr('time_3d')}),
                      action: 'message',
                    ),
                    _MemberRow(
                      name: 'Salma R.',
                      isActive: false,
                      details:
                          '${context.tr('time_6w')} · ${context.tr('community_quiet')}',
                      action: 'nudge',
                      isPale: true,
                    ),
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
                color: isPale ? MaamoraColors.primarySoft : MaamoraColors.primarySoft,
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
                color: nudge ? MaamoraColors.primarySoft : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: nudge ? AppColors.primary.withValues(alpha: 0.35) : AppColors.cardBorder),
              ),
              child: Text(
                nudge ? context.tr('community_nudge') : context.tr('community_message'),
                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: nudge ? AppColors.primary : AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
