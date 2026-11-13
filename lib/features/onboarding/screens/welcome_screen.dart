// features/onboarding/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../design_system/design_system.dart';
import '../../../core/l10n/app_strings.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.onGoToDashboard,
    this.onSeeHowLevelsWork,
  });

  final VoidCallback? onGoToDashboard;
  final VoidCallback? onSeeHowLevelsWork;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  // Dummy personal ambassador link
  static const String _personalLink = 'maamora.ma/s/FATIMA-7F3';

  bool _linkCopied = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _copyLink() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _personalLink));
    MaamoraToast.success(context, context.tr('share_link_copied'));
    setState(() => _linkCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _linkCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      body: SafeArea(
        child: Stack(
          children: [
            // One-shot confetti burst on arrival — the activation reward moment.
            const Positioned.fill(
              child: IgnorePointer(child: MaamoraConfetti()),
            ),
            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: MaamoraStagger(
                                children: [
                                  _buildSuccessIcon(),
                                  const SizedBox(height: 24),
                                  _buildTitle(),
                                  const SizedBox(height: 32),
                                  _buildLinkCard(),
                                  const SizedBox(height: 24),
                                  _buildInfoCard(),
                                ],
                              ),
                            ),
                          ),
                          _buildActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.6, end: 1.0),
      duration: MaamoraDurations.slow,
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Transform.scale(scale: t, child: child);
      },
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: MaamoraColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: MaamoraColors.primaryHairline, width: 2),
            boxShadow: MaamoraShadows.glow(MaamoraColors.primary, 0.28),
          ),
          child: Center(
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: MaamoraGradients.heroOrange,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                MaamoraIcons.checkFilled,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          context.tr('welcome_title'),
          textAlign: TextAlign.center,
          style: MaamoraTheme.screenTitle().copyWith(fontSize: 28),
        ),
        const SizedBox(height: 10),
        Text(
          context.tr('welcome_sub'),
          textAlign: TextAlign.center,
          style: MaamoraTheme.support().copyWith(fontSize: 14.5),
        ),
      ],
    );
  }

  Widget _buildLinkCard() {
    return MaamoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MaamoraColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  MaamoraIcons.link,
                  color: MaamoraColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('welcome_link_title'),
                style: MaamoraTheme.sectionHeader().copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: MaamoraColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MaamoraColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _personalLink,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MaamoraColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _copyLink,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      _linkCopied ? MaamoraIcons.check : MaamoraIcons.copy,
                      key: ValueKey(_linkCopied),
                      color: _linkCopied
                          ? MaamoraColors.primary
                          : MaamoraColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('welcome_link_sub'),
            style: MaamoraTheme.support().copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MaamoraColors.primarySoft,
        borderRadius: BorderRadius.circular(MaamoraRadius.cardSm),
        border: Border.all(color: MaamoraColors.primaryHairline),
      ),
      child: Row(
        children: [
          const Icon(
            MaamoraIcons.sparkles,
            color: MaamoraColors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tu démarres au niveau Starter — 4% de commission. Réalise 6 commandes pour atteindre Bronze et débloquer 6%.',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: MaamoraColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Share on WhatsApp
        MaamoraButton(
          label: context.tr('welcome_share'),
          leadingIcon: MaamoraIcons.whatsapp,
          variant: MaamoraButtonVariant.whatsapp,
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Static – no backend. In production: launch WhatsApp share URL.
          },
        ),
        const SizedBox(height: 12),
        // See how levels work
        MaamoraButton(
          label: context.tr('welcome_levels'),
          leadingIcon: MaamoraIcons.board,
          variant: MaamoraButtonVariant.outlined,
          height: 52,
          onPressed: widget.onSeeHowLevelsWork,
        ),
        const SizedBox(height: 14),
        MaamoraButton(
          label: context.tr('welcome_dash'),
          variant: MaamoraButtonVariant.ghost,
          height: 44,
          onPressed: widget.onGoToDashboard,
        ),
      ],
    );
  }
}
