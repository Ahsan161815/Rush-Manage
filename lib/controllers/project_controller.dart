import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/common/models/collaborator_contact.dart';
import 'package:myapp/common/models/contact_detail_args.dart';
import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/common/models/shared_file_record.dart';
import 'package:myapp/models/industry.dart';
import 'package:myapp/models/project.dart';
import 'package:myapp/services/industry_module_service.dart';
import 'package:myapp/services/invitation_service.dart';
import 'package:myapp/services/project_data_service.dart';

class ProjectController extends ChangeNotifier {
  ProjectController({
    required SupabaseClient client,
    ProjectDataService? dataService,
    IndustryModuleService? industryService,
    InvitationService? invitationService,
  }) : _client = client,
       _dataService = dataService ?? ProjectDataService(client),
       _industryService = industryService ?? IndustryModuleService(client),
       _invitationService = invitationService ?? InvitationService(client);

  final SupabaseClient _client;
  final ProjectDataService _dataService;
  final IndustryModuleService _industryService;
  final InvitationService _invitationService;

  final List<Project> _projects = [];
  final Map<String, List<Message>> _projectMessages = {};
  final List<CollaboratorContact> _contacts = [];
  final List<Invitation> _invitations = [];
  final List<SharedFileRecord> _sharedFiles = [];
  final Set<String> _pendingMessageFetches = <String>{};
  final Map<String, ProjectIndustryExtension> _industryExtensions = {};
  IndustryProfile _industryProfile = const IndustryProfile.core();

  bool _hasInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentUserId => _client.auth.currentUser?.id;
  String? get currentUserEmail => _client.auth.currentUser?.email;
  IndustryProfile get industryProfile => _industryProfile;
  bool get isCatererWorkspace =>
      _industryProfile.industry == IndustryKey.caterer;

  ProjectIndustryExtension? industryExtensionFor(String projectId) =>
      _industryExtensions[projectId];

  CatererProjectExtension? catererExtensionFor(String projectId) {
    final extension = _industryExtensions[projectId];
    return extension is CatererProjectExtension ? extension : null;
  }

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    if (_client.auth.currentUser?.id == null) {
      return;
    }
    _hasInitialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    final ownerId = _requireUserId();
    _setLoading(true);
    try {
      final projects = await _dataService.fetchProjects(ownerId);
      final contacts = await _dataService.fetchContacts(ownerId);
      final invitations = await _dataService.fetchInvitations(ownerId);
      final sharedFiles = await _dataService.fetchSharedFiles(ownerId);

      _projects
        ..clear()
        ..addAll(projects);
      _contacts
        ..clear()
        ..addAll(contacts);
      _invitations
        ..clear()
        ..addAll(invitations);
      _sharedFiles
        ..clear()
        ..addAll(sharedFiles);
      _sortSharedFiles();

      _projectMessages.clear();
      if (projects.isNotEmpty) {
        final messagePairs = await Future.wait(
          projects.map(
            (project) async => MapEntry(
              project.id,
              await _dataService.fetchMessages(project.id),
            ),
          ),
        );
        _projectMessages.addEntries(messagePairs);
      }

      await _syncIndustryContext(ownerId, projects);

      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      _errorMessage = 'Unable to sync workspace data';
      _logError('refresh', error, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  List<Project> get projects => List.unmodifiable(_projects);
  List<CollaboratorContact> get contacts => List.unmodifiable(_contacts);
  List<Invitation> get invitations => List.unmodifiable(_invitations);
  List<SharedFileRecord> get sharedFiles => List.unmodifiable(_sharedFiles);

  Future<void> updateCollaboratorRole({
    required String inviteeEmail,
    required String role,
  }) async {
    final normalized = inviteeEmail.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(inviteeEmail, 'inviteeEmail', 'Email required');
    }

    final ownerId = _requireUserId();

    final matches = <(int, Invitation)>[];
    for (var i = 0; i < _invitations.length; i++) {
      if (_invitations[i].inviteeEmail.trim().toLowerCase() == normalized) {
        matches.add((i, _invitations[i]));
      }
    }
    if (matches.isEmpty) {
      return;
    }

    final now = DateTime.now();
    for (final (index, original) in matches) {
      _invitations[index] = original.copyWith(role: role, updatedAt: now);
    }
    notifyListeners();

    try {
      final updated = await _dataService.updateInvitationRolesForInvitee(
        ownerId: ownerId,
        inviteeEmail: normalized,
        role: role,
      );
      if (updated.isNotEmpty) {
        for (final invitation in updated) {
          _replaceInvitation(invitation);
        }
      }
      // Also update existing project members that match the invitee email
      // so role changes persist for already-added collaborators.
      final originals = <int, Project>{};
      CollaboratorContact? matchedContact;
      try {
        matchedContact = _contacts.firstWhere(
          (c) => c.email.trim().toLowerCase() == normalized,
        );
      } catch (_) {
        matchedContact = null;
      }
      if (matchedContact != null) {
        final contact = matchedContact;
        for (var i = 0; i < _projects.length; i++) {
          final project = _projects[i];
          var changed = false;
          final newMembers = project.members
              .map((m) {
                final contactId = m.contactId;
                if ((contactId != null && contactId == contact.id) ||
                    m.id == contact.id ||
                    (contact.email.isNotEmpty &&
                        (m.name.trim().toLowerCase() ==
                            contact.name.trim().toLowerCase()))) {
                  changed = true;
                  return m.copyWith(role: role);
                }
                return m;
              })
              .toList(growable: false);
          if (changed) {
            originals[i] = project;
            _projects[i] = project.copyWith(members: newMembers);
          }
        }
      }
      if (originals.isNotEmpty) {
        notifyListeners();
        try {
          await Future.wait(
            originals.keys.map((i) {
              final proj = _projects[i];
              return _dataService.updateProjectMembers(
                projectId: proj.id,
                members: proj.members,
              );
            }),
          );
        } catch (error, stackTrace) {
          // rollback to originals
          for (final entry in originals.entries) {
            _projects[entry.key] = entry.value;
          }
          notifyListeners();
          _logError('updateCollaboratorRole', error, stackTrace);
          rethrow;
        }
      }
      notifyListeners();
    } catch (error, stackTrace) {
      for (final (index, original) in matches) {
        _invitations[index] = original;
      }
      notifyListeners();
      _logError('updateCollaboratorRole', error, stackTrace);
      rethrow;
    }
  }

  Future<void> reloadSharedFiles() async {
    final ownerId = _requireUserId();
    try {
      final records = await _dataService.fetchSharedFiles(ownerId);
      _sharedFiles
        ..clear()
        ..addAll(records);
      _sortSharedFiles();
      notifyListeners();
    } catch (error, stackTrace) {
      _logError('reloadSharedFiles', error, stackTrace);
      rethrow;
    }
  }

  Future<SharedFileRecord?> saveSharedFile(SharedFileDraft draft) async {
    if (draft.fileUrl.trim().isEmpty) {
      return null;
    }
    final ownerId = _requireUserId();
    final recordId = (draft.id != null && draft.id!.trim().isNotEmpty)
        ? draft.id!.trim()
        : _generateSharedFileId();
    try {
      final created = await _dataService.createSharedFile(
        draft: draft,
        recordId: recordId,
        ownerId: ownerId,
      );
      _insertOrReplaceSharedFile(created);
      notifyListeners();
      return created;
    } catch (error, stackTrace) {
      _logError('saveSharedFile', error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSharedFile(String fileId) async {
    final index = _sharedFiles.indexWhere((file) => file.id == fileId);
    if (index == -1) {
      return;
    }
    final removed = _sharedFiles.removeAt(index);
    notifyListeners();
    try {
      await _dataService.deleteSharedFile(fileId);
    } catch (error, stackTrace) {
      _sharedFiles.insert(index, removed);
      notifyListeners();
      _logError('deleteSharedFile', error, stackTrace);
      rethrow;
    }
  }

  Future<bool> emailHasRegisteredUser(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty) {
      return false;
    }
    try {
      return await _invitationService.emailHasAccount(normalized);
    } catch (error, stackTrace) {
      _logError('emailHasRegisteredUser', error, stackTrace);
      return false;
    }
  }

  Future<bool> loadInvitationsForEmail(String email) async {
    final normalized = email.trim();
    if (normalized.isEmpty) {
      return false;
    }
    try {
      final invites = await _invitationService.fetchInvitationsForEmail(
        normalized,
      );
      _invitations
        ..clear()
        ..addAll(invites);
      notifyListeners();
      return invites.isNotEmpty;
    } catch (error, stackTrace) {
      _logError('loadInvitationsForEmail', error, stackTrace);
      return false;
    }
  }

  CollaboratorContact? contactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (_) {
      return null;
    }
  }

  CollaboratorContact? contactByName(String name) {
    final normalized = name.trim().toLowerCase();
    try {
      return _contacts.firstWhere(
        (contact) => contact.name.trim().toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  CollaboratorContact? contactForMember(Member member) {
    if (member.contactId != null) {
      final contact = contactById(member.contactId!);
      if (contact != null) {
        return contact;
      }
    }
    return contactByName(member.name);
  }

  ContactDetailArgs buildContactDetailArgs({
    CollaboratorContact? contact,
    Member? member,
    Project? currentProject,
  }) {
    final resolvedContact =
        contact ?? (member != null ? contactForMember(member) : null);
    final displayName = resolvedContact?.name ?? member?.name ?? 'Collaborator';
    final title = resolvedContact?.profession ?? 'Contributor';
    final projects = <ContactProjectSummary>[];

    if (currentProject != null) {
      projects.add(
        ContactProjectSummary(
          id: currentProject.id,
          name: currentProject.name,
          role: title,
          statusLabel: _statusLabel(currentProject.status),
        ),
      );
    }

    final previousProjectName = resolvedContact?.lastProject;
    final shouldShowLastProject =
        previousProjectName != null &&
        (currentProject == null || currentProject.name != previousProjectName);
    if (shouldShowLastProject) {
      projects.add(
        ContactProjectSummary(
          id: 'last-$previousProjectName',
          name: previousProjectName,
          role: 'Recent project',
          statusLabel: 'Completed',
        ),
      );
    }

    return ContactDetailArgs(
      contactId:
          resolvedContact?.id ??
          member?.id ??
          'contact-${displayName.hashCode}',
      name: displayName,
      title: title,
      category: ContactCategory.collaborator,
      email: resolvedContact?.email,
      phone: resolvedContact?.phone,
      location: resolvedContact?.location,
      note: resolvedContact?.lastProject,
      tags: resolvedContact?.tags ?? const [],
      projects: projects,
    );
  }

  ContactDetailArgs? contactDetailById(String id, {Project? currentProject}) {
    final contact = contactById(id);
    if (contact == null) {
      return null;
    }
    return buildContactDetailArgs(
      contact: contact,
      currentProject: currentProject,
    );
  }

  Project? getById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Project> addProject(
    Project project, {
    ProjectIndustryExtension? extension,
  }) async {
    final ownerId = _requireUserId();
    final sanitized = project.copyWith(
      progress: _calculateProgress(project.tasks),
    );
    try {
      final created = await _dataService.createProject(
        sanitized,
        ownerId: ownerId,
      );
      _projects.add(created);
      await _persistIndustryExtension(ownerId, created.id, extension);
      notifyListeners();
      _ensureMessagesLoaded(created.id);
      return created;
    } catch (error, stackTrace) {
      _logError('addProject', error, stackTrace);
      rethrow;
    }
  }

  Future<Project?> updateProject(Project updated) async {
    final idx = _projects.indexWhere((p) => p.id == updated.id);
    if (idx == -1) {
      return null;
    }
    try {
      final saved = await _dataService.updateProject(updated);
      _projects[idx] = saved;
      notifyListeners();
      return saved;
    } catch (error, stackTrace) {
      _logError('updateProject', error, stackTrace);
      rethrow;
    }
  }

  Future<void> removeProject(String id) async {
    final index = _projects.indexWhere((project) => project.id == id);
    if (index == -1) {
      return;
    }
    final removed = _projects.removeAt(index);
    _projectMessages.remove(id);
    notifyListeners();
    try {
      await _dataService.deleteProject(id);
    } catch (error, stackTrace) {
      _projects.insert(index, removed);
      notifyListeners();
      _logError('removeProject', error, stackTrace);
      rethrow;
    }
  }

  Future<void> addTask(String projectId, Task task) async {
    final project = getById(projectId);
    if (project == null) {
      return;
    }
    final updatedTasks = List<Task>.from(project.tasks)..add(task);
    final updatedProject = project.copyWith(
      tasks: updatedTasks,
      progress: _calculateProgress(updatedTasks),
    );
    final index = _projects.indexOf(project);
    _projects[index] = updatedProject;
    notifyListeners();
    try {
      await _dataService.updateProjectTasks(
        projectId: projectId,
        tasks: updatedTasks,
        progress: updatedProject.progress,
      );
    } catch (error, stackTrace) {
      _projects[index] = project;
      notifyListeners();
      _logError('addTask', error, stackTrace);
      rethrow;
    }
  }

  Future<void> toggleTask(String projectId, String taskId) async {
    final project = getById(projectId);
    if (project == null) {
      return;
    }
    final updatedTasks = project.tasks
        .map(
          (task) => task.id == taskId
              ? task.copyWith(status: _nextStatus(task.status))
              : task,
        )
        .toList(growable: false);
    await _persistTaskUpdate(project, updatedTasks);
  }

  Future<void> updateTaskStatus(
    String projectId,
    String taskId,
    TaskStatus status,
  ) async {
    final project = getById(projectId);
    if (project == null) {
      return;
    }

    final updatedTasks = project.tasks
        .map((task) => task.id == taskId ? task.copyWith(status: status) : task)
        .toList(growable: false);
    await _persistTaskUpdate(project, updatedTasks);
  }

  Future<void> updateTaskSchedule(
    String projectId,
    String taskId, {
    required DateTime start,
    required DateTime end,
  }) async {
    if (!end.isAfter(start)) {
      return;
    }

    final project = getById(projectId);
    if (project == null) {
      return;
    }

    final updatedTasks = project.tasks
        .map(
          (task) => task.id == taskId
              ? task.copyWith(startDate: start, endDate: end)
              : task,
        )
        .toList(growable: false);
    await _persistTaskUpdate(project, updatedTasks, recomputeProgress: false);
  }

  Future<void> upsertIndustryExtension(
    String projectId,
    ProjectIndustryExtension extension,
  ) async {
    final ownerId = _requireUserId();
    final didPersist = await _persistIndustryExtension(
      ownerId,
      projectId,
      extension,
    );
    if (didPersist) {
      notifyListeners();
    }
  }

  List<Message> messagesFor(String projectId) {
    if (!_projectMessages.containsKey(projectId) &&
        !_pendingMessageFetches.contains(projectId)) {
      _ensureMessagesLoaded(projectId);
    }
    final messages = _projectMessages[projectId];
    if (messages == null) {
      return const [];
    }
    final sorted = List<Message>.from(messages)
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return List.unmodifiable(sorted);
  }

  Future<Message> addMessage(String projectId, Message message) async {
    final ownerId = _requireUserId();
    final pending = List<Message>.from(_projectMessages[projectId] ?? [])
      ..add(message);
    _projectMessages[projectId] = pending;
    notifyListeners();
    try {
      final persisted = await _dataService.createMessage(
        projectId,
        message,
        ownerId: ownerId,
      );
      final updated = List<Message>.from(_projectMessages[projectId] ?? [])
        ..removeWhere((msg) => msg.id == message.id)
        ..add(persisted)
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      _projectMessages[projectId] = updated;
      notifyListeners();
      return persisted;
    } catch (error, stackTrace) {
      _logError('addMessage', error, stackTrace);
      rethrow;
    }
  }

  Invitation? invitationById(String id) {
    try {
      return _invitations.firstWhere((invitation) => invitation.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> markInvitationRead(String id) async {
    final index = _invitations.indexWhere((invitation) => invitation.id == id);
    if (index == -1) {
      return;
    }

    final invitation = _invitations[index];
    if (invitation.readByInvitee) {
      return;
    }

    final updated = invitation.copyWith(readByInvitee: true);
    await _persistInvitationUpdate(index, updated);
  }

  Future<void> acceptInvitation(String id) async {
    final index = _invitations.indexWhere((invitation) => invitation.id == id);
    if (index == -1) {
      return;
    }

    final invitation = _invitations[index];
    if (invitation.status == InvitationStatus.accepted) {
      return;
    }

    final updatedInvitation = invitation.copyWith(
      status: InvitationStatus.accepted,
      updatedAt: DateTime.now(),
      receiptStatus: MessageReceiptStatus.read,
      readByInvitee: true,
      requiresOnboarding: false,
    );

    final project = getById(invitation.projectId);
    if (project != null) {
      final alreadyMember = project.members.any(
        (member) =>
            member.name.toLowerCase() == invitation.inviteeName.toLowerCase(),
      );
      if (!alreadyMember) {
        final updatedMembers = List<Member>.from(project.members)
          ..add(
            Member(id: 'member-${invitation.id}', name: invitation.inviteeName),
          );
        await _persistMemberUpdate(project, updatedMembers);
      }
    }

    await _persistInvitationUpdate(index, updatedInvitation);
  }

  Future<void> declineInvitation(String id) async {
    final index = _invitations.indexWhere((invitation) => invitation.id == id);
    if (index == -1) {
      return;
    }

    final invitation = _invitations[index];
    if (invitation.status == InvitationStatus.declined) {
      return;
    }

    final updated = invitation.copyWith(
      status: InvitationStatus.declined,
      updatedAt: DateTime.now(),
      receiptStatus: MessageReceiptStatus.received,
      readByInvitee: true,
      requiresOnboarding: false,
    );
    await _persistInvitationUpdate(index, updated);
  }

  Future<void> addInvitation({
    required String projectId,
    required String projectName,
    required String inviteeName,
    required String inviteeEmail,
    required String role,
    InvitationNote? message,
    bool requiresOnboarding = false,
  }) async {
    final normalizedEmail = inviteeEmail.trim().toLowerCase();
    final invitation = Invitation(
      id: 'inv-${DateTime.now().microsecondsSinceEpoch}',
      projectId: projectId,
      projectName: projectName,
      inviteeEmail: normalizedEmail,
      inviteeName: inviteeName,
      role: role,
      status: InvitationStatus.pending,
      sentAt: DateTime.now(),
      requiresOnboarding: requiresOnboarding,
      message: message,
      receiptStatus: MessageReceiptStatus.sent,
    );

    _invitations.insert(0, invitation);
    notifyListeners();
    try {
      final persisted = await _dataService.createInvitation(
        invitation: invitation,
        ownerId: _requireUserId(),
      );
      _replaceInvitation(persisted);
      if (requiresOnboarding) {
        try {
          await _invitationService.sendInviteEmail(persisted);
        } catch (error, stackTrace) {
          _logError('sendInviteEmail', error, stackTrace);
        }
      }
    } catch (error, stackTrace) {
      _logError('addInvitation', error, stackTrace);
      rethrow;
    }
  }

  Future<void> markReceipt({
    required String projectId,
    required String messageId,
    required String memberId,
    required MessageReceiptStatus status,
  }) async {
    final messages = _projectMessages[projectId];
    if (messages == null) {
      return;
    }

    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) {
      return;
    }

    final message = messages[index];
    final current = message.receipts[memberId];
    if (current == status) {
      return;
    }

    if (current != null && _receiptWeight(current) >= _receiptWeight(status)) {
      return;
    }

    final updatedReceipts = Map<String, MessageReceiptStatus>.from(
      message.receipts,
    )..[memberId] = status;
    final updatedMessage = message.copyWith(receipts: updatedReceipts);
    await _persistMessageUpdate(projectId, index, updatedMessage);
  }

  Future<void> addReaction(
    String projectId,
    String messageId,
    String emoji,
  ) async {
    final messages = _projectMessages[projectId];
    if (messages == null) {
      return;
    }

    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) {
      return;
    }

    final message = messages[index];
    final updatedReactions = Map<String, int>.from(message.reactions)
      ..update(emoji, (count) => count + 1, ifAbsent: () => 1);

    final updatedMessage = message.copyWith(reactions: updatedReactions);
    await _persistMessageUpdate(projectId, index, updatedMessage);
  }

  Future<void> _persistTaskUpdate(
    Project original,
    List<Task> updatedTasks, {
    bool recomputeProgress = true,
  }) async {
    final updatedProject = original.copyWith(
      tasks: updatedTasks,
      progress: recomputeProgress
          ? _calculateProgress(updatedTasks)
          : original.progress,
    );
    final index = _projects.indexOf(original);
    _projects[index] = updatedProject;
    notifyListeners();
    try {
      await _dataService.updateProjectTasks(
        projectId: original.id,
        tasks: updatedTasks,
        progress: updatedProject.progress,
      );
    } catch (error, stackTrace) {
      _projects[index] = original;
      notifyListeners();
      _logError('updateTask', error, stackTrace);
      rethrow;
    }
  }

  Future<void> _persistMemberUpdate(
    Project project,
    List<Member> members,
  ) async {
    final index = _projects.indexOf(project);
    final updatedProject = project.copyWith(members: members);
    _projects[index] = updatedProject;
    notifyListeners();
    try {
      await _dataService.updateProjectMembers(
        projectId: project.id,
        members: members,
      );
    } on PostgrestException catch (error, stackTrace) {
      if (_shouldAttemptPrivilegedUpdate(error)) {
        try {
          await _dataService.updateProjectMembersPrivileged(
            projectId: project.id,
            members: members,
          );
          return;
        } catch (fallbackError, fallbackStack) {
          _logError('updateMembersPrivileged', fallbackError, fallbackStack);
        }
      }
      _projects[index] = project;
      notifyListeners();
      _logError('updateMembers', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _projects[index] = project;
      notifyListeners();
      _logError('updateMembers', error, stackTrace);
      rethrow;
    }
  }

  Future<void> _persistInvitationUpdate(int index, Invitation updated) async {
    final previous = _invitations[index];
    _invitations[index] = updated;
    notifyListeners();
    try {
      final saved = await _dataService.updateInvitation(updated);
      _invitations[index] = saved;
      notifyListeners();
    } on PostgrestException catch (error, stackTrace) {
      final inviteeEmail = _client.auth.currentUser?.email;
      if (_shouldAttemptPrivilegedUpdate(error) && inviteeEmail != null) {
        try {
          final saved = await _dataService.updateInvitationPrivileged(
            updated,
            inviteeEmail: inviteeEmail,
          );
          _invitations[index] = saved;
          notifyListeners();
          return;
        } catch (fallbackError, fallbackStack) {
          _logError('updateInvitationPrivileged', fallbackError, fallbackStack);
        }
      }
      _invitations[index] = previous;
      notifyListeners();
      _logError('updateInvitation', error, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      _invitations[index] = previous;
      notifyListeners();
      _logError('updateInvitation', error, stackTrace);
      rethrow;
    }
  }

  bool _shouldAttemptPrivilegedUpdate(PostgrestException error) {
    if (error.code == '42501') {
      return true;
    }
    final message = error.message.toLowerCase();
    return message.contains('permission denied');
  }

  Future<void> _persistMessageUpdate(
    String projectId,
    int index,
    Message updated,
  ) async {
    final messages = List<Message>.from(_projectMessages[projectId] ?? []);
    if (messages.length <= index) {
      return;
    }
    final previous = messages[index];
    messages[index] = updated;
    _projectMessages[projectId] = messages;
    notifyListeners();
    try {
      await _dataService.updateMessage(updated);
    } catch (error, stackTrace) {
      messages[index] = previous;
      _projectMessages[projectId] = messages;
      notifyListeners();
      _logError('updateMessage', error, stackTrace);
    }
  }

  void _replaceInvitation(Invitation updated) {
    final index = _invitations.indexWhere((inv) => inv.id == updated.id);
    if (index == -1) {
      _invitations.insert(0, updated);
    } else {
      _invitations[index] = updated;
    }
    notifyListeners();
  }

  void _ensureMessagesLoaded(String projectId) {
    _pendingMessageFetches.add(projectId);
    scheduleMicrotask(() async {
      try {
        final messages = await _dataService.fetchMessages(projectId);
        _projectMessages[projectId] = messages;
        notifyListeners();
      } catch (error, stackTrace) {
        _logError('fetchMessages($projectId)', error, stackTrace);
      } finally {
        _pendingMessageFetches.remove(projectId);
      }
    });
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void reset() {
    _hasInitialized = false;
    _projects.clear();
    _projectMessages.clear();
    _contacts.clear();
    _invitations.clear();
    _sharedFiles.clear();
    _pendingMessageFetches.clear();
    _errorMessage = null;
    _industryProfile = const IndustryProfile.core();
    _industryExtensions.clear();
    notifyListeners();
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('User not authenticated');
    }
    return userId;
  }

  Future<void> _syncIndustryContext(
    String ownerId,
    List<Project> projects,
  ) async {
    try {
      _industryProfile = await _industryService.fetchProfile(ownerId);
      final extensions = await _industryService.fetchProjectExtensions(
        ownerId: ownerId,
        projectIds: projects.map((project) => project.id).toList(),
      );
      _industryExtensions
        ..clear()
        ..addAll(extensions);
    } catch (error, stackTrace) {
      _logError('syncIndustryContext', error, stackTrace);
    }
  }

  Future<bool> _persistIndustryExtension(
    String ownerId,
    String projectId,
    ProjectIndustryExtension? extension,
  ) async {
    if (extension == null || !extension.hasData) {
      return false;
    }
    try {
      final saved = await _industryService.upsertProjectExtension(
        ownerId: ownerId,
        projectId: projectId,
        extension: extension,
      );
      if (saved != null) {
        _industryExtensions[projectId] = saved;
        return true;
      }
    } catch (error, stackTrace) {
      _logError('persistIndustryExtension', error, stackTrace);
    }
    return false;
  }

  void _insertOrReplaceSharedFile(SharedFileRecord record) {
    final index = _sharedFiles.indexWhere((file) => file.id == record.id);
    if (index == -1) {
      _sharedFiles.insert(0, record);
    } else {
      _sharedFiles[index] = record;
    }
    _sortSharedFiles();
  }

  void _sortSharedFiles() {
    _sharedFiles.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
  }

  String _generateSharedFileId() {
    final seed = DateTime.now().microsecondsSinceEpoch;
    final suffix = currentUserId ?? currentUserEmail ?? 'anonymous';
    return 'shared-$seed-${suffix.hashCode}';
  }

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint('ProjectController.$action failed: $error');
    debugPrint(stackTrace.toString());
  }
}

int _calculateProgress(List<Task> tasks) {
  if (tasks.isEmpty) {
    return 0;
  }

  final completedCount = tasks
      .where((task) => task.status == TaskStatus.completed)
      .length;
  return ((completedCount / tasks.length) * 100).round();
}

TaskStatus _nextStatus(TaskStatus status) {
  switch (status) {
    case TaskStatus.planned:
      return TaskStatus.inProgress;
    case TaskStatus.inProgress:
      return TaskStatus.completed;
    case TaskStatus.completed:
    case TaskStatus.deferred:
      return TaskStatus.planned;
  }
}

int _receiptWeight(MessageReceiptStatus status) {
  switch (status) {
    case MessageReceiptStatus.sent:
      return 0;
    case MessageReceiptStatus.received:
      return 1;
    case MessageReceiptStatus.read:
      return 2;
  }
}

String _statusLabel(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.inPreparation:
      return 'In preparation';
    case ProjectStatus.ongoing:
      return 'In progress';
    case ProjectStatus.completed:
      return 'Completed';
    case ProjectStatus.archived:
      return 'Archived';
  }
}
