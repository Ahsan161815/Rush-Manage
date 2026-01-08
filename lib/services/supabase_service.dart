import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/config/supabase_config.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => _client;
  late final SupabaseClient _client;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
        detectSessionInUri: true,
      ),
    );
    _client = Supabase.instance.client;
    _initialized = true;
  }
}
