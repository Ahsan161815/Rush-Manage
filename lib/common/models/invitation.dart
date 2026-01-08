import 'package:equatable/equatable.dart';

import 'package:myapp/common/models/message.dart';

typedef JsonMap = Map<String, dynamic>;

enum InvitationStatus { pending, accepted, declined }

extension InvitationStatusMapper on InvitationStatus {
  static const Map<InvitationStatus, String> _storage = {
    InvitationStatus.pending: 'pending',
    InvitationStatus.accepted: 'accepted',
    InvitationStatus.declined: 'declined',
  };

  String get storageValue => _storage[this] ?? 'pending';

  static InvitationStatus fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(InvitationStatus.pending, ''),
    );
    return entry.key;
  }
}

typedef InvitationId = String;

typedef ProjectId = String;

typedef InviteeId = String;

typedef InvitationNote = String;

class Invitation extends Equatable {
  const Invitation({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.inviteeEmail,
    required this.inviteeName,
    required this.role,
    required this.status,
    required this.sentAt,
    this.requiresOnboarding = false,
    this.message,
    this.updatedAt,
    this.readByInvitee = false,
    this.receiptStatus = MessageReceiptStatus.sent,
  });

  final InvitationId id;
  final ProjectId projectId;
  final String projectName;
  final String inviteeEmail;
  final String inviteeName;
  final String role;
  final InvitationStatus status;
  final DateTime sentAt;
  final bool requiresOnboarding;
  final InvitationNote? message;
  final DateTime? updatedAt;
  final bool readByInvitee;
  final MessageReceiptStatus receiptStatus;

  bool get isPending => status == InvitationStatus.pending;

  Invitation copyWith({
    String? role,
    InvitationStatus? status,
    DateTime? updatedAt,
    bool? requiresOnboarding,
    InvitationNote? message,
    bool? readByInvitee,
    MessageReceiptStatus? receiptStatus,
  }) {
    return Invitation(
      id: id,
      projectId: projectId,
      projectName: projectName,
      inviteeEmail: inviteeEmail,
      inviteeName: inviteeName,
      role: role ?? this.role,
      status: status ?? this.status,
      sentAt: sentAt,
      requiresOnboarding: requiresOnboarding ?? this.requiresOnboarding,
      message: message ?? this.message,
      updatedAt: updatedAt ?? this.updatedAt,
      readByInvitee: readByInvitee ?? this.readByInvitee,
      receiptStatus: receiptStatus ?? this.receiptStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    projectName,
    inviteeEmail,
    inviteeName,
    role,
    status,
    sentAt,
    requiresOnboarding,
    message,
    updatedAt,
    readByInvitee,
    receiptStatus,
  ];

  factory Invitation.fromJson(JsonMap json) => Invitation(
    id: json['id'] as String,
    projectId: json['project_id'] as String? ?? '',
    projectName: json['project_name'] as String? ?? '',
    inviteeEmail: json['invitee_email'] as String? ?? '',
    inviteeName: json['invitee_name'] as String? ?? '',
    role: json['role'] as String? ?? '',
    status: InvitationStatusMapper.fromStorage(json['status'] as String?),
    sentAt: _parseDate(json['sent_at']) ?? DateTime.now(),
    requiresOnboarding: json['requires_onboarding'] as bool? ?? false,
    message: json['message'] as String?,
    updatedAt: _parseDate(json['updated_at']),
    readByInvitee: json['read_by_invitee'] as bool? ?? false,
    receiptStatus: MessageReceiptStatusMapper.fromStorage(
      json['receipt_status'] as String?,
    ),
  );

  JsonMap toJson() => {
    'id': id,
    'project_id': projectId,
    'project_name': projectName,
    'invitee_email': inviteeEmail,
    'invitee_name': inviteeName,
    'role': role,
    'status': status.storageValue,
    'sent_at': sentAt.toIso8601String(),
    'requires_onboarding': requiresOnboarding,
    'message': message,
    'updated_at': updatedAt?.toIso8601String(),
    'read_by_invitee': readByInvitee,
    'receipt_status': receiptStatus.storageValue,
  };
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
