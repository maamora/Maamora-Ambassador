import 'package:ambassadors/features/onboarding/widgets/benefit_list_item.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../widgets/benefit_card.dart';
import '../widgets/requirements_card.dart';

/// First screen of the onboarding flow: pitches the ambassador program
/// before the actual sign-up form. Not authenticated yet, so this screen
/// has no app shell (no drawer/avatar/bottom nav) — just a simple back
/// arrow + title, matching a pre-signup landing page.
///
/// Route: pushes to the sign-up form screen when "Start application" is tapped.
class AmbassadorIntroScreen extends StatelessWidget {
  const AmbassadorIntroScreen({super.key, this.onStartApplication});

  /// Callback fired when the user taps "Start application".
  /// Wire this to your router / navigate to the sign-up form screen.
  final VoidCallback? onStartApplication;

  static const _requirements = [
    '18+',
    'Phone verified',
    'A place where neighbors can pick up (shop, café, your home)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHero(),
                    const SizedBox(height: 16),
                    // Text('Become an ambassador', style: AppTheme.headlineLg),
                    const SizedBox(height: 8),
                    Text(
                      'Earn while your neighborhood saves. Run a pickup point. '
                      'Bring neighbors in. Get paid every time a group you organized fills.',
                      style: AppTheme.bodyLg,
                    ),
                    const SizedBox(height: 24),
                    // _buildBenefitsGrid(),
                    _buildBenefitsList(),
                    const SizedBox(height: 24),
                    RequirementsCard(requirements: _requirements),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed CTA row, pinned to the bottom like in the wireframe —
      // stays put while the content above scrolls.
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Text('Become an ambassador', style: AppTheme.headlineSm),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // TODO: replace with real hero image (Image.network / Image.asset).
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    return GridView.count(
      crossAxisCount: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: const [
        BenefitCard(
          icon: Icons.savings_outlined,
          tagLabel: 'Revenues',
          tagColor: AppColors.tertiary,
          onTagColor: AppColors.tertiary,
          title: '5 DH per buyer',
          subtitle: 'every group order that fills',
        ),
        BenefitCard(
          icon: Icons.emoji_events_outlined,
          tagLabel: 'Bonus',
          tagColor: AppColors.secondary,
          onTagColor: AppColors.secondary,
          title: 'Bonus payouts',
          subtitle: 'hit weekly tier goals → +200 DH',
        ),
        BenefitCard(
          icon: Icons.verified_outlined,
          tagLabel: 'Confiance',
          tagColor: AppColors.primary,
          onTagColor: AppColors.primary,
          title: 'Verified badge',
          subtitle: "your neighbors see you're trusted",
        ),
        BenefitCard(
          icon: Icons.card_giftcard_outlined,
          tagLabel: 'Cadeaux',
          tagColor: AppColors.tertiary,
          onTagColor: AppColors.tertiary,
          title: 'Free bundles',
          subtitle: 'monthly product gifts from vendors',
        ),
      ],
    );
  }

  Widget _buildBenefitsList() {
    return const Column(
      children: [
        BenefitListItem(
          icon: Icons.savings_outlined,
          iconColor: AppColors.secondaryContainer,
          title: '5 DH per buyer',
          subtitle: 'every group order that fills',
        ),
        SizedBox(height: 20),
        BenefitListItem(
          icon: Icons.emoji_events_outlined,
          iconColor: AppColors.secondaryContainer,
          title: 'Bonus payouts',
          subtitle: 'hit weekly tier goals → +200 DH',
        ),
        SizedBox(height: 20),
        BenefitListItem(
          icon: Icons.verified_outlined,
          iconColor: AppColors.tertiary,
          title: 'Verified badge',
          subtitle: "your neighbors see you're trusted",
        ),
        SizedBox(height: 20),
        BenefitListItem(
          icon: Icons.card_giftcard_outlined,
          iconColor: AppColors.primaryContainer,
          title: 'Free bundles',
          subtitle: 'monthly product gifts from vendors',
        ),
      ],
    );
  }

  /// Fixed footer: "Learn more" + "Start application" side by side,
  /// pinned to the bottom of the screen (matches the wireframe), plus
  /// the legal text underneath.
  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // TODO: show more info (e.g. modal / FAQ screen).
                    },
                    child: Text('Learn more', style: AppTheme.headlineSm),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: onStartApplication,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start application',
                            style: AppTheme.headlineSm.copyWith(
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLegalText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTheme.bodySm,
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: AppTheme.bodySm.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: AppTheme.bodySm.copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
