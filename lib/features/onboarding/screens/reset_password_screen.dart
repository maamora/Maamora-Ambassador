// features/onboarding/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/onboarding_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final VoidCallback onResetSuccess;

  const ResetPasswordScreen({super.key, required this.onResetSuccess});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmReset(OnboardingProvider provider) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await provider.updatePasswordAfterRecovery(
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour avec succès !')),
      );
      widget.onResetSuccess();
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Nouveau mot de passe',
                            style: AppTheme.headlineXl.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              'Votre lien a été vérifié. Choisissez un '
                              'nouveau mot de passe pour votre compte.',
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyMd.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          if (provider.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                provider.errorMessage!,
                                style: AppTheme.bodySm.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          AppTextField(
                            label: 'Nouveau mot de passe',
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
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Confirmer le mot de passe',
                            icon: Icons.lock_outline,
                            controller: _confirmController,
                            obscureText: provider.obscurePassword,
                            validator: (value) =>
                                provider.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: 'Confirmer',
                            isLoading: provider.isUpdatingPassword,
                            onPressed: () => _handleConfirmReset(provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
