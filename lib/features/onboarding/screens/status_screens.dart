import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () {
            ref.read(authProvider.notifier).signOut();
            context.go('/login');
          },
        ),
        title: Text(
          'Application Submitted',
          style: AppTheme.headlineSm.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: profileAsync.when(
        data: (profile) {
          final firstName = profile?.fullName.split(' ').first ?? 'Ambassador';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(Icons.star, size: 16, color: AppColors.primary),
                    ),
                    const Positioned(
                      bottom: 20,
                      left: 10,
                      child: Icon(Icons.star_border, size: 20, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  "You're almost in, $firstName!",
                  style: AppTheme.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Your application is being reviewed by the Maamora team. This usually takes less than 24h.",
                  style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 10, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Text(
                        "PENDING REVIEW",
                        style: AppTheme.labelMd.copyWith(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Application Details",
                        style: AppTheme.headlineSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.person_outline,
                        label: "Full Name",
                        value: profile?.fullName ?? '-',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.location_city_outlined,
                        label: "City",
                        value: profile?.city ?? '-',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Payout Method",
                        value: profile?.payoutMethod ?? '-',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text('Error loading profile')),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget!
        else if (value != null)
          Text(
            value!,
            style: AppTheme.bodyMd.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
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
      title: 'Compte en pause',
      message: 'Votre compte est temporairement en pause.',
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
      title: 'Demande refusée',
      message: authState.rejectionReason ?? 'Votre demande a été refusée.',
    );
  }
}

class UnregisteredScreen extends ConsumerWidget {
  const UnregisteredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _StatusScreen(
      icon: Icons.no_accounts_outlined,
      title: 'Profil introuvable',
      message: 'Compte non trouvé ou invitation inexistante.',
      action: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          ref.read(authProvider.notifier).signOut();
          context.go('/login');
        },
        child: const Text('Retour à la connexion'),
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
      backgroundColor: const Color(0xFFFAF4EE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTheme.headlineSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              ),
              if (action != null) ...[
                const SizedBox(height: 24),
                action!,
              ]
            ],
          ),
        ),
      ),
    );
  }
}
