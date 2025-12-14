import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as html;

Future<bool> handlePasswordRecoveryRedirect(SupabaseClient client) async {
  final params = _collectRedirectParams();
  if (params.isEmpty) {
    return false;
  }

  final type = params['type'];
  final code = params['code'];
  final accessToken = params['access_token'];
  final refreshToken = params['refresh_token'];

  try {
    if (code != null) {
      await client.auth.exchangeCodeForSession(code);
      _clearSensitiveParams();
      return type == 'recovery';
    }

    if (accessToken != null && refreshToken != null) {
      await client.auth.setSession(refreshToken);
      _clearSensitiveParams();
      return type == 'recovery';
    }
  } catch (_) {
    // Swallow errors: fall back to regular flow so the user sees the login UI.
  }

  return false;
}

Map<String, String> _collectRedirectParams() {
  final uri = Uri.parse(html.window.location.href);
  final params = <String, String>{...uri.queryParameters};
  final fragment = uri.fragment;
  if (fragment.isEmpty) {
    return params;
  }

  final queryPortion = _extractQueryFromFragment(fragment);
  if (queryPortion != null && queryPortion.isNotEmpty) {
    params.addAll(Uri.splitQueryString(queryPortion));
  }
  return params;
}

String? _extractQueryFromFragment(String fragment) {
  var working = fragment;
  if (working.startsWith('/')) {
    final queryIndex = working.indexOf('?');
    if (queryIndex == -1) {
      return null;
    }
    working = working.substring(queryIndex + 1);
  }
  if (working.isEmpty) {
    return null;
  }
  return working;
}

void _clearSensitiveParams() {
  final location = html.window.location;
  final uri = Uri.parse(location.href);
  final sanitized = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    fragment: '/reset-password',
  );
  html.window.history.replaceState(null, '', sanitized.toString());
}
