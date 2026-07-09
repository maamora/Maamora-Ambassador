import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/onboarding_provider.dart';

/// Login screen for returning ambassadors.
/// Wrap this screen (or higher up in the tree) with:
///   ChangeNotifierProvider(create: (_) => OnboardingProvider())
///
/// Route params:
/// - [onLoginSuccess]: called after a successful sign-in (e.g. navigate to Dashboard).
/// - [onCreateAccount]: called when the user taps "Créer un compte"
///   (e.g. navigate to AmbassadorIntroScreen / sign-up form).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess, this.onCreateAccount});

  final VoidCallback? onLoginSuccess;
  final VoidCallback? onCreateAccount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(OnboardingProvider provider) async {
    FocusScope.of(context).unfocus();
    
    // Bypass de l'authentification pour faciliter le développement
    if (mounted) {
      widget.onLoginSuccess?.call();
    }
  }

  Future<void> _handleForgotPassword(OnboardingProvider provider) async {
    final email = _emailController.text.trim();
    if (provider.validateEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez votre email d\'abord')),
      );
      return;
    }
    await provider.sendPasswordResetEmail(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email de réinitialisation envoyé')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Stack(
              children: [
                // Ambient glow decoration (simplified from the design's radial gradients)
                Positioned(top: -100, left: -100, child: _glow()),
                Positioned(bottom: -100, right: -100, child: _glow()),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 32,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 48),
                              _buildLoginPanel(provider),
                              const SizedBox(height: 32),
                              _buildFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _glow() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.primaryContainer.withValues(alpha: 0.15),
            AppColors.background.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Transform.rotate(
          angle: 0.05,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/images/maamora_logo.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Maamora',
          style: AppTheme.headlineXl.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            'Connectez-vous pour gérer votre communauté et vos récompenses.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPanel(OnboardingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (provider.errorMessage != null) ...[
            _buildErrorBanner(provider.errorMessage!),
            const SizedBox(height: 16),
          ],
          AppTextField(
            label: 'Email',
            icon: Icons.mail_outline,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: provider.validateEmail,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            controller: _passwordController,
            obscureText: provider.obscurePassword,
            autofillHints: const [AutofillHints.password],
            validator: provider.validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                provider.obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: provider.toggleObscurePassword,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _handleForgotPassword(provider),
              child: Text(
                'Mot de passe oublié ?',
                style: AppTheme.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Se connecter',
            trailingIcon: Icons.arrow_forward,
            isLoading: provider.isLoading,
            onPressed: () => _handleSignIn(provider),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildSocialButtons(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodySm.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OU CONTINUER AVEC',
            style: AppTheme.labelMd.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons
                .g_mobiledata, // TODO: swap for the real Google "G" logo asset.
            onPressed: () {
              // TODO: wire google_sign_in package + provider.signInWithGoogle()
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icons.apple,
            onPressed: () {
              // TODO: wire sign_in_with_apple package (iOS only)
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTheme.bodySm,
            children: [
              const TextSpan(text: 'Pas encore ambassadeur ? '),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: widget.onCreateAccount,
                  child: Text(
                    'Créer un compte',
                    style: AppTheme.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'En vous connectant, vous acceptez nos Conditions d\'utilisation '
            'et notre Politique de Confidentialité.',
            textAlign: TextAlign.center,
            style: AppTheme.bodySm.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerHigh,
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onSurface),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.labelMd.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
