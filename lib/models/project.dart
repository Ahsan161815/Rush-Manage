import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

enum ProjectStatus { inPreparation, ongoing, completed, archived }

extension ProjectStatusMapper on ProjectStatus {
  static const Map<ProjectStatus, String> _storage = {
    ProjectStatus.inPreparation: 'in_preparation',
    ProjectStatus.ongoing: 'ongoing',
    ProjectStatus.completed: 'completed',
    ProjectStatus.archived: 'archived',
  };

  String get storageValue => _storage[this] ?? 'in_preparation';

  static ProjectStatus fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(ProjectStatus.inPreparation, ''),
    );
    return entry.key;
  }
}

enum TaskStatus { planned, inProgress, completed, deferred }

extension TaskStatusMapper on TaskStatus {
  static const Map<TaskStatus, String> _storage = {
    TaskStatus.planned: 'planned',
    TaskStatus.inProgress: 'in_progress',
    TaskStatus.completed: 'completed',
    TaskStatus.deferred: 'deferred',
  };

  String get storageValue => _storage[this] ?? 'planned';

  static TaskStatus fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(TaskStatus.planned, ''),
    );
    return entry.key;
  }
}

class Member extends Equatable {
  final String id;
  final String name;
  final String? role;
  final String? avatarUrl; // optional
  final String? contactId;

  const Member({
    required this.id,
    required this.name,
    this.role,
    this.avatarUrl,
    this.contactId,
  });

  Member copyWith({
    String? name,
    String? role,
    String? avatarUrl,
    String? contactId,
  }) {
    return Member(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      contactId: contactId ?? this.contactId,
    );
  }

  factory Member.fromJson(JsonMap json) => Member(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    role: json['role'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    contactId: json['contact_id'] as String?,
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    if (role != null) 'role': role,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (contactId != null) 'contact_id': contactId,
  };

  @override
  List<Object?> get props => [id, name, role, avatarUrl, contactId];
}

class Task extends Equatable {
  final String id;
  final String title;
  final String? assigneeId;
  final TaskStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<String> attachments;

  const Task({
    required this.id,
    required this.title,
    this.assigneeId,
    this.status = TaskStatus.planned,
    this.startDate,
    this.endDate,
    this.description,
    this.attachments = const [],
  });

  Task copyWith({
    String? title,
    String? assigneeId,
    TaskStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? dueDate,
    String? description,
    List<String>? attachments,
  }) => Task(
    id: id,
    title: title ?? this.title,
    assigneeId: assigneeId ?? this.assigneeId,
    status: status ?? this.status,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? dueDate ?? this.endDate,
    description: description ?? this.description,
    attachments: attachments ?? this.attachments,
  );

  bool get isCompleted => status == TaskStatus.completed;

  DateTime? get dueDate => endDate;

  factory Task.fromJson(JsonMap json) => Task(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    assigneeId: json['assignee_id'] as String?,
    status: TaskStatusMapper.fromStorage(json['status'] as String?),
    startDate: _parseDate(json['start_date']),
    endDate: _parseDate(json['end_date']),
    description: json['description'] as String?,
    attachments: _stringList(json['attachments']),
  );

  JsonMap toJson() => {
    'id': id,
    'title': title,
    'assignee_id': assigneeId,
    'status': status.storageValue,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    if (description != null) 'description': description,
    'attachments': attachments,
  };

  @override
  List<Object?> get props => [
    id,
    title,
    assigneeId,
    status,
    startDate,
    endDate,
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
  final String? category;
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
    this.category,
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
    String? category,
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
      category: category ?? this.category,
      members: members ?? this.members,
      tasks: tasks ?? this.tasks,
    );
  }

  factory Project.fromJson(JsonMap json) => Project(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    client: json['client'] as String? ?? '',
    startDate: _parseDate(json['start_date']),
    endDate: _parseDate(json['end_date']),
    status: ProjectStatusMapper.fromStorage(json['status'] as String?),
    progress: (json['progress'] as num?)?.round() ?? 0,
    description: json['description'] as String?,
    category: json['category'] as String?,
    members: _membersFromJson(json['members']),
    tasks: _tasksFromJson(json['tasks']),
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'client': client,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'status': status.storageValue,
    'progress': progress,
    if (description != null) 'description': description,
    if (category != null) 'category': category,
    'members': members.map((member) => member.toJson()).toList(),
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

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
    category,
    members,
    tasks,
  ];
}

List<Member> _membersFromJson(dynamic source) {
  if (source is List) {
    return source
        .whereType<JsonMap>()
        .map(Member.fromJson)
        .toList(growable: false);
  }
  return const [];
}

List<Task> _tasksFromJson(dynamic source) {
  if (source is List) {
    return source
        .whereType<JsonMap>()
        .map(Task.fromJson)
        .toList(growable: false);
  }
  return const [];
}

List<String> _stringList(dynamic source) {
  if (source is List) {
    return source.whereType<String>().toList(growable: false);
  }
  return const [];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
