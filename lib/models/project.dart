import 'package:equatable/equatable.dart';

enum ProjectStatus { inPreparation, ongoing, completed, archived }

class Member extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl; // optional

  const Member({required this.id, required this.name, this.avatarUrl});

  @override
  List<Object?> get props => [id, name, avatarUrl];
}

class Task extends Equatable {
  final String id;
  final String title;
  final String? assigneeId;
  final bool completed;
  final DateTime? dueDate;
  final String? description;
  final List<String> attachments;

  const Task({
    required this.id,
    required this.title,
    this.assigneeId,
    this.completed = false,
    this.dueDate,
    this.description,
    this.attachments = const [],
  });

  Task copyWith({
    String? title,
    String? assigneeId,
    bool? completed,
    DateTime? dueDate,
    String? description,
    List<String>? attachments,
  }) => Task(
    id: id,
    title: title ?? this.title,
    assigneeId: assigneeId ?? this.assigneeId,
    completed: completed ?? this.completed,
    dueDate: dueDate ?? this.dueDate,
    description: description ?? this.description,
    attachments: attachments ?? this.attachments,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    assigneeId,
    completed,
    dueDate,
    description,
    attachments,
  ];
}

class Project extends Equatable {
  final String id;
  final String name;
  final String client;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final int progress; // 0..100
  final String? description;
  final List<Member> members;
  final List<Task> tasks;

  const Project({
    required this.id,
    required this.name,
    this.client = '',
    this.startDate,
    this.endDate,
    this.status = ProjectStatus.inPreparation,
    this.progress = 0,
    this.description,
    this.members = const [],
    this.tasks = const [],
  });

  Project copyWith({
    String? id,
    String? name,
    String? client,
    DateTime? startDate,
    DateTime? endDate,
    ProjectStatus? status,
    int? progress,
    String? description,
    List<Member>? members,
    List<Task>? tasks,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      client: client ?? this.client,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      description: description ?? this.description,
      members: members ?? this.members,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    client,
    startDate,
    endDate,
    status,
    progress,
    description,
    members,
    tasks,
  ];
}
