import 'package:flutter/material.dart';
import 'package:myapp/models/project.dart';

class ProjectController extends ChangeNotifier {
  final List<Project> _projects = [];

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
        tasks: const [
          Task(
            id: 't1',
            title: 'Book the venue',
            assigneeId: 'm1',
            completed: true,
          ),
          Task(
            id: 't2',
            title: 'Confirm catering',
            assigneeId: 'm2',
            completed: false,
          ),
          Task(
            id: 't3',
            title: 'Create photo quote',
            assigneeId: 'm1',
            completed: false,
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
        tasks: const [
          Task(
            id: 't4',
            title: 'Design stand',
            assigneeId: 'm3',
            completed: false,
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
        tasks: const [
          Task(
            id: 't5',
            title: 'Finalize shots',
            assigneeId: 'm4',
            completed: true,
          ),
        ],
      ),
    ]);
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
    notifyListeners();
  }

  void addTask(String projectId, Task task) {
    final p = getById(projectId);
    if (p != null) {
      final updated = p.copyWith(tasks: List.from(p.tasks)..add(task));
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
}
