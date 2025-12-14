import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/config/supabase_config.dart';
import 'package:myapp/services/supabase_service.dart';

class AuthService {
  AuthService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final trimmedEmail = email.trim();
    final response = await _client.auth.signUp(
      email: trimmedEmail,
      password: password,
    );

    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Registration failed');
    }

    await _client.from('users').upsert({
      'id': user.id,
      'email': trimmedEmail,
      'full_name': fullName.trim(),
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<void> sendPasswordResetEmail({required String email}) {
    return _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: SupabaseConfig.passwordResetRedirectUrl,
    );
  }

  Future<void> updatePassword({required String newPassword}) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
