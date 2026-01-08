import 'package:equatable/equatable.dart';

import 'package:myapp/common/models/contact_detail_args.dart';

typedef JsonMap = Map<String, dynamic>;

enum CrmContactType { client, collaborator, supplier }

extension CrmContactTypeMapper on CrmContactType {
  static const Map<CrmContactType, String> _storage = {
    CrmContactType.client: 'client',
    CrmContactType.collaborator: 'collaborator',
    CrmContactType.supplier: 'supplier',
  };

  String get storageValue => _storage[this] ?? 'client';

  static CrmContactType fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(CrmContactType.client, ''),
    );
    return entry.key;
  }
}

class CrmStat extends Equatable {
  const CrmStat({required this.label, required this.value, this.trend});

  final String label;
  final String value;
  final String? trend;

  factory CrmStat.fromJson(JsonMap json) => CrmStat(
    label: json['label'] as String? ?? '',
    value: json['value'] as String? ?? '',
    trend: json['trend'] as String?,
  );

  JsonMap toJson() => {
    'label': label,
    'value': value,
    if (trend != null) 'trend': trend,
  };

  @override
  List<Object?> get props => [label, value, trend];
}

class CrmContact extends Equatable {
  CrmContact({
    required this.id,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.address,
    this.notes,
    this.primaryProjectLabel,
    this.relationshipLabel,
    this.projects = const <ContactProjectSummary>[],
    this.stats = const <CrmStat>[],
    this.linkedProjects = const <String>[],
    this.financeHighlights = const <String>[],
    this.documentLinks = const <String>[],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String name;
  final CrmContactType type;
  final String? email;
  final String? phone;
  final String? address;
  final String? notes;
  final String? primaryProjectLabel;
  final String? relationshipLabel;
  final List<ContactProjectSummary> projects;
  final List<CrmStat> stats;
  final List<String> linkedProjects;
  final List<String> financeHighlights;
  final List<String> documentLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isClient => type == CrmContactType.client;
  bool get isCollaborator => type == CrmContactType.collaborator;
  bool get isSupplier => type == CrmContactType.supplier;

  String get initials {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String get searchableText {
    final buffer = StringBuffer()
      ..write(name)
      ..write(' ')
      ..write(type.storageValue)
      ..write(' ')
      ..write(primaryProjectLabel ?? '')
      ..write(' ')
      ..write(email ?? '')
      ..write(' ')
      ..write(phone ?? '');
    return buffer.toString().toLowerCase();
  }

  CrmStat? get primaryStat => stats.isNotEmpty ? stats.first : null;

  CrmContact copyWith({
    String? id,
    String? name,
    CrmContactType? type,
    String? email,
    String? phone,
    String? address,
    String? notes,
    String? primaryProjectLabel,
    String? relationshipLabel,
    List<ContactProjectSummary>? projects,
    List<CrmStat>? stats,
    List<String>? linkedProjects,
    List<String>? financeHighlights,
    List<String>? documentLinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CrmContact(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      primaryProjectLabel: primaryProjectLabel ?? this.primaryProjectLabel,
      relationshipLabel: relationshipLabel ?? this.relationshipLabel,
      projects: projects ?? this.projects,
      stats: stats ?? this.stats,
      linkedProjects: linkedProjects ?? this.linkedProjects,
      financeHighlights: financeHighlights ?? this.financeHighlights,
      documentLinks: documentLinks ?? this.documentLinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CrmContact.fromJson(JsonMap json) => CrmContact(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    type: CrmContactTypeMapper.fromStorage(json['type'] as String?),
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    address: json['address'] as String?,
    notes: json['notes'] as String?,
    primaryProjectLabel: json['primary_project_label'] as String?,
    relationshipLabel: json['relationship_label'] as String?,
    projects: _projectsFromJson(json['projects']),
    stats: _statsFromJson(json['crm_stats']),
    linkedProjects: _stringList(json['linked_projects']),
    financeHighlights: _stringList(json['finance_highlights']),
    documentLinks: _stringList(json['document_links']),
    createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
    updatedAt: _parseDate(json['updated_at']) ?? DateTime.now(),
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'type': type.storageValue,
    'email': email,
    'phone': phone,
    'address': address,
    'notes': notes,
    'primary_project_label': primaryProjectLabel,
    'relationship_label': relationshipLabel,
    'projects': projects.map((project) => project.toJson()).toList(),
    'crm_stats': stats.map((stat) => stat.toJson()).toList(),
    'linked_projects': linkedProjects,
    'finance_highlights': financeHighlights,
    'document_links': documentLinks,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    email,
    phone,
    address,
    notes,
    primaryProjectLabel,
    relationshipLabel,
    projects,
    stats,
    linkedProjects,
    financeHighlights,
    documentLinks,
    createdAt,
    updatedAt,
  ];
}

List<ContactProjectSummary> _projectsFromJson(dynamic source) {
  if (source is List) {
    return source
        .whereType<JsonMap>()
        .map(ContactProjectSummary.fromJson)
        .toList(growable: false);
  }
  return const [];
}

List<CrmStat> _statsFromJson(dynamic source) {
  if (source is List) {
    return source
        .whereType<JsonMap>()
        .map(CrmStat.fromJson)
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
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
