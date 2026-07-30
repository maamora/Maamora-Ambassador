// features/onboarding/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/onboarding_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.onBackToLogin});

  final VoidCallback? onBackToLogin;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink(OnboardingProvider provider) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() => _emailSent = true);
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.primary),
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _emailSent
                        ? _buildConfirmation()
                        : _buildForm(provider),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(OnboardingProvider provider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(
            'Mot de passe oublié ?',
            style: AppTheme.headlineXl.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              "Entrez votre adresse email, nous vous enverrons un lien pour "
              'réinitialiser votre mot de passe.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 24),
          AppButton(
            label: 'Envoyer le lien',
            trailingIcon: Icons.arrow_forward,
            isLoading: provider.isResetLoading,
            onPressed: () => _handleSendResetLink(provider),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onBackToLogin,
            child: Text(
              'Retour à la connexion',
              style: AppTheme.labelMd.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    final email = _emailController.text.trim();
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppColors.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Vérifiez votre boîte mail',
          textAlign: TextAlign.center,
          style: AppTheme.headlineXl.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'Si un compte existe pour $email, un lien de réinitialisation '
            "vient d'être envoyé. Ouvrez-le depuis votre téléphone pour "
            "revenir directement dans l'app.",
            textAlign: TextAlign.center,
            style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Retour à la connexion',
          onPressed: widget.onBackToLogin ?? () {},
        ),
      ],
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
}
