import 'package:equatable/equatable.dart';

import 'package:myapp/common/models/message.dart';

enum InvitationStatus { pending, accepted, declined }

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
      role: role,
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
}
