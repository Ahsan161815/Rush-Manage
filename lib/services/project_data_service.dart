import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/common/models/collaborator_contact.dart';
import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/models/shared_file_record.dart';
import 'package:myapp/config/supabase_config.dart';
import 'package:myapp/models/project.dart';

class ProjectDataService {
  ProjectDataService(this._client)
    : _privilegedClient = SupabaseConfig.serviceRoleKey.isNotEmpty
          ? SupabaseClient(SupabaseConfig.url, SupabaseConfig.serviceRoleKey)
          : null;

  final SupabaseClient _client;
  final SupabaseClient? _privilegedClient;

  static const String _projectsTable = 'projects';
  static const String _messagesTable = 'project_messages';
  static const String _contactsTable = 'collaborator_contacts';
  static const String _invitationsTable = 'project_invitations';
  static const String _sharedFilesTable = 'shared_files';

  Future<List<Project>> fetchProjects(String ownerId) async {
    final response = await _client
        .from(_projectsTable)
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Project.fromJson)
        .toList(growable: false);
  }

  Future<Project> createProject(
    Project project, {
    required String ownerId,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = project.toJson()
      ..addAll({'owner_id': ownerId, 'created_at': now, 'updated_at': now});
    final record = await _client
        .from(_projectsTable)
        .insert(payload)
        .select()
        .single();
    return Project.fromJson(record);
  }

  Future<Project> updateProject(Project project) async {
    final payload = project.toJson()
      ..addAll({'updated_at': DateTime.now().toUtc().toIso8601String()});
    final record = await _client
        .from(_projectsTable)
        .update(payload)
        .eq('id', project.id)
        .select()
        .single();
    return Project.fromJson(record);
  }

  Future<void> deleteProject(String projectId) async {
    await _client.from(_projectsTable).delete().eq('id', projectId);
  }

  Future<void> updateProjectMembers({
    required String projectId,
    required List<Member> members,
  }) async {
    await _client
        .from(_projectsTable)
        .update({
          'members': members.map((member) => member.toJson()).toList(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', projectId);
  }

  Future<void> updateProjectMembersPrivileged({
    required String projectId,
    required List<Member> members,
  }) async {
    final admin = _privilegedClient;
    if (admin == null) {
      throw StateError('Privileged client unavailable');
    }
    await admin
        .from(_projectsTable)
        .update({
          'members': members.map((member) => member.toJson()).toList(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', projectId);
  }

  Future<void> updateProjectTasks({
    required String projectId,
    required List<Task> tasks,
    required int progress,
  }) async {
    await _client
        .from(_projectsTable)
        .update({
          'tasks': tasks.map((task) => task.toJson()).toList(),
          'progress': progress,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', projectId);
  }

  Future<List<Message>> fetchMessages(String projectId) async {
    final response = await _client
        .from(_messagesTable)
        .select()
        .eq('project_id', projectId)
        .order('sent_at');
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Message.fromJson)
        .toList(growable: false);
  }

  Future<Message> createMessage(
    String projectId,
    Message message, {
    required String ownerId,
  }) async {
    final payload = message.toJson()
      ..addAll({'project_id': projectId, 'owner_id': ownerId});
    final record = await _client
        .from(_messagesTable)
        .insert(payload)
        .select()
        .single();
    return Message.fromJson(record);
  }

  Future<Message> updateMessage(Message message) async {
    final record = await _client
        .from(_messagesTable)
        .update(message.toJson())
        .eq('id', message.id)
        .select()
        .single();
    return Message.fromJson(record);
  }

  Future<List<CollaboratorContact>> fetchContacts(String ownerId) async {
    final response = await _client
        .from(_contactsTable)
        .select()
        .eq('owner_id', ownerId)
        .order('name');
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(CollaboratorContact.fromJson)
        .toList(growable: false);
  }

  Future<List<Invitation>> fetchInvitations(String ownerId) async {
    final response = await _client
        .from(_invitationsTable)
        .select()
        .eq('owner_id', ownerId)
        .order('sent_at', ascending: false);
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Invitation.fromJson)
        .toList(growable: false);
  }

  Future<Invitation> createInvitation({
    required Invitation invitation,
    required String ownerId,
  }) async {
    final payload = invitation.toJson()..addAll({'owner_id': ownerId});
    final record = await _client
        .from(_invitationsTable)
        .insert(payload)
        .select()
        .single();
    return Invitation.fromJson(record);
  }

  Future<Invitation> updateInvitation(Invitation invitation) async {
    final record = await _client
        .from(_invitationsTable)
        .update(invitation.toJson())
        .eq('id', invitation.id)
        .select()
        .single();
    return Invitation.fromJson(record);
  }

  Future<List<Invitation>> updateInvitationRolesForInvitee({
    required String ownerId,
    required String inviteeEmail,
    required String role,
  }) async {
    final normalized = inviteeEmail.trim().toLowerCase();
    final now = DateTime.now().toUtc().toIso8601String();
    final response = await _client
        .from(_invitationsTable)
        .update({'role': role, 'updated_at': now})
        .eq('owner_id', ownerId)
        .ilike('invitee_email', normalized)
        .select();

    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Invitation.fromJson)
        .toList(growable: false);
  }

  Future<Invitation> updateInvitationPrivileged(
    Invitation invitation, {
    required String inviteeEmail,
  }) async {
    final admin = _privilegedClient;
    if (admin == null) {
      throw StateError('Privileged client unavailable');
    }
    final normalized = inviteeEmail.trim().toLowerCase();
    final record = await admin
        .from(_invitationsTable)
        .update(invitation.toJson())
        .eq('id', invitation.id)
        .ilike('invitee_email', normalized)
        .select()
        .single();
    return Invitation.fromJson(record);
  }

  Future<List<SharedFileRecord>> fetchSharedFiles(String ownerId) async {
    final response = await _client
        .from(_sharedFilesTable)
        .select()
        .eq('owner_id', ownerId)
        .order('uploaded_at', ascending: false);
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(SharedFileRecord.fromJson)
        .toList(growable: false);
  }

  Future<SharedFileRecord> createSharedFile({
    required SharedFileDraft draft,
    required String recordId,
    required String ownerId,
  }) async {
    final payload = draft.toInsertPayload(ownerId: ownerId, recordId: recordId);
    final record = await _client
        .from(_sharedFilesTable)
        .insert(payload)
        .select()
        .single();
    return SharedFileRecord.fromJson(record);
  }

  Future<void> deleteSharedFile(String id) async {
    await _client.from(_sharedFilesTable).delete().eq('id', id);
  }
}
