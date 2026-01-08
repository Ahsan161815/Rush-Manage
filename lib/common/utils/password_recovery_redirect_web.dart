import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as html;

Future<bool> handlePasswordRecoveryRedirect(SupabaseClient client) async {
  final uri = Uri.parse(html.window.location.href);
  final params = _collectRedirectParams(uri);
  if (params.isEmpty) {
    return false;
  }

  final type = params['type'];
  final shouldOpenReset = type == 'recovery';
  final code = params['code'];
  final refreshToken = params['refresh_token'];

  final hasSessionParams =
      code != null || (refreshToken != null && refreshToken.isNotEmpty);
  if (!hasSessionParams) {
    return false;
  }

  try {
    if (code != null && code.isNotEmpty) {
      await client.auth.exchangeCodeForSession(code);
    } else if (refreshToken != null && refreshToken.isNotEmpty) {
      await client.auth.setSession(refreshToken);
    }
    _clearSensitiveParams(
      uri: uri,
      fragmentOverride: shouldOpenReset ? '/reset-password' : _defaultFragment(uri),
    );
    return shouldOpenReset;
  } catch (_) {
    // Swallow errors: fall back to regular flow so the user sees the login UI.
  }

  return false;
}

String _defaultFragment(Uri uri) {
  final fragment = uri.fragment;
  if (fragment.isEmpty) {
    return '/login';
  }
  final queryIndex = fragment.indexOf('?');
  if (queryIndex == -1) {
    return fragment.startsWith('/') ? fragment : '/$fragment';
  }
  final baseFragment = fragment.substring(0, queryIndex);
  return baseFragment.isEmpty ? '/login' : baseFragment;
}

Map<String, String> _collectRedirectParams(Uri uri) {
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

void _clearSensitiveParams({required Uri uri, required String fragmentOverride}) {
  final sanitized = uri.replace(queryParameters: const {}, fragment: fragmentOverride);
  html.window.history.replaceState(null, '', sanitized.toString());
}
