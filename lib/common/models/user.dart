import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    this.roleTitle,
    this.phone,
    this.location,
    this.focusArea,
    this.bio,
  });

  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String? roleTitle;
  final String? phone;
  final String? location;
  final String? focusArea;
  final String? bio;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: (map['id'] as String?)?.trim() ?? '',
      email: (map['email'] as String?)?.trim() ?? '',
      fullName: (map['full_name'] as String?)?.trim() ?? '',
      avatarUrl: (map['avatar_url'] as String?)?.trim(),
      roleTitle: (map['role_title'] as String?)?.trim(),
      phone: (map['phone'] as String?)?.trim(),
      location: (map['location'] as String?)?.trim(),
      focusArea: (map['focus_area'] as String?)?.trim(),
      bio: (map['bio'] as String?)?.trim(),
    );
  }

  factory UserProfile.fromAuthUser(User user) {
    final metadata = user.userMetadata;
    String? metadataName;
    if (metadata is Map<String, dynamic>) {
      metadataName = (metadata['display_name'] as String?)?.trim();
    }
    return UserProfile(
      id: user.id,
      email: (user.email ?? '').trim(),
      fullName: metadataName ?? '',
      avatarUrl: null,
      roleTitle: null,
      phone: null,
      location: null,
      focusArea: null,
      bio: null,
    );
  }

  String get displayName {
    final normalized = fullName.trim();
    if (normalized.isNotEmpty) {
      return normalized;
    }
    final emailHandle = email.trim();
    if (emailHandle.isNotEmpty && emailHandle.contains('@')) {
      return emailHandle.split('@').first;
    }
    return 'Crew';
  }

  String get firstName {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((value) => value.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return displayName;
    }
    return parts.first;
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    final firstInitial = parts.first[0].toUpperCase();
    final lastInitial = parts.last[0].toUpperCase();
    return '$firstInitial$lastInitial';
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? avatarUrl,
    String? roleTitle,
    String? phone,
    String? location,
    String? focusArea,
    String? bio,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roleTitle: roleTitle ?? this.roleTitle,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      focusArea: focusArea ?? this.focusArea,
      bio: bio ?? this.bio,
    );
  }
}
