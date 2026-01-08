import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

enum CollaboratorAvailability { available, busy, offline }

extension CollaboratorAvailabilityMapper on CollaboratorAvailability {
  static const Map<CollaboratorAvailability, String> _storage = {
    CollaboratorAvailability.available: 'available',
    CollaboratorAvailability.busy: 'busy',
    CollaboratorAvailability.offline: 'offline',
  };

  String get storageValue => _storage[this] ?? 'available';

  static CollaboratorAvailability fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(CollaboratorAvailability.available, ''),
    );
    return entry.key;
  }
}

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

  factory CollaboratorContact.fromJson(JsonMap json) => CollaboratorContact(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    profession: json['profession'] as String? ?? '',
    availability: CollaboratorAvailabilityMapper.fromStorage(
      json['availability'] as String?,
    ),
    location: json['location'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String?,
    lastProject: json['last_project'] as String?,
    tags: _stringList(json['tags']),
  );

  JsonMap toJson() => {
    'id': id,
    'name': name,
    'profession': profession,
    'availability': availability.storageValue,
    'location': location,
    'email': email,
    'phone': phone,
    'last_project': lastProject,
    'tags': tags,
  };
}

List<String> _stringList(dynamic source) {
  if (source is List) {
    return source.whereType<String>().toList(growable: false);
  }
  return const [];
}
