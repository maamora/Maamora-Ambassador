import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/onboarding_provider.dart';

/// Sign-up (registration) screen for new ambassadors.
/// Wrap this screen with ChangeNotifierProvider(create: (_) => OnboardingProvider())
/// unless it already sits below one in the tree (e.g. same provider as LoginScreen).
///
/// Route params:
/// - [onSignUpSuccess]: called after account creation succeeds
///   (e.g. navigate to Dashboard, or to a "check your phone" step).
/// - [onGoToLogin]: called when the user taps "Se connecter"
///   (e.g. navigate to LoginScreen).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onSignUpSuccess, this.onGoToLogin});

  final VoidCallback? onSignUpSuccess;
  final VoidCallback? onGoToLogin;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp(OnboardingProvider provider) async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState!.validate();

    setState(() => _termsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;

    final success = await provider.signUp(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (success && mounted) {
      widget.onSignUpSuccess?.call();
    }
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
                // Decorative background glows (simplified from the design's blurred circles)
                Positioned(
                  top: -60,
                  left: -60,
                  child: _glow(AppColors.primaryContainer),
                ),
                Positioned(
                  bottom: 100,
                  right: -80,
                  child: _glow(AppColors.secondaryContainer),
                ),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                              _buildVisualAnchor(),
                              const SizedBox(height: 24),
                              if (provider.errorMessage != null) ...[
                                _buildErrorBanner(provider.errorMessage!),
                                const SizedBox(height: 16),
                              ],
                              _buildForm(provider),
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

  Widget _glow(Color color) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.15),
            AppColors.background.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Transform.rotate(
          angle: 0.05,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
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
        const SizedBox(height: 16),
        Text(
          'Maamora',
          style: AppTheme.headlineXl.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Rejoignez notre communauté d'ambassadeurs et transformez votre "
            'influence en récompenses exclusives.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualAnchor() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // TODO: replace with real community photo (Image.network / Image.asset).
            Container(color: AppColors.surfaceContainer),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.outlineVariant,
                size: 36,
              ),
            ),
          ],
        ),
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

  Widget _buildForm(OnboardingProvider provider) {
    return Column(
      children: [
        AppTextField(
          label: 'Nom complet',
          icon: Icons.person_outline,
          controller: _nameController,
          autofillHints: const [AutofillHints.name],
          validator: provider.validateName,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Adresse Email',
          icon: Icons.mail_outline,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          validator: provider.validateEmail,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Numéro de téléphone',
          icon: Icons.call_outlined,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: provider.validatePhone,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          controller: _passwordController,
          obscureText: provider.obscurePassword,
          autofillHints: const [AutofillHints.newPassword],
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
        const SizedBox(height: 12),
        _buildTermsCheckbox(),
        const SizedBox(height: 20),
        AppButton(
          label: "S'INSCRIRE",
          trailingIcon: Icons.arrow_forward,
          isLoading: provider.isLoading,
          onPressed: () => _handleSignUp(provider),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptedTerms,
              activeColor: AppColors.primaryContainer,
              side: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                  if (_acceptedTerms) _termsError = false;
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.bodySm,
                    children: [
                      const TextSpan(text: 'En continuant, vous acceptez nos '),
                      TextSpan(
                        text: "Conditions d'utilisation",
                        style: AppTheme.bodySm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' et notre '),
                      TextSpan(
                        text: 'Politique de confidentialité',
                        style: AppTheme.bodySm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // Corrected: the mockup's checkbox was decorative only (no submit guard).
        // Sign-up now blocks submission until this is checked.
        if (_termsError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              'Vous devez accepter les conditions pour continuer',
              style: AppTheme.bodySm.copyWith(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            height: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTheme.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              children: [
                const TextSpan(text: 'Vous avez déjà un compte ? '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onGoToLogin,
                    child: Text(
                      'Se connecter',
                      style: AppTheme.bodyMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
