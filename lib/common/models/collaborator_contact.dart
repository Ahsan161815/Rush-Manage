import 'package:equatable/equatable.dart';

enum CollaboratorAvailability { available, busy, offline }

typedef CollaboratorTag = String;

class CollaboratorContact extends Equatable {
  const CollaboratorContact({
    required this.id,
    required this.name,
    required this.profession,
    required this.availability,
    required this.location,
    required this.email,
    this.phone,
    this.lastProject,
    this.tags = const <CollaboratorTag>[],
  });

  final String id;
  final String name;
  final String profession;
  final CollaboratorAvailability availability;
  final String location;
  final String email;
  final String? phone;
  final String? lastProject;
  final List<CollaboratorTag> tags;

  CollaboratorContact copyWith({
    String? name,
    String? profession,
    CollaboratorAvailability? availability,
    String? location,
    String? email,
    String? phone,
    String? lastProject,
    List<CollaboratorTag>? tags,
  }) {
    return CollaboratorContact(
      id: id,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      availability: availability ?? this.availability,
      location: location ?? this.location,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      lastProject: lastProject ?? this.lastProject,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    profession,
    availability,
    location,
    email,
    phone,
    lastProject,
    tags,
  ];
}
