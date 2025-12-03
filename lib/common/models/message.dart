import 'package:equatable/equatable.dart';

enum MessageReceiptStatus { sent, received, read }

class Message extends Equatable {
  const Message({
    required this.id,
    required this.authorId,
    required this.body,
    required this.sentAt,
    this.attachments = const [],
    this.mentions = const [],
    this.reactions = const {},
    this.receipts = const {},
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime sentAt;
  final List<String> attachments;
  final List<String> mentions;
  final Map<String, int> reactions;
  final Map<String, MessageReceiptStatus> receipts;

  Message copyWith({
    String? body,
    List<String>? attachments,
    List<String>? mentions,
    Map<String, int>? reactions,
    Map<String, MessageReceiptStatus>? receipts,
  }) => Message(
    id: id,
    authorId: authorId,
    body: body ?? this.body,
    sentAt: sentAt,
    attachments: attachments ?? this.attachments,
    mentions: mentions ?? this.mentions,
    reactions: reactions ?? this.reactions,
    receipts: receipts ?? this.receipts,
  );

  @override
  List<Object?> get props => [
    id,
    authorId,
    body,
    sentAt,
    attachments,
    mentions,
    reactions,
    receipts,
  ];
}
