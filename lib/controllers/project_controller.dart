import 'package:flutter/material.dart';

import 'package:myapp/common/models/message.dart';
import 'package:myapp/models/project.dart';

class ProjectController extends ChangeNotifier {
  final List<Project> _projects = [];
  final Map<String, List<Message>> _projectMessages = {};

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
            completed: true,
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            description:
                'Confirm the preferred ballroom reservation and deposit payment.',
            attachments: const ['venue_proposal.pdf'],
          ),
          Task(
            id: 't2',
            title: 'Confirm catering',
            assigneeId: 'm2',
            completed: false,
            dueDate: DateTime.now().add(const Duration(days: 6)),
            description:
                'Finalize the dinner menu selections and guest dietary requirements.',
            attachments: const ['menu_options.xlsx'],
          ),
          Task(
            id: 't3',
            title: 'Create photo quote',
            assigneeId: 'm1',
            completed: false,
            dueDate: DateTime.now().add(const Duration(days: 12)),
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
            completed: false,
            dueDate: DateTime.now().add(const Duration(days: 18)),
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
            completed: true,
            dueDate: DateTime.now().subtract(const Duration(days: 62)),
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
      ),
      Message(
        id: 'msg2',
        authorId: 'm2',
        body: 'Great! I will update the catering vendor today.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      ),
      Message(
        id: 'msg3',
        authorId: 'm1',
        body: 'Reminder: send final photo package pricing before Friday.',
        sentAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      ),
    ];

    _projectMessages['p2'] = [
      Message(
        id: 'msg4',
        authorId: 'm3',
        body: 'Waiting on booth dimensions from the client.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      Message(
        id: 'msg5',
        authorId: 'm3',
        body: 'Received measurements—starting layout draft tonight.',
        sentAt: DateTime.now().subtract(const Duration(hours: 11)),
      ),
    ];

    _projectMessages['p3'] = [
      Message(
        id: 'msg6',
        authorId: 'm4',
        body: 'All edited files delivered to client folder.',
        sentAt: DateTime.now().subtract(const Duration(days: 70)),
      ),
      Message(
        id: 'msg7',
        authorId: 'm4',
        body: 'Client approved the color grading—project closed.',
        sentAt: DateTime.now().subtract(const Duration(days: 65)),
      ),
    ];
  }

  List<Project> get projects => List.unmodifiable(_projects);

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
      final completedCount = tasks.where((t) => t.completed).length;
      final newProgress = tasks.isEmpty
          ? 0
          : ((completedCount / tasks.length) * 100).round();
      final updated = p.copyWith(tasks: tasks, progress: newProgress);
      updateProject(updated);
    }
  }

  void toggleTask(String projectId, String taskId) {
    final p = getById(projectId);
    if (p != null) {
      final tasks = p.tasks
          .map((t) => t.id == taskId ? t.copyWith(completed: !t.completed) : t)
          .toList();
      final completedCount = tasks.where((t) => t.completed).length;
      final newProgress = tasks.isEmpty
          ? 0
          : ((completedCount / tasks.length) * 100).round();
      final updated = p.copyWith(tasks: tasks, progress: newProgress);
      updateProject(updated);
    }
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
}
