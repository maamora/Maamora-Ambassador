import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../shared/navigation/app_routes.dart';

enum AmbassadorStatus {
  initial,
  unauthenticated,
  admin,
  pending,
  active,
  rejected,
  paused,
  unregistered,
}

class AuthState {
  final AmbassadorStatus status;
  final String? rejectionReason;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.status = AmbassadorStatus.initial,
    this.rejectionReason,
    this.isLoading = true,
    this.errorMessage,
  });

  AuthState copyWith({
    AmbassadorStatus? status,
    String? rejectionReason,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final _supabase = Supabase.instance.client;

  AuthNotifier() : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        state = state.copyWith(
          status: AmbassadorStatus.unauthenticated,
          isLoading: false,
        );
      } else {
        _checkUserStatus();
      }
    });
  }

  Future<void> _checkUserStatus() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = _supabase.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          status: AmbassadorStatus.unauthenticated,
          isLoading: false,
        );
        return;
      }

      // Check admin
      final adminRes = await _supabase
          .from('admins')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (adminRes != null) {
        state = state.copyWith(
          status: AmbassadorStatus.admin,
          isLoading: false,
        );
        return;
      }

      // Check ambassador
      final response = await _supabase.rpc('get_my_ambassador_status');
      
      String? statusStr;
      String? reason;

      if (response != null) {
        if (response is Map) {
          statusStr = response['status']?.toString();
          reason = response['rejection_reason']?.toString();
        } else if (response is String) {
          statusStr = response;
        } else if (response is List && response.isNotEmpty) {
          final first = response.first;
          if (first is Map) {
            statusStr = first['status']?.toString();
            reason = first['rejection_reason']?.toString();
          } else if (first is String) {
            statusStr = first;
          }
        }
      }

      if (statusStr != null) {
        AmbassadorStatus newStatus;
        switch (statusStr) {
          case 'pending':
            newStatus = AmbassadorStatus.pending;
            break;
          case 'active':
            newStatus = AmbassadorStatus.active;
            break;
          case 'rejected':
            newStatus = AmbassadorStatus.rejected;
            break;
          case 'paused':
            newStatus = AmbassadorStatus.paused;
            break;
          default:
            newStatus = AmbassadorStatus.unregistered;
        }

        state = state.copyWith(
          status: newStatus,
          rejectionReason: reason,
          isLoading: false,
        );
      } else {
        // Unregistered user or empty response
        state = state.copyWith(
          status: AmbassadorStatus.unregistered,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AmbassadorStatus.unregistered,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle({bool isRegister = false}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      if (kIsWeb) {
        // On Web, use Supabase's built-in OAuth flow which is much more stable
        // and avoids the popup blocker / missing ID token issues of google_sign_in_web.
        final String redirectPath = isRegister ? '/#${AppRoutes.register}' : '/';
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? '${Uri.base.origin}$redirectPath' : null,
          queryParams: {'prompt': 'select_account'},
        );
        // The page will redirect. Upon return, _init() will catch the auth state change.
      } else {
        // On Mobile, use the native Google Sign-In plugin
        final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
        
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
        );
        
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          state = state.copyWith(isLoading: false);
          return; // User canceled sign-in
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? accessToken = googleAuth.accessToken;
        final String? idToken = googleAuth.idToken;

        if (accessToken == null || idToken == null) {
          throw 'Missing Google Auth Token. Check your Web Client ID configuration.';
        }

        await _supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<bool> checkInviteCode(String code) async {
    try {
      final isValid = await _supabase.rpc('check_invite_code', params: {'p_code': code});
      return isValid == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerAmbassador({
    required String fullName,
    required String phone,
    required String city,
    required String inviteCode,
    String? referrerSlug,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _supabase.rpc('register_ambassador', params: {
        'p_full_name': fullName,
        'p_phone': phone,
        'p_city': city,
        'p_invite_code': inviteCode,
        'p_referrer_slug': referrerSlug,
      });
      await _checkUserStatus();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}
