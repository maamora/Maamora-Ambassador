import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      appBar: SharedAppBar(pageTitle: context.tr('rules_title')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Intro ────────────────────────────────────────────────
                Text(
                  'Niveaux d\'Ambassadeur',
                  textAlign: TextAlign.center,
                  style: MaamoraTheme.screenTitle().copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('rules_sub'),
                  textAlign: TextAlign.center,
                  style: MaamoraTheme.support(),
                ),
                const SizedBox(height: 28),

                // ── Neutral (Starter) ─────────────────────────────────────
                _buildTierCard(
                  context: context,
                  levelIndex: 0,
                  name: context.tr('dash_tier_neutral'),
                  range: context.tr('rules_tag_neutral'),
                  requirement: context.tr('rules_req_neutral'),
                  commission: '3%',
                  icon: MaamoraIcons.level,
                ),
                const SizedBox(height: 12),

                // ── Bronze ────────────────────────────────────────────────
                _buildTierCard(
                  context: context,
                  levelIndex: 1,
                  name: context.tr('dash_tier_bronze'),
                  range: context.tr('rules_tag_bronze'),
                  requirement: context.tr('rules_req_bronze'),
                  commission: '6%',
                  icon: MaamoraIcons.trophy,
                ),
                const SizedBox(height: 12),

                // ── Silver ────────────────────────────────────────────────
                _buildTierCard(
                  context: context,
                  levelIndex: 2,
                  name: context.tr('dash_tier_silver'),
                  range: context.tr('rules_tag_silver'),
                  requirement: context.tr('rules_req_silver'),
                  commission: '9%',
                  icon: MaamoraIcons.medal,
                ),
                const SizedBox(height: 12),

                // ── Gold ──────────────────────────────────────────────────
                _buildTierCard(
                  context: context,
                  levelIndex: 3,
                  name: context.tr('dash_tier_gold'),
                  range: context.tr('rules_tag_gold'),
                  requirement: context.tr('rules_req_gold'),
                  commission: '10%',
                  icon: MaamoraIcons.crown,
                ),
                const SizedBox(height: 28),

                // ── Good to know ──────────────────────────────────────────
                _buildGoodToKnow(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard({
    required BuildContext context,
    required int levelIndex,
    required String name,
    required String range,
    required String requirement,
    required String commission,
    required IconData icon,
  }) {
    final tierStyle = MaamoraTierStyle.ofLevel(levelIndex);

    return MaamoraCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Metallic disc matching the tier gradient.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: levelIndex == 0
                    ? const [
                        MaamoraColors.navySoft,
                        MaamoraColors.textPrimary,
                      ]
                    : tierStyle.gradient,
              ),
              boxShadow: [
                BoxShadow(
                  color: tierStyle.glow.withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: tierStyle.onColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TierBadge(
                  levelIndex: levelIndex,
                  label: name,
                  showRate: false,
                  compact: true,
                  showIcon: false,
                ),
                const SizedBox(height: 4),
                Text(
                  requirement,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: MaamoraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                commission,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: MaamoraColors.primary,
                ),
              ),
              Text(
                context.tr('rules_commission'),
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: MaamoraColors.textFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoodToKnow(BuildContext context) {
    final rules = [
      context.tr('rules_note1'),
      context.tr('rules_note2'),
      'Si tu manques le seuil de commandes de ton palier, une période de grâce d\'un mois s\'applique avant redescente.',
      context.tr('rules_note4'),
      context.tr('rules_note5'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaamoraColors.primarySoft,
        borderRadius: BorderRadius.circular(MaamoraRadius.card),
        border: Border.all(
          color: MaamoraColors.primaryHairline,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                MaamoraIcons.info,
                color: MaamoraColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('rules_good_to_know'),
                style: MaamoraTheme.sectionHeader(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 7, end: 10),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: MaamoraColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rule,
                      style: MaamoraTheme.support().copyWith(
                        fontSize: 13.5,
                        color: MaamoraColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
