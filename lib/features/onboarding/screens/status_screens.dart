import 'package:flutter/material.dart';
import '../../../shared/widgets/shared_app_bar.dart';
import '../../../shared/widgets/design_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/l10n/app_strings.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      appBar: SharedAppBar(
        pageTitle: context.tr('status_submitted'),
        profileEnabled: false,
        onBack: () {
          ref.read(authProvider.notifier).signOut();
          context.go('/login');
        },
      ),
      body: profileAsync.when(
        data: (profile) {
          final firstName = (profile?.fullName ?? '').trim().split(' ').first;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: MaamoraSpacing.screen,
              vertical: MaamoraSpacing.xl,
            ),
            child: Column(
              children: [
                const SizedBox(height: MaamoraSpacing.lg),
                const _StatusEmblem(icon: Icons.hourglass_empty_rounded),
                const SizedBox(height: MaamoraSpacing.xl),
                Text(
                  firstName.isEmpty
                      ? context.tr('status_pending_hello_anon')
                      : context.tr(
                          'status_pending_hello',
                          args: {'name': firstName},
                        ),
                  style: AppTheme.headlineSm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: MaamoraColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MaamoraSpacing.md),
                Text(
                  context.tr('status_pending_sub'),
                  style: AppTheme.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MaamoraSpacing.xl),
                // Status = colour + icon + label (never colour alone).
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MaamoraSpacing.lg,
                    vertical: MaamoraSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: MaamoraColors.warningSoft,
                    borderRadius: BorderRadius.circular(MaamoraRadius.chip),
                    border: Border.all(color: MaamoraColors.warningEdge),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        MaamoraIcons.timer,
                        size: 16,
                        color: MaamoraColors.warningDeep,
                      ),
                      const SizedBox(width: MaamoraSpacing.sm),
                      Flexible(
                        child: Text(
                          context.tr('status_pending_badge'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.labelMd.copyWith(
                            color: MaamoraColors.warningDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MaamoraSpacing.xl + MaamoraSpacing.lg),
                MaamoraCard(
                  padding: const EdgeInsets.all(MaamoraSpacing.screen),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('status_details_title'),
                        style: MaamoraTheme.sectionHeader(),
                      ),
                      const SizedBox(height: MaamoraSpacing.lg),
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: context.tr('status_full_name'),
                        value: profile?.fullName,
                      ),
                      const Divider(
                        height: MaamoraSpacing.xl,
                        color: MaamoraColors.border,
                      ),
                      _DetailRow(
                        icon: Icons.location_city_outlined,
                        label: context.tr('status_city'),
                        value: profile?.city,
                      ),
                      const Divider(
                        height: MaamoraSpacing.xl,
                        color: MaamoraColors.border,
                      ),
                      _DetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: context.tr('status_payout'),
                        value: profile?.payoutMethod,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoader(),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(MaamoraSpacing.screen),
          child: Center(
            child: MaamoraErrorState(
              title: context.tr('status_error'),
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large soft circle with the status icon — shared by every status screen.
class _StatusEmblem extends StatelessWidget {
  const _StatusEmblem({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 112,
        height: 112,
        decoration: const BoxDecoration(
          color: MaamoraColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 48, color: MaamoraColors.primary),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _DetailRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final shown = (value == null || value!.trim().isEmpty) ? '—' : value!;
    return Row(
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: MaamoraSpacing.md),
        Text(
          label,
          style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(width: MaamoraSpacing.md),
        // Long values (payout details) must never push the row off-screen.
        Expanded(
          child: Text(
            shown,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.bodyMd.copyWith(
              color: MaamoraColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class PausedScreen extends StatelessWidget {
  const PausedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StatusScreen(
      icon: Icons.pause_circle_outline,
      title: context.tr('status_paused_title'),
      message: context.tr('status_paused_sub'),
    );
  }
}

class RejectedScreen extends ConsumerWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return _StatusScreen(
      icon: Icons.cancel_outlined,
      title: context.tr('status_refused_title'),
      message: authState.rejectionReason ?? context.tr('status_refused_sub'),
    );
  }
}

class UnregisteredScreen extends ConsumerWidget {
  const UnregisteredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StatusScreen(
      icon: Icons.no_accounts_outlined,
      title: context.tr('status_not_found_title'),
      message: context.tr('status_not_found_sub'),
      action: MaamoraButton(
        label: context.tr('status_back_login'),
        onPressed: () {
          ref.read(authProvider.notifier).signOut();
          context.go('/login');
        },
      ),
    );
  }
}

class _StatusScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _StatusScreen({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaamoraColors.scaffold,
      appBar: const SharedAppBar(profileEnabled: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MaamoraSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatusEmblem(icon: icon),
              const SizedBox(height: MaamoraSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  color: MaamoraColors.textPrimary,
                ),
              ),
              const SizedBox(height: MaamoraSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: MaamoraSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
