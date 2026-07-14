// features/onboarding/providers/onboarding_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_client_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final _supabase = SupabaseClientService.client;
  bool isLoading = false;
  String? errorMessage;

  // UI State for password visibility
  bool obscurePassword = true;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // Form Validators
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Le nom complet est requis';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'email est requis';
    if (!value.contains('@')) return 'Veuillez entrer une adresse email valide';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      // 1. Create the auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final authUserId = authResponse.user?.id;
      if (authUserId == null) {
        errorMessage = 'Sign up failed. Try again.';
        return false;
      }

      // 2. Insert the ambassador row, retrying on referral_code collision
      const maxAttempts = 5;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        final code = await _generateUniqueReferralCode(name);
        try {
          await _supabase.from('ambassadors').insert({
            'auth_id': authUserId,
            'name': name,
            'email': email,
            'referral_code': code,
            'points_total': 0,
            // tier_id left null on purpose
          });
          return true; // success
        } on PostgrestException catch (e) {
          // 23505 = unique_violation. Retry with a new code.
          if (e.code == '23505' && attempt < maxAttempts) {
            continue;
          }
          errorMessage = e.message;
          return false;
        }
      }
      errorMessage = 'Could not generate a unique referral code. Try again.';
      return false;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      // Supabase renvoie un message spécifique si l'email n'est pas confirmé
      if (e.message.contains('Email not confirmed')) {
        errorMessage =
            "Votre adresse e-mail n'a pas encore été confirmée. Veuillez vérifier votre boîte de réception.";
      } else {
        errorMessage = "Identifiants invalides ou problème de connexion.";
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  // Future<bool> signIn({required String email, required String password}) async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();
  //   try {
  //     await _supabase.auth.signInWithPassword(email: email, password: password);
  //     return true;
  //   } on AuthException catch (e) {
  //     errorMessage = e.message;
  //     return false;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> sendPasswordResetEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Checks the DB for an existing referral_code before returning a candidate.
  Future<String> _generateUniqueReferralCode(String name) async {
    for (var i = 0; i < 5; i++) {
      final candidate = _buildCandidateCode(name);
      final existing = await _supabase
          .from('ambassadors')
          .select('id')
          .eq('referral_code', candidate)
          .maybeSingle();
      if (existing == null) return candidate;
    }
    // Fall back to a longer random code if we somehow keep colliding.
    return _buildCandidateCode(name, suffixLength: 6);
  }

  String _buildCandidateCode(String name, {int suffixLength = 4}) {
    final letters = name.replaceAll(' ', '').toUpperCase();
    final prefix = letters.substring(
      0,
      letters.length >= 4 ? 4 : letters.length,
    );
    final max = pow(10, suffixLength).toInt();
    final min = pow(10, suffixLength - 1).toInt();
    final rand = Random().nextInt(max - min) + min;
    return '$prefix$rand';
  }
}
