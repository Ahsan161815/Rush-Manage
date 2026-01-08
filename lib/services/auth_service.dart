import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/config/supabase_config.dart';
import 'package:myapp/models/industry.dart';
import 'package:myapp/services/supabase_service.dart';

class SignInResult {
  const SignInResult({
    required this.isVerified,
    required this.needsProfileSetup,
    this.emailForVerification,
  });

  final bool isVerified;
  final bool needsProfileSetup;
  final String? emailForVerification;
}

class DuplicateAccountException extends AuthException {
  const DuplicateAccountException()
    : super('An account already exists for this email.', statusCode: '409');
}

class AuthService {
  AuthService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final trimmedEmail = email.trim();
    final AuthResponse response;
    try {
      response = await _client.auth.signUp(
        email: trimmedEmail,
        password: password,
      );
      if (_isDuplicateAccountResponse(response)) {
        throw const DuplicateAccountException();
      }
    } on DuplicateAccountException {
      rethrow;
    } on AuthException catch (error) {
      if (_isDuplicateAccountError(error)) {
        throw const DuplicateAccountException();
      }
      rethrow;
    }

    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Registration failed');
    }

    final trimmedName = fullName?.trim();
    try {
      await _client.from('users').upsert({
        'id': user.id,
        'email': trimmedEmail,
        if (trimmedName != null && trimmedName.isNotEmpty)
          'full_name': trimmedName,
      });
      if (trimmedName != null && trimmedName.isNotEmpty) {
        await _setDisplayName(trimmedName);
      }
    } on PostgrestException catch (error) {
      // User creation succeeded even if profile persistence fails; log and continue.
      // ignore: avoid_print
      print('Failed to upsert user profile: ${error.message}');
    }
  }

  Future<SignInResult> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Login failed, please try again.');
    }

    final verified = await _isUserVerified(user);
    if (!verified) {
      final targetEmail = user.email ?? email.trim();
      if (targetEmail.isEmpty) {
        throw const AuthException('Unable to send verification email.');
      }
      await sendVerificationOtp(email: targetEmail);
      return SignInResult(
        isVerified: false,
        needsProfileSetup: false,
        emailForVerification: targetEmail,
      );
    }

    final needsProfileSetup = await _needsProfileSetup(user);
    return SignInResult(isVerified: true, needsProfileSetup: needsProfileSetup);
  }

  Future<SignInResult?> signInWithGoogle() async {
    StreamSubscription<AuthState>? authSubscription;
    Completer<User>? userCompleter;

    if (!kIsWeb) {
      final cachedUser = _client.auth.currentUser;
      if (cachedUser != null) {
        userCompleter = Completer<User>()..complete(cachedUser);
      } else {
        final pendingCompleter = Completer<User>();
        userCompleter = pendingCompleter;
        authSubscription = _client.auth.onAuthStateChange.listen((authState) {
          if (authState.event == AuthChangeEvent.signedIn) {
            final sessionUser =
                authState.session?.user ?? _client.auth.currentUser;
            if (sessionUser != null && !pendingCompleter.isCompleted) {
              pendingCompleter.complete(sessionUser);
            } else if (!pendingCompleter.isCompleted) {
              _client.auth
                  .getUser()
                  .then((response) {
                    final fetched = response.user;
                    if (fetched != null && !pendingCompleter.isCompleted) {
                      pendingCompleter.complete(fetched);
                    }
                  })
                  .catchError((error) {
                    if (!pendingCompleter.isCompleted) {
                      pendingCompleter.completeError(error);
                    }
                  });
            }
          }
        });
      }
    }

    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _oauthRedirectUrl,
        queryParams: const {'access_type': 'offline', 'prompt': 'consent'},
      );

      if (kIsWeb) {
        return null;
      }

      final user = await _awaitOAuthUser(userCompleter);
      final verified = await _isUserVerified(user);
      final needsProfileSetup = verified
          ? await _needsProfileSetup(user)
          : false;
      return SignInResult(
        isVerified: verified,
        needsProfileSetup: needsProfileSetup,
        emailForVerification: user.email,
      );
    } on AuthException catch (error) {
      final normalized = error.message.trim().toLowerCase();
      final isPendingRedirect =
          kIsWeb && normalized.contains('auth session missing');
      if (isPendingRedirect) {
        return null;
      }
      rethrow;
    } finally {
      await authSubscription?.cancel();
    }
  }

  Future<SignInResult?> resolveExistingSession() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    final verified = await _isUserVerified(user);
    final needsProfileSetup = verified ? await _needsProfileSetup(user) : false;
    return SignInResult(
      isVerified: verified,
      needsProfileSetup: needsProfileSetup,
      emailForVerification: user.email,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> sendPasswordResetEmail({required String email}) {
    return _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: SupabaseConfig.passwordResetRedirectUrl,
    );
  }

  Future<void> sendVerificationOtp({required String email}) {
    return _client.auth.resend(email: email.trim(), type: OtpType.signup);
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.signup,
    );

    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Unable to verify email at this time');
    }

    try {
      await _client
          .from('users')
          .update({'is_verified': true})
          .eq('id', user.id);
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('Failed to flag profile as verified: ${error.message}');
    }

    await _client.auth.updateUser(UserAttributes(data: {'is_verified': true}));
  }

  Future<bool> _isUserVerified(User user) async {
    final metadata = user.userMetadata;
    final metadataVerified =
        metadata is Map<String, dynamic> && metadata['is_verified'] == true;
    if (metadataVerified || user.emailConfirmedAt != null) {
      return true;
    }

    try {
      final result = await _client
          .from('users')
          .select('is_verified')
          .eq('id', user.id)
          .maybeSingle();
      if (result is Map<String, dynamic> && result['is_verified'] == true) {
        return true;
      }
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('Failed to check verification flag: ${error.message}');
    }
    return false;
  }

  Future<bool> _needsProfileSetup(User user) async {
    try {
      final result = await _client
          .from('users')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();
      if (result is Map<String, dynamic>) {
        final fullName = (result['full_name'] as String?)?.trim();
        return fullName == null || fullName.isEmpty;
      }
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('Failed to check profile completion: ${error.message}');
    }
    return true;
  }

  Future<User> _requireCurrentUser() async {
    final cached = _client.auth.currentUser;
    if (cached != null) {
      return cached;
    }
    final response = await _client.auth.getUser();
    final user = response.user;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }
    return user;
  }

  Future<User> _awaitOAuthUser(Completer<User>? completer) async {
    if (completer == null) {
      return _requireCurrentUser();
    }
    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw const AuthException(
          'Google sign-in is taking longer than expected. Please try again.',
        );
      },
    );
  }

  String get _oauthRedirectUrl {
    if (kIsWeb) {
      final uri = Uri.base;
      final sanitized = uri.replace(
        queryParameters: const {},
        fragment: '/login',
      );
      return sanitized.toString();
    }
    return SupabaseConfig.oauthRedirectUrl;
  }

  Future<void> completeProfile({
    required String fullName,
    required String avatarUrl,
    String? roleTitle,
    String? location,
    String? focusArea,
    IndustryKey? industry,
    String? phone,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not authenticated');
    }

    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      throw const AuthException('Please provide your full name');
    }

    final trimmedAvatar = avatarUrl.trim();
    if (trimmedAvatar.isEmpty) {
      throw const AuthException('Please upload a profile photo');
    }

    final updates = <String, dynamic>{
      'full_name': trimmedName,
      'avatar_url': trimmedAvatar,
      if (roleTitle != null && roleTitle.trim().isNotEmpty)
        'role_title': roleTitle.trim(),
      if (location != null && location.trim().isNotEmpty)
        'location': location.trim(),
      if (focusArea != null && focusArea.isNotEmpty) 'focus_area': focusArea,
    };
    if (phone != null) {
      final trimmedPhone = phone.trim();
      updates['phone'] = trimmedPhone.isEmpty ? null : trimmedPhone;
    }

    await _client.from('users').update(updates).eq('id', userId);
    if (industry != null) {
      await _upsertIndustryProfile(userId: userId, industry: industry);
    }
    await _setDisplayName(trimmedName);
  }

  Future<void> updatePassword({required String newPassword}) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> _setDisplayName(String displayName) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(data: {'display_name': displayName}),
      );
    } on AuthException catch (error) {
      // ignore: avoid_print
      print('Failed to update display name: ${error.message}');
    }
  }

  Future<void> _upsertIndustryProfile({
    required String userId,
    required IndustryKey industry,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = <String, dynamic>{
      'owner_id': userId,
      'industry': industry.storageValue,
      'is_reference': industry == IndustryKey.caterer,
      'activated_at': now,
      'updated_at': now,
    };

    try {
      await _client
          .from('user_industry_profiles')
          .upsert(payload, onConflict: 'owner_id');
    } on PostgrestException catch (error) {
      // ignore: avoid_print
      print('Failed to upsert industry profile: ${error.message}');
    }
  }

  bool _isDuplicateAccountError(AuthException error) {
    final statusCode = error.statusCode?.trim();
    if (statusCode == '409' || statusCode?.toLowerCase() == 'conflict') {
      return true;
    }
    final normalizedMessage = error.message.toLowerCase();
    return normalizedMessage.contains('already registered') ||
        normalizedMessage.contains('already exists');
  }

  bool _isDuplicateAccountResponse(AuthResponse response) {
    final identities = response.user?.identities;
    if (identities == null) {
      return false;
    }
    return identities.isEmpty;
  }
}
