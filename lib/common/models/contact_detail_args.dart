import 'package:equatable/equatable.dart';

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
    email,
    phone,
    location,
    note,
    tags,
    projects,
  ];
}
