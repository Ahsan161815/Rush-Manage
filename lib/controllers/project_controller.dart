import 'package:flutter/material.dart';

import 'package:myapp/common/models/collaborator_contact.dart';
import 'package:myapp/common/models/contact_detail_args.dart';
import 'package:myapp/common/models/invitation.dart';
import 'package:myapp/common/models/message.dart';
import 'package:myapp/models/project.dart';

class ProjectController extends ChangeNotifier {
  final List<Project> _projects = [];
  final Map<String, List<Message>> _projectMessages = {};
  final List<CollaboratorContact> _contacts = [];
  final List<Invitation> _invitations = [];
  final Map<String, String> _memberContactMap = {};

  ProjectController() {
    // mock data
    _projects.addAll([
      Project(
        id: 'p1',
        name: 'Dupont Wedding',
        client: 'Dupont Family',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        status: ProjectStatus.ongoing,
        progress: 42,
        description: 'Full wedding coordination and photography',
        members: const [
          Member(id: 'm1', name: 'Sarah'),
          Member(id: 'm2', name: 'Alex'),
        ],
        tasks: [
          Task(
            id: 't1',
            title: 'Book the venue',
            assigneeId: 'm1',
            status: TaskStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 14)),
            endDate: DateTime.now().subtract(const Duration(days: 2)),
            description:
                'Confirm the preferred ballroom reservation and deposit payment.',
            attachments: const ['venue_proposal.pdf'],
          ),
          Task(
            id: 't2',
            title: 'Confirm catering',
            assigneeId: 'm2',
            status: TaskStatus.inProgress,
            startDate: DateTime.now().subtract(const Duration(days: 1)),
            endDate: DateTime.now().add(const Duration(days: 6)),
            description:
                'Finalize the dinner menu selections and guest dietary requirements.',
            attachments: const ['menu_options.xlsx'],
          ),
          Task(
            id: 't3',
            title: 'Create photo quote',
            assigneeId: 'm1',
            status: TaskStatus.planned,
            startDate: DateTime.now().add(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 12)),
            description:
                'Provide detailed pricing for ceremony, reception, and album add-ons.',
            attachments: const ['photo_package.pdf'],
          ),
        ],
      ),
      Project(
        id: 'p2',
        name: 'Pro Trade Show – January',
        client: 'Pro Trade',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 40)),
        status: ProjectStatus.inPreparation,
        progress: 12,
        description: 'Stand design and logistics',
        members: const [Member(id: 'm3', name: 'Paul')],
        tasks: [
          Task(
            id: 't4',
            title: 'Design stand',
            assigneeId: 'm3',
            status: TaskStatus.planned,
            startDate: DateTime.now().add(const Duration(days: 12)),
            endDate: DateTime.now().add(const Duration(days: 18)),
            description:
                'Produce concept sketches and final 3D renders for the trade stand.',
            attachments: const ['booth_brief.pdf'],
          ),
        ],
      ),
      Project(
        id: 'p3',
        name: 'Photo Shoot – Completed',
        client: 'StudioX',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().subtract(const Duration(days: 60)),
        status: ProjectStatus.completed,
        progress: 100,
        description: 'Product catalog shoot',
        members: const [Member(id: 'm4', name: 'Nina')],
        tasks: [
          Task(
            id: 't5',
            title: 'Finalize shots',
            assigneeId: 'm4',
            status: TaskStatus.completed,
            startDate: DateTime.now().subtract(const Duration(days: 68)),
            endDate: DateTime.now().subtract(const Duration(days: 62)),
            description:
                'Retouch and deliver the approved product imagery set.',
            attachments: const ['final_shots.zip'],
          ),
        ],
      ),
    ]);

    _projectMessages['p1'] = [
      Message(
        id: 'msg1',
        authorId: 'm1',
        body: 'Venue deposit confirmed with the coordinator.',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
        attachments: const ['venue_contract.pdf', 'deposit_receipt.jpeg'],
        reactions: const {'👍': 3, '✅': 1},
        receipts: const {
          'me': MessageReceiptStatus.read,
          'm1': MessageReceiptStatus.read,
          'm2': MessageReceiptStatus.received,
        },
      ),
      Message(
        id: 'msg2',
        authorId: 'm2',
        body: 'Great! I will update the catering vendor today. @Sarah',
        sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
        mentions: const ['@Sarah'],
        reactions: const {'❤️': 2},
        receipts: const {
          'me': MessageReceiptStatus.received,
          'm1': MessageReceiptStatus.read,
          'm2': MessageReceiptStatus.read,
        },
      ),
      Message(
        id: 'msg3',
        authorId: 'm1',
        body: 'Reminder: send final photo package pricing before Friday. @Alex',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        attachments: const ['pricing_draft.pdf'],
        mentions: const ['@Alex'],
        reactions: const {'👍': 1, '❤️': 1, '✅': 1},
        receipts: const {
          'me': MessageReceiptStatus.received,
          'm1': MessageReceiptStatus.read,
          'm2': MessageReceiptStatus.sent,
        },
      ),
    ];

    _projectMessages['p2'] = [
      Message(
        id: 'msg4',
        authorId: 'm3',
        body: 'Waiting on booth dimensions from the client.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        reactions: const {'👍': 1},
        receipts: const {
          'me': MessageReceiptStatus.received,
          'm3': MessageReceiptStatus.read,
        },
      ),
      Message(
        id: 'msg5',
        authorId: 'm3',
        body: 'Received measurements—starting layout draft tonight.',
        sentAt: DateTime.now().subtract(const Duration(hours: 11)),
        attachments: const ['layout_brief.pdf'],
        receipts: const {
          'me': MessageReceiptStatus.sent,
          'm3': MessageReceiptStatus.read,
        },
      ),
    ];

    _projectMessages['p3'] = [
      Message(
        id: 'msg6',
        authorId: 'm4',
        body: 'All edited files delivered to client folder.',
        sentAt: DateTime.now().subtract(const Duration(days: 70)),
        attachments: const ['deliverables.zip'],
        receipts: const {
          'me': MessageReceiptStatus.read,
          'm4': MessageReceiptStatus.read,
        },
      ),
      Message(
        id: 'msg7',
        authorId: 'm4',
        body: 'Client approved the color grading—project closed.',
        sentAt: DateTime.now().subtract(const Duration(days: 65)),
        reactions: const {'❤️': 3},
        receipts: const {
          'me': MessageReceiptStatus.received,
          'm4': MessageReceiptStatus.read,
        },
      ),
    ];

    _contacts.addAll([
      const CollaboratorContact(
        id: 'c1',
        name: 'Sarah Collins',
        profession: 'Photographer',
        availability: CollaboratorAvailability.available,
        location: 'Paris, FR',
        email: 'sarah.collins@studiox.com',
        phone: '+33 1 23 45 67 89',
        lastProject: 'Dupont Wedding',
        tags: ['Lead shooter', 'Gallery editing'],
      ),
      const CollaboratorContact(
        id: 'c2',
        name: 'Gourmet Caterer',
        profession: 'Caterer',
        availability: CollaboratorAvailability.busy,
        location: 'Lyon, FR',
        email: 'hello@gourmetcaterer.fr',
        phone: '+33 2 11 22 33 44',
        lastProject: 'Corporate Dinner',
        tags: ['Fine dining', 'Vegan friendly'],
      ),
      const CollaboratorContact(
        id: 'c3',
        name: 'Laura Design',
        profession: 'Decorator',
        availability: CollaboratorAvailability.offline,
        location: 'Marseille, FR',
        email: 'studio@lauradesign.fr',
        phone: '+33 4 55 66 77 88',
        lastProject: 'Art Expo Launch',
        tags: ['Scenography', 'Florals'],
      ),
      const CollaboratorContact(
        id: 'c4',
        name: 'Karim Haddad',
        profession: 'Videographer',
        availability: CollaboratorAvailability.available,
        location: 'Toulouse, FR',
        email: 'karim@filmcrafted.com',
        phone: '+33 6 98 76 54 32',
        lastProject: 'Product Launch',
        tags: ['Cinematic', 'Drone'],
      ),
    ]);

    _memberContactMap.addAll({'m1': 'c1', 'm2': 'c2', 'm3': 'c3', 'm4': 'c4'});

    _invitations.addAll([
      Invitation(
        id: 'inv1',
        projectId: 'p1',
        projectName: 'Dupont Wedding',
        inviteeEmail: 'alex.turner@creativehub.co',
        inviteeName: 'Alex Turner',
        role: 'Gallery Editor',
        status: InvitationStatus.pending,
        sentAt: DateTime.now().subtract(const Duration(hours: 12)),
        requiresOnboarding: true,
        message: 'We would love your eye on the final print selection.',
        receiptStatus: MessageReceiptStatus.received,
      ),
      Invitation(
        id: 'inv2',
        projectId: 'p2',
        projectName: 'Pro Trade Show – January',
        inviteeEmail: 'marie@stagedesign.fr',
        inviteeName: 'Marie Curie',
        role: 'Lighting Designer',
        status: InvitationStatus.accepted,
        sentAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
        requiresOnboarding: false,
        message: 'Thanks for joining again this season!',
        readByInvitee: true,
        receiptStatus: MessageReceiptStatus.read,
      ),
      Invitation(
        id: 'inv3',
        projectId: 'p3',
        projectName: 'Photo Shoot – Completed',
        inviteeEmail: 'paul@logisticsteam.fr',
        inviteeName: 'Paul Martin',
        role: 'Logistics Support',
        status: InvitationStatus.declined,
        sentAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9, hours: 5)),
        requiresOnboarding: false,
        message: 'Catch you next time, Paul gave notice.',
        readByInvitee: true,
        receiptStatus: MessageReceiptStatus.received,
      ),
    ]);
  }

  List<Project> get projects => List.unmodifiable(_projects);
  List<CollaboratorContact> get contacts => List.unmodifiable(_contacts);
  List<Invitation> get invitations => List.unmodifiable(_invitations);

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
    final mappedId = _memberContactMap[member.id];
    if (mappedId != null) {
      final contact = contactById(mappedId);
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

    if (resolvedContact?.lastProject != null &&
        (currentProject == null ||
            currentProject.name != resolvedContact!.lastProject)) {
      projects.add(
        ContactProjectSummary(
          id: 'last-${resolvedContact!.lastProject}',
          name: resolvedContact.lastProject!,
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

  void addProject(Project p) {
    _projects.add(p);
    notifyListeners();
  }

  void updateProject(Project updated) {
    final idx = _projects.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _projects[idx] = updated;
      notifyListeners();
    }
  }

  void removeProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _projectMessages.remove(id);
    notifyListeners();
  }

  void addTask(String projectId, Task task) {
    final p = getById(projectId);
    if (p != null) {
      final tasks = List<Task>.from(p.tasks)..add(task);
      final updated = p.copyWith(
        tasks: tasks,
        progress: _calculateProgress(tasks),
      );
      updateProject(updated);
    }
  }

  void toggleTask(String projectId, String taskId) {
    final p = getById(projectId);
    if (p != null) {
      final tasks = p.tasks
          .map(
            (t) =>
                t.id == taskId ? t.copyWith(status: _nextStatus(t.status)) : t,
          )
          .toList();
      final updated = p.copyWith(
        tasks: tasks,
        progress: _calculateProgress(tasks),
      );
      updateProject(updated);
    }
  }

  void updateTaskStatus(String projectId, String taskId, TaskStatus status) {
    final p = getById(projectId);
    if (p == null) {
      return;
    }

    final tasks = p.tasks
        .map((task) => task.id == taskId ? task.copyWith(status: status) : task)
        .toList(growable: false);

    final updated = p.copyWith(
      tasks: tasks,
      progress: _calculateProgress(tasks),
    );
    updateProject(updated);
  }

  void updateTaskSchedule(
    String projectId,
    String taskId, {
    required DateTime start,
    required DateTime end,
  }) {
    if (!end.isAfter(start)) {
      return;
    }

    final p = getById(projectId);
    if (p == null) {
      return;
    }

    final tasks = p.tasks
        .map(
          (task) => task.id == taskId
              ? task.copyWith(startDate: start, endDate: end)
              : task,
        )
        .toList(growable: false);

    final updated = p.copyWith(tasks: tasks);
    updateProject(updated);
  }

  List<Message> messagesFor(String projectId) {
    final messages = _projectMessages[projectId];
    if (messages == null) {
      return const [];
    }
    return List.unmodifiable(messages);
  }

  void addMessage(String projectId, Message message) {
    final messages = List<Message>.from(_projectMessages[projectId] ?? [])
      ..add(message);
    _projectMessages[projectId] = messages;
    notifyListeners();
  }

  Invitation? invitationById(String id) {
    try {
      return _invitations.firstWhere((invitation) => invitation.id == id);
    } catch (_) {
      return null;
    }
  }

  void markInvitationRead(String id) {
    final index = _invitations.indexWhere((invitation) => invitation.id == id);
    if (index == -1) {
      return;
    }

    final invitation = _invitations[index];
    if (invitation.readByInvitee) {
      return;
    }

    _invitations[index] = invitation.copyWith(readByInvitee: true);
    notifyListeners();
  }

  void acceptInvitation(String id) {
    final index = _invitations.indexWhere((invitation) => invitation.id == id);
    if (index == -1) {
      return;
    }

    final invitation = _invitations[index];
    if (invitation.status == InvitationStatus.accepted) {
      return;
    }

    _invitations[index] = invitation.copyWith(
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
        updateProject(project.copyWith(members: updatedMembers));
      }
    }

    notifyListeners();
  }

  void declineInvitation(String id) {
    final index = _invitations.indexWhere((invitation) => invitation.id == id);
    if (index == -1) {
      return;
    }

    final invitation = _invitations[index];
    if (invitation.status == InvitationStatus.declined) {
      return;
    }

    _invitations[index] = invitation.copyWith(
      status: InvitationStatus.declined,
      updatedAt: DateTime.now(),
      receiptStatus: MessageReceiptStatus.received,
      readByInvitee: true,
      requiresOnboarding: false,
    );
    notifyListeners();
  }

  void addInvitation({
    required String projectId,
    required String projectName,
    required String inviteeName,
    required String inviteeEmail,
    required String role,
    InvitationNote? message,
    bool requiresOnboarding = false,
  }) {
    final invitation = Invitation(
      id: 'inv-${DateTime.now().microsecondsSinceEpoch}',
      projectId: projectId,
      projectName: projectName,
      inviteeEmail: inviteeEmail,
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
  }

  void markReceipt({
    required String projectId,
    required String messageId,
    required String memberId,
    required MessageReceiptStatus status,
  }) {
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
    final updatedMessages = List<Message>.from(messages)
      ..[index] = updatedMessage;

    _projectMessages[projectId] = updatedMessages;
    notifyListeners();
  }

  void addReaction(String projectId, String messageId, String emoji) {
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
    final updatedMessages = List<Message>.from(messages)
      ..[index] = updatedMessage;

    _projectMessages[projectId] = updatedMessages;
    notifyListeners();
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
