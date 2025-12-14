import 'package:supabase_flutter/supabase_flutter.dart';

import 'password_recovery_redirect_stub.dart'
    if (dart.library.html) 'password_recovery_redirect_web.dart'
    as handler;

Future<bool> handlePasswordRecoveryRedirect(SupabaseClient client) {
  return handler.handlePasswordRecoveryRedirect(client);
}
