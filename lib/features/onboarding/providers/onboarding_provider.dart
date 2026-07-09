import 'package:flutter/foundation.dart';
// TODO(firebase): restore once the team's Firebase project is configured
// (flutterfire configure + firebase_options.dart) and Firebase.initializeApp()
// is called in main.dart. Until then, this provider fakes auth locally.
// import 'package:firebase_auth/firebase_auth.dart';

/// Handles form validation and auth calls for the onboarding flow
/// (login + sign up). Owned by Dev 1 — do not duplicate auth logic elsewhere;
/// other features should read the resulting Ambassador via
/// `core/services/ambassador_state_provider.dart`, not call Firebase directly.
///
/// MOCK MODE: real Firebase Auth calls are commented out below so the UI
/// can be built/tested without a configured Firebase project. signIn/signUp
/// currently just simulate a network delay and always succeed (unless you
/// use the special test emails below). Swap back in once backend is ready.
class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Mocked "current user" — just the email of whoever last signed in/up,
  /// or null if signed out. Replace with FirebaseAuth's User? later.
  String? _currentUserEmail;
  String? get currentUser => _currentUserEmail;

  /// Phone entered at sign-up. Firebase email/password auth has no phone
  /// field, so this is held here and should be written onto the Ambassador
  /// record (models/ambassador.dart) once that contract is finalized —
  /// same TODO as the referral code / tier defaults.
  String? _pendingPhone;
  String? get pendingPhone => _pendingPhone;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // Validation (unchanged — no Firebase dependency here)
  // ---------------------------------------------------------------------

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns an error string to show under the field, or null if valid.
  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email requis';
    if (!_emailRegex.hasMatch(email)) return 'Email invalide';
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Mot de passe requis';
    if (password.length < 6) return '6 caractères minimum';
    return null;
  }

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Nom requis';
    if (name.length < 2) return 'Nom trop court';
    return null;
  }

  static final _phoneRegex = RegExp(r'^(\+212|0)[5-7]\d{8}$');

  /// Accepts Moroccan mobile formats, e.g. +212612345678 or 0612345678.
  /// Spaces/dashes are stripped before checking.
  String? validatePhone(String? value) {
    final phone = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (phone.isEmpty) return 'Téléphone requis';
    if (!_phoneRegex.hasMatch(phone)) return 'Numéro invalide';
    return null;
  }

  // ---------------------------------------------------------------------
  // Auth actions — MOCKED (see class doc). Real Firebase calls are
  // commented out inline so this is easy to restore later.
  // ---------------------------------------------------------------------

  /// Signs an existing ambassador in. Returns true on success.
  Future<bool> signIn({required String email, required String password}) async {
    return _runMockAuthAction(
      email: email.trim(),
      password: password,
      // TODO(firebase): replace _runMockAuthAction(...) above with:
      // return _runAuthAction(
      //   () => _auth.signInWithEmailAndPassword(
      //     email: email.trim(),
      //     password: password,
      //   ),
      // );
    );
  }

  /// Creates a new ambassador account. Returns true on success.
  ///
  /// NOTE: this only creates the Firebase Auth user. Writing the
  /// corresponding `Ambassador` record (name, referral code, tier, etc.)
  /// happens in `core/services/` once the backend contract (models/ambassador.dart)
  /// is finalized with the team — see Definition of Done in the team doc.
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final success = await _runMockAuthAction(
      email: email.trim(),
      password: password,
    );
    if (success) {
      _pendingPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    }
    return success;
    // TODO(firebase): replace the block above with:
    // final success = await _runAuthAction(
    //   () => _auth.createUserWithEmailAndPassword(
    //     email: email.trim(),
    //     password: password,
    //   ),
    // );
    // if (success) {
    //   await _auth.currentUser?.updateDisplayName(name.trim());
    //   _pendingPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    // }
    // return success;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // TODO(firebase): replace with real call:
    // try {
    //   await _auth.sendPasswordResetEmail(email: email.trim());
    // } on FirebaseAuthException catch (e) {
    //   _errorMessage = _messageForCode(e.code);
    //   notifyListeners();
    // }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> signOut() async {
    _currentUserEmail = null;
    notifyListeners();
    // TODO(firebase): replace with: await _auth.signOut();
  }

  // ---------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------

  /// Fake auth: simulates network delay, then succeeds — unless the email
  /// is one of the reserved test addresses below, which lets you exercise
  /// the error-banner UI without a real backend.
  Future<bool> _runMockAuthAction({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    // Test hooks for exercising error states in the UI:
    //   test-error@maamora.app  -> generic error
    //   test-taken@maamora.app  -> "email already in use" style error
    if (email == 'test-error@maamora.app') {
      _isLoading = false;
      _errorMessage = 'Une erreur est survenue. Réessayez.';
      notifyListeners();
      return false;
    }
    if (email == 'test-taken@maamora.app') {
      _isLoading = false;
      _errorMessage = 'Cet email est déjà utilisé';
      notifyListeners();
      return false;
    }

    _currentUserEmail = email;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // TODO(firebase): restore this once FirebaseAuth is back —
  // Future<bool> _runAuthAction(Future<UserCredential> Function() action) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();
  //
  //   try {
  //     await action();
  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     _isLoading = false;
  //     _errorMessage = _messageForCode(e.code);
  //     notifyListeners();
  //     return false;
  //   } catch (_) {
  //     _isLoading = false;
  //     _errorMessage = 'Une erreur est survenue. Réessayez.';
  //     notifyListeners();
  //     return false;
  //   }
  // }

  // String _messageForCode(String code) {
  //   switch (code) {
  //     case 'invalid-email':
  //       return 'Email invalide';
  //     case 'user-disabled':
  //       return 'Ce compte est désactivé';
  //     case 'user-not-found':
  //       return 'Aucun compte avec cet email';
  //     case 'wrong-password':
  //     case 'invalid-credential':
  //       return 'Email ou mot de passe incorrect';
  //     case 'email-already-in-use':
  //       return 'Cet email est déjà utilisé';
  //     case 'weak-password':
  //       return 'Mot de passe trop faible';
  //     case 'network-request-failed':
  //       return 'Vérifiez votre connexion internet';
  //     default:
  //       return 'Une erreur est survenue. Réessayez.';
  //   }
  // }
}
