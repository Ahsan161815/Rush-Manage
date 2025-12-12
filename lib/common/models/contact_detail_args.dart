import 'package:equatable/equatable.dart';

enum ContactCategory { client, collaborator }

extension ContactCategoryX on ContactCategory {
  bool get isClient => this == ContactCategory.client;
}

class ContactProjectSummary extends Equatable {
  const ContactProjectSummary({
    required this.id,
    required this.name,
    required this.role,
    this.statusLabel,
  });

  final String id;
  final String name;
  final String role;
  final String? statusLabel;

  @override
  List<Object?> get props => [id, name, role, statusLabel];
}

class ContactDetailArgs extends Equatable {
  const ContactDetailArgs({
    required this.contactId,
    required this.name,
    required this.title,
    this.category = ContactCategory.collaborator,
    this.email,
    this.phone,
    this.location,
    this.note,
    this.tags = const <String>[],
    this.projects = const <ContactProjectSummary>[],
  });

  final String contactId;
  final String name;
  final String title;
  final ContactCategory category;
  final String? email;
  final String? phone;
  final String? location;
  final String? note;
  final List<String> tags;
  final List<ContactProjectSummary> projects;

  String get initials {
    final parts = name
        .trim()
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

  ContactDetailArgs copyWith({
    String? contactId,
    String? name,
    String? title,
    ContactCategory? category,
    String? email,
    String? phone,
    String? location,
    String? note,
    List<String>? tags,
    List<ContactProjectSummary>? projects,
  }) {
    return ContactDetailArgs(
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      title: title ?? this.title,
      category: category ?? this.category,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      projects: projects ?? this.projects,
    );
  }

  @override
  List<Object?> get props => [
    contactId,
    name,
    title,
    category,
    email,
    phone,
    location,
    note,
    tags,
    projects,
  ];

  bool get isClient => category.isClient;
}

class ContactProjectSeed extends Equatable {
  const ContactProjectSeed({
    required this.contactId,
    required this.clientName,
    this.clientEmail,
  });

  final String contactId;
  final String clientName;
  final String? clientEmail;

  @override
  List<Object?> get props => [contactId, clientName, clientEmail];
}
