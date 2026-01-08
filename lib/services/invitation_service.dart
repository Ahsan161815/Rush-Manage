import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/config/supabase_config.dart';

class InvitationService {
  InvitationService(SupabaseClient client)
    : _client = client,
      _privilegedClient = SupabaseConfig.serviceRoleKey.isNotEmpty
          ? SupabaseClient(SupabaseConfig.url, SupabaseConfig.serviceRoleKey)
          : null;

  final SupabaseClient _client;
  final SupabaseClient? _privilegedClient;

  Future<bool> emailHasAccount(String email) async {
    final admin = _privilegedClient;
    if (admin == null) {
      return false;
    }
    final normalized = email.trim().toLowerCase();
    final response = await admin
        .from('users')
        .select('id')
        .ilike('email', normalized)
        .maybeSingle();
    return response is Map<String, dynamic>;
  }

  Future<List<Invitation>> fetchInvitationsForEmail(String email) async {
    final admin = _privilegedClient;
    if (admin == null) {
      return const [];
    }
    final normalized = email.trim().toLowerCase();
    final response = await admin
        .from('project_invitations')
        .select()
        .ilike('invitee_email', normalized)
        .eq('status', 'pending')
        .order('sent_at', ascending: false);
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Invitation.fromJson)
        .toList(growable: false);
  }

  Future<void> sendInviteEmail(Invitation invitation) async {
    final inviterName = _resolveInviterName(_client.auth.currentUser);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (SupabaseConfig.inviteEmailSecret.isNotEmpty)
        'x-invite-secret': SupabaseConfig.inviteEmailSecret,
    };

    final payload = {
      'to': invitation.inviteeEmail,
      'invitee_name': invitation.inviteeName,
      'inviter_name': inviterName,
      'project_name': invitation.projectName,
      'role': invitation.role,
      'invite_link': _buildInviteLink(invitation).toString(),
      'message': invitation.message,
      'app_store_url': SupabaseConfig.inviteAppStoreUrl,
      'play_store_url': SupabaseConfig.invitePlayStoreUrl,
    };

    try {
      await _client.functions.invoke(
        'invite-email',
        headers: headers,
        body: jsonEncode(payload),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('invite-email invocation failed: $error');
        debugPrint(stackTrace.toString());
      }
      rethrow;
    }
  }

  String _resolveInviterName(User? user) {
    if (user == null) {
      return 'Rush Manage workspace';
    }
    final metadata = user.userMetadata;
    final displayName = metadata is Map<String, dynamic>
        ? (metadata['display_name'] as String? ??
              metadata['full_name'] as String?)
        : null;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    return user.email ?? 'Rush Manage workspace';
  }

  Uri _buildInviteLink(Invitation invitation) {
    final base = SupabaseConfig.inviteLandingUrl;
    final encodedEmail = Uri.encodeComponent(invitation.inviteeEmail);
    final encodedProject = Uri.encodeComponent(invitation.projectName);
    return Uri.parse('$base?email=$encodedEmail&project=$encodedProject');
  }
}
