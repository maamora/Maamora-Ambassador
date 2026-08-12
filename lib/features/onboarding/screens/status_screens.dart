import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _StatusScreen(
      icon: Icons.hourglass_empty,
      title: 'Compte en attente',
      message: 'Votre compte est en attente de validation.',
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
