// features/onboarding/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../../../shared/navigation/app_routes.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/language_toggle.dart';

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
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: LanguageToggle(),
                      ),
                      const SizedBox(height: 20),
                      Center(child: _buildHeader()),
                      const SizedBox(height: 36),
                      Text(
                        context.tr('login_welcome'),
                        style: AppTheme.headlineXl.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('login_subtitle'),
                        style: AppTheme.bodyMd
                            .copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        label: context.tr('login_google'),
                        variant: AppButtonVariant.outlined,
                        leadingIcon: Icons.g_mobiledata,
                        isLoading: _isSigningIn,
                        onPressed: _handleGoogleSignIn,
                      ),
                      const SizedBox(height: 20),
                      _buildInviteCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Real Maamora logo (assets/images/maamora_logo.png)
        Image.asset(
          'assets/images/maamora_logo.png',
          width: 140,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        const Text(
          'Maamora',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.tr('login_tagline'),
          style: AppTheme.bodySm.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            context.tr('login_badge'),
            style: AppTheme.labelMd
                .copyWith(color: AppColors.secondary, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.vpn_key_outlined,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('login_new'),
            style: AppTheme.headlineSm.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('login_need_invite'),
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: context.tr('login_have_invite'),
            variant: AppButtonVariant.outlined,
            onPressed: widget.onCreateAccount,
          ),
        ],
      ),
    );
  }
}
