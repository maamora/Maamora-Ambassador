// features/onboarding/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../shared/navigation/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onCreateAccount,
    this.onForgotPassword,
  });

  final VoidCallback? onLoginSuccess;
  final VoidCallback? onCreateAccount;
  final VoidCallback? onForgotPassword;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSigningIn = false;

  void _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    
    await ref.read(authProvider.notifier).signInWithGoogle();
    
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    final authState = ref.read(authProvider);
    
    if (authState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authState.errorMessage!), backgroundColor: Colors.red),
      );
      return;
    }

    _routeBasedOnStatus(authState.status);
  }
  
  void _routeBasedOnStatus(AmbassadorStatus status) {
    switch (status) {
      case AmbassadorStatus.admin:
        context.go(AppRoutes.admin);
        break;
      case AmbassadorStatus.pending:
        context.go(AppRoutes.pending);
        break;
      case AmbassadorStatus.active:
        widget.onLoginSuccess?.call(); // usually goes to dashboard
        break;
      case AmbassadorStatus.rejected:
        context.go(AppRoutes.rejected);
        break;
      case AmbassadorStatus.paused:
        context.go(AppRoutes.paused);
        break;
      case AmbassadorStatus.unregistered:
        context.go(AppRoutes.unregistered);
        break;
      default:
        // Do nothing if initial or unauthenticated
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to status changes to handle automatic redirects (e.g. if user is already signed in)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false && next.status != AmbassadorStatus.unauthenticated && next.status != AmbassadorStatus.initial) {
        if (!_isSigningIn) {
          final location = GoRouterState.of(context).matchedLocation;
          if (location == AppRoutes.login) {
            _routeBasedOnStatus(next.status);
          }
        }
      }
    });

    // Initial check in case state is already loaded when screen mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (!authState.isLoading && authState.status != AmbassadorStatus.unauthenticated && authState.status != AmbassadorStatus.initial) {
        final location = GoRouterState.of(context).matchedLocation;
        if (location == AppRoutes.login) {
          _routeBasedOnStatus(authState.status);
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4EE),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildGoogleCard(),
                  const SizedBox(height: 20),
                  _buildInviteCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Transform.rotate(
          angle: -0.04,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFE8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5DFDA), width: 1),
            ),
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              'assets/images/maamora_logo.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF0E4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'AMBASSADOR · PRIVATE APP',
                style: AppTheme.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE6DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connexion à votre compte',
            style: AppTheme.headlineSm.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFDDD5CC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSigningIn ? null : _handleGoogleSignIn,
              child: _isSigningIn
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.g_mobiledata, size: 28, color: AppColors.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Se connecter avec Google',
                          style: AppTheme.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
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

  Widget _buildInviteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEEEDE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '✦',
            style: TextStyle(
              fontSize: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'New here?',
            style: AppTheme.headlineSm.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You need an invite code to join the ambassador\nprogram.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFDDD5CC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: widget.onCreateAccount,
              icon: const Icon(
                Icons.vpn_key_outlined,
                color: AppColors.secondary,
                size: 18,
              ),
              label: Text(
                'I have an invite code',
                style: AppTheme.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
