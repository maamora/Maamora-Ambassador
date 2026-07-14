// features/onboarding/screens/email_verification_screen.dart
import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.onGoToLogin,
  });

  final String email;
  final VoidCallback onGoToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Effet de halo en arrière-plan
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryContainer.withValues(alpha: 0.15),
                    AppColors.background.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône d'enveloppe animée/stylisée
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Vérifiez votre boîte de réception !',
                        textAlign: TextAlign.center,
                        style: AppTheme.headlineXl.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTheme.bodyMd.copyWith(
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  "Un e-mail de confirmation a été envoyé à l'adresse :\n",
                            ),
                            TextSpan(
                              text: email,
                              style: AppTheme.bodyMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Veuillez cliquer sur le lien contenu dans cet e-mail pour activer votre compte d'ambassadeur Maamora.",
                        textAlign: TextAlign.center,
                        style: AppTheme.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AppButton(
                        label: 'Se connecter',
                        trailingIcon: Icons.login,
                        onPressed: onGoToLogin,
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          // Optionnel : renvoyer l'email de confirmation
                          // provider.resendSignUpEmail(email);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Un nouvel e-mail a été envoyé.'),
                            ),
                          );
                        },
                        child: Text(
                          "Je n'ai pas reçu d'e-mail",
                          style: AppTheme.labelMd.copyWith(
                            color: AppColors.secondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
}
