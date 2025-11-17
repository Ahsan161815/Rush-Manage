import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.authorId,
    required this.body,
    required this.sentAt,
    this.attachments = const [],
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime sentAt;
  final List<String> attachments;

  Message copyWith({String? body, List<String>? attachments}) => Message(
    id: id,
    authorId: authorId,
    body: body ?? this.body,
    sentAt: sentAt,
    attachments: attachments ?? this.attachments,
  );

  @override
  List<Object?> get props => [id, authorId, body, sentAt, attachments];
}
