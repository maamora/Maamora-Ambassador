// features/onboarding/providers/onboarding_provider.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_client_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OnboardingProvider extends ChangeNotifier {
  final _supabase = SupabaseClientService.client;

  static String get _googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  static String get _googleIosClientId =>
      dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '';

  bool isLoading = false; // signIn / signUp email+mdp
  bool isGoogleLoading = false; // flux Google, indépendant du reste
  bool isResetLoading = false; // envoi de l'email de réinitialisation
  bool isUpdatingPassword = false; // confirmation du nouveau mot de passe
  String? errorMessage;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  // UI State for password visibility
  bool obscurePassword = true;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    _safeNotify();
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

  String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != originalPassword) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le code est requis';
    if (value.trim().length < 6) return 'Le code doit contenir 6 chiffres';
    return null;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();
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
      _safeNotify();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    _safeNotify();
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
      _safeNotify();
    }
  }

  Future<bool> signInWithGoogle() async {
    isGoogleLoading = true;
    errorMessage = null;
    _safeNotify();

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: (!kIsWeb && Platform.isIOS) ? _googleIosClientId : null,
        serverClientId: _googleWebClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Impossible de récupérer le jeton ID de Google.');
      }

      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final authUser = response.user;
      if (authUser == null) {
        errorMessage = "L'authentification Google a échoué auprès de Supabase.";
        return false;
      }

      final existingAmbassador = await _supabase
          .from('ambassadors')
          .select('id')
          .eq('auth_id', authUser.id)
          .maybeSingle();

      if (existingAmbassador == null) {
        final name =
            authUser.userMetadata?['full_name'] ??
            googleUser.displayName ??
            'Ambassadeur';
        final email = authUser.email ?? googleUser.email;

        const maxAttempts = 5;
        bool insertSuccess = false;

        for (var attempt = 1; attempt <= maxAttempts; attempt++) {
          final code = await _generateUniqueReferralCode(name);
          try {
            await _supabase.from('ambassadors').insert({
              'auth_id': authUser.id,
              'name': name,
              'email': email,
              'referral_code': code,
              'points_total': 0,
            });
            insertSuccess = true;
            break;
          } on PostgrestException catch (e) {
            if (e.code == '23505' && attempt < maxAttempts) continue;
            errorMessage = e.message;
            return false;
          }
        }

        if (!insertSuccess) {
          errorMessage = 'Impossible de générer un code de parrainage unique.';
          return false;
        }
      }
      return true;
    } catch (e) {
      errorMessage = "La connexion avec Google a échoué. Veuillez réessayer.";
      return false;
    } finally {
      isGoogleLoading = false;
      _safeNotify();
    }
  }

  // Future<bool> signInWithGoogle() async {
  //   isGoogleLoading = true;
  //   errorMessage = null;
  //   _safeNotify();

  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn(
  //       clientId: (!kIsWeb && Platform.isIOS) ? _googleIosClientId : null,
  //       // Obligatoire pour obtenir l'idToken requis par Supabase
  //       serverClientId: _googleWebClientId,
  //     );

  //     // 1. Déclencher le flux de sélection du compte Google
  //     final googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // L'utilisateur a annulé la connexion
  //       return false;
  //     }

  //     // 2. Récupérer les jetons d'authentification
  //     final googleAuth = await googleUser.authentication;
  //     final accessToken = googleAuth.accessToken;
  //     final idToken = googleAuth.idToken;

  //     if (idToken == null) {
  //       throw Exception('Impossible de récupérer le jeton ID de Google.');
  //     }

  //     // 3. Se connecter à Supabase avec le jeton d'identité Google
  //     final AuthResponse response = await _supabase.auth.signInWithIdToken(
  //       provider: OAuthProvider.google,
  //       idToken: idToken,
  //       accessToken: accessToken,
  //     );

  //     final authUser = response.user;
  //     if (authUser == null) {
  //       errorMessage = "L'authentification Google a échoué auprès de Supabase.";
  //       return false;
  //     }

  //     // 4. CRUCIAL POUR LE SIGN-UP : Vérifier si le profil dans 'ambassadors' existe
  //     final existingAmbassador = await _supabase
  //         .from('ambassadors')
  //         .select('id')
  //         .eq('auth_id', authUser.id)
  //         .maybeSingle();

  //     // Si le profil n'existe pas, c'est un Sign-Up -> On crée sa ligne
  //     if (existingAmbassador == null) {
  //       final name =
  //           authUser.userMetadata?['full_name'] ??
  //           googleUser.displayName ??
  //           'Ambassadeur';
  //       final email = authUser.email ?? googleUser.email;

  //       const maxAttempts = 5;
  //       bool insertSuccess = false;

  //       for (var attempt = 1; attempt <= maxAttempts; attempt++) {
  //         final code = await _generateUniqueReferralCode(name);
  //         try {
  //           await _supabase.from('ambassadors').insert({
  //             'auth_id': authUser.id,
  //             'name': name,
  //             'email': email,
  //             'referral_code': code,
  //             'points_total': 0,
  //           });
  //           insertSuccess = true;
  //           break;
  //         } on PostgrestException catch (e) {
  //           // Gestion de la collision du referral_code (unique_violation)
  //           if (e.code == '23505' && attempt < maxAttempts) {
  //             continue;
  //           }
  //           errorMessage = e.message;
  //           return false;
  //         }
  //       }

  //       if (!insertSuccess) {
  //         errorMessage = 'Impossible de générer un code de parrainage unique.';
  //         return false;
  //       }
  //     }

  //     return true; // Connexion ou Inscription réussie !
  //   } on AuthException catch (e) {
  //     errorMessage = e.message;
  //     return false;
  //   } on PostgrestException catch (e) {
  //     errorMessage = e.message;
  //     return false;
  //   } catch (e) {
  //     errorMessage = "La connexion avec Google a échoué. Veuillez réessayer.";
  //     return false;
  //   } finally {
  //     isGoogleLoading = false;
  //     _safeNotify();
  //   }
  // }

  Future<bool> sendPasswordResetEmail(String email) async {
    isResetLoading = true;
    errorMessage = null;
    _safeNotify();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isResetLoading = false;
      _safeNotify();
    }
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    isUpdatingPassword = true;
    errorMessage = null;
    _safeNotify();
    try {
      await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isUpdatingPassword = false;
      _safeNotify();
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

// // features/onboarding/providers/onboarding_provider.dart
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'dart:math';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../core/services/supabase_client_service.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class OnboardingProvider extends ChangeNotifier {
//   final _supabase = SupabaseClientService.client;
//   bool isLoading = false;
//   String? errorMessage;

//   // UI State for password visibility
//   bool obscurePassword = true;

//   void toggleObscurePassword() {
//     obscurePassword = !obscurePassword;
//     notifyListeners();
//   }

//   // Form Validators
//   String? validateName(String? value) {
//     if (value == null || value.trim().isEmpty)
//       return 'Le nom complet est requis';
//     return null;
//   }

//   String? validateEmail(String? value) {
//     if (value == null || value.trim().isEmpty) return 'L\'email est requis';
//     if (!value.contains('@')) return 'Veuillez entrer une adresse email valide';
//     return null;
//   }

//   String? validatePassword(String? value) {
//     if (value == null || value.length < 6) {
//       return 'Le mot de passe doit contenir au moins 6 caractères';
//     }
//     return null;
//   }

//   Future<bool> signUp({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();
//     try {
//       // 1. Create the auth user
//       final authResponse = await _supabase.auth.signUp(
//         email: email,
//         password: password,
//       );
//       final authUserId = authResponse.user?.id;
//       if (authUserId == null) {
//         errorMessage = 'Sign up failed. Try again.';
//         return false;
//       }

//       // 2. Insert the ambassador row, retrying on referral_code collision
//       const maxAttempts = 5;
//       for (var attempt = 1; attempt <= maxAttempts; attempt++) {
//         final code = await _generateUniqueReferralCode(name);
//         try {
//           await _supabase.from('ambassadors').insert({
//             'auth_id': authUserId,
//             'name': name,
//             'email': email,
//             'referral_code': code,
//             'points_total': 0,
//             // tier_id left null on purpose
//           });
//           return true; // success
//         } on PostgrestException catch (e) {
//           // 23505 = unique_violation. Retry with a new code.
//           if (e.code == '23505' && attempt < maxAttempts) {
//             continue;
//           }
//           errorMessage = e.message;
//           return false;
//         }
//       }
//       errorMessage = 'Could not generate a unique referral code. Try again.';
//       return false;
//     } on AuthException catch (e) {
//       errorMessage = e.message;
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> signIn({required String email, required String password}) async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();
//     try {
//       await _supabase.auth.signInWithPassword(email: email, password: password);
//       return true;
//     } on AuthException catch (e) {
//       // Supabase renvoie un message spécifique si l'email n'est pas confirmé
//       if (e.message.contains('Email not confirmed')) {
//         errorMessage =
//             "Votre adresse e-mail n'a pas encore été confirmée. Veuillez vérifier votre boîte de réception.";
//       } else {
//         errorMessage = "Identifiants invalides ou problème de connexion.";
//       }
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> signInWithGoogle() async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();

//     try {
//       // 1. Utilisez les ID générés sur Google Cloud Console
//       const webClientId = 'VOTRE_CLIENT_ID_WEB.apps.googleusercontent.com';
//       const iosClientId =
//           'VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com'; // optionnel si pas d'iOS

//       final GoogleSignIn googleSignIn = GoogleSignIn(
//         clientId: Platform.isIOS ? iosClientId : null,
//         serverClientId:
//             webClientId, // Obligatoire pour obtenir l'idToken requis par Supabase
//       );

//       // 2. Déclencher le flux de sélection du compte Google
//       final googleUser = await googleSignIn.signIn();
//       if (googleUser == null) {
//         // L'utilisateur a annulé la connexion
//         isLoading = false;
//         notifyListeners();
//         return false;
//       }

//       // 3. Récupérer les jetons d'authentification
//       final googleAuth = await googleUser.authentication;
//       final accessToken = googleAuth.accessToken;
//       final idToken = googleAuth.idToken;

//       if (idToken == null) {
//         throw Exception('Impossible de récupérer le jeton ID de Google.');
//       }

//       // 4. Se connecter à Supabase avec le jeton d'identité Google
//       final AuthResponse response = await _supabase.auth.signInWithIdToken(
//         provider: OAuthProvider.google,
//         idToken: idToken,
//         accessToken: accessToken,
//       );

//       final authUser = response.user;
//       if (authUser == null) {
//         errorMessage = "L'authentification Google a échoué auprès de Supabase.";
//         return false;
//       }

//       // 5. CRUCIAL POUR LE SIGN-UP : Vérifier si le profil dans 'ambassadors' existe
//       final existingAmbassador = await _supabase
//           .from('ambassadors')
//           .select('id')
//           .eq('auth_id', authUser.id)
//           .maybeSingle();

//       // Si le profil n'existe pas, c'est un Sign-Up -> On crée sa ligne
//       if (existingAmbassador == null) {
//         final name =
//             authUser.userMetadata?['full_name'] ??
//             googleUser.displayName ??
//             'Ambassadeur';
//         final email = authUser.email ?? googleUser.email;

//         const maxAttempts = 5;
//         bool insertSuccess = false;

//         for (var attempt = 1; attempt <= maxAttempts; attempt++) {
//           final code = await _generateUniqueReferralCode(name);
//           try {
//             await _supabase.from('ambassadors').insert({
//               'auth_id': authUser.id,
//               'name': name,
//               'email': email,
//               'referral_code': code,
//               'points_total': 0,
//             });
//             insertSuccess = true;
//             break;
//           } on PostgrestException catch (e) {
//             // Gestion de la collision du referral_code (code d'erreur unique_violation)
//             if (e.code == '23505' && attempt < maxAttempts) {
//               continue;
//             }
//             errorMessage = e.message;
//             return false;
//           }
//         }

//         if (!insertSuccess) {
//           errorMessage = 'Impossible de générer un code de parrainage unique.';
//           return false;
//         }
//       }

//       return true; // Connexion ou Inscription réussie !
//     } catch (e) {
//       errorMessage = e.toString();
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> sendPasswordResetEmail(String email) async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();
//     try {
//       await _supabase.auth.resetPasswordForEmail(email);
//       return true;
//     } on AuthException catch (e) {
//       errorMessage = e.message;
//       return false;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Checks the DB for an existing referral_code before returning a candidate.
//   Future<String> _generateUniqueReferralCode(String name) async {
//     for (var i = 0; i < 5; i++) {
//       final candidate = _buildCandidateCode(name);
//       final existing = await _supabase
//           .from('ambassadors')
//           .select('id')
//           .eq('referral_code', candidate)
//           .maybeSingle();
//       if (existing == null) return candidate;
//     }
//     // Fall back to a longer random code if we somehow keep colliding.
//     return _buildCandidateCode(name, suffixLength: 6);
//   }

//   String _buildCandidateCode(String name, {int suffixLength = 4}) {
//     final letters = name.replaceAll(' ', '').toUpperCase();
//     final prefix = letters.substring(
//       0,
//       letters.length >= 4 ? 4 : letters.length,
//     );
//     final max = pow(10, suffixLength).toInt();
//     final min = pow(10, suffixLength - 1).toInt();
//     final rand = Random().nextInt(max - min) + min;
//     return '$prefix$rand';
//   }
// }
