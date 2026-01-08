import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

class MessageReplyPreview extends Equatable {
  const MessageReplyPreview({
    required this.messageId,
    required this.authorId,
    required this.authorName,
    required this.sentAt,
    required this.body,
    this.authorAvatarUrl,
    this.attachments = const [],
  });

  final String messageId;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime sentAt;
  final String body;
  final List<String> attachments;

  factory MessageReplyPreview.fromJson(dynamic source) {
    if (source is Map) {
      return MessageReplyPreview(
        messageId: source['message_id'] as String? ?? '',
        authorId: source['author_id'] as String? ?? '',
        authorName: source['author_name'] as String? ?? '',
        authorAvatarUrl: source['author_avatar_url'] as String?,
        sentAt: _parseDate(source['sent_at']) ?? DateTime.now(),
        body: source['body'] as String? ?? '',
        attachments: _stringList(source['attachments']),
      );
    }
    return MessageReplyPreview(
      messageId: '',
      authorId: '',
      authorName: '',
      sentAt: _epoch,
      body: '',
    );
  }

  JsonMap toJson() => {
    'message_id': messageId,
    'author_id': authorId,
    'author_name': authorName,
    'author_avatar_url': authorAvatarUrl,
    'sent_at': sentAt.toIso8601String(),
    'body': body,
    'attachments': attachments,
  };

  @override
  List<Object?> get props => [
    messageId,
    authorId,
    authorName,
    authorAvatarUrl,
    sentAt,
    body,
    attachments,
  ];
}

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

enum MessageReceiptStatus { sent, received, read }

extension MessageReceiptStatusMapper on MessageReceiptStatus {
  static const Map<MessageReceiptStatus, String> _storage = {
    MessageReceiptStatus.sent: 'sent',
    MessageReceiptStatus.received: 'received',
    MessageReceiptStatus.read: 'read',
  };

  String get storageValue => _storage[this] ?? 'sent';

  static MessageReceiptStatus fromStorage(String? value) {
    final entry = _storage.entries.firstWhere(
      (item) => item.value == value,
      orElse: () => const MapEntry(MessageReceiptStatus.sent, ''),
    );
    return entry.key;
  }
}

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
    this.replyToMessageId,
    this.replyPreview,
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime sentAt;
  final List<String> attachments;
  final List<String> mentions;
  final Map<String, int> reactions;
  final Map<String, MessageReceiptStatus> receipts;
  final String? replyToMessageId;
  final MessageReplyPreview? replyPreview;

  Message copyWith({
    String? body,
    List<String>? attachments,
    List<String>? mentions,
    Map<String, int>? reactions,
    Map<String, MessageReceiptStatus>? receipts,
    String? replyToMessageId,
    MessageReplyPreview? replyPreview,
  }) => Message(
    id: id,
    authorId: authorId,
    body: body ?? this.body,
    sentAt: sentAt,
    attachments: attachments ?? this.attachments,
    mentions: mentions ?? this.mentions,
    reactions: reactions ?? this.reactions,
    receipts: receipts ?? this.receipts,
    replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    replyPreview: replyPreview ?? this.replyPreview,
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
    replyToMessageId,
    replyPreview,
  ];

  factory Message.fromJson(JsonMap json) => Message(
    id: json['id'] as String,
    authorId: json['author_id'] as String? ?? '',
    body: json['body'] as String? ?? '',
    sentAt: _parseDate(json['sent_at']) ?? DateTime.now(),
    attachments: _stringList(json['attachments']),
    mentions: _stringList(json['mentions']),
    reactions: _reactionsMap(json['reactions']),
    receipts: _receiptsMap(json['receipts']),
    replyToMessageId: json['reply_to_message_id'] as String?,
    replyPreview: json['reply_preview'] == null
        ? null
        : MessageReplyPreview.fromJson(json['reply_preview']),
  );

  JsonMap toJson() => {
    'id': id,
    'author_id': authorId,
    'body': body,
    'sent_at': sentAt.toIso8601String(),
    'attachments': attachments,
    'mentions': mentions,
    'reactions': reactions,
    'receipts': receipts.map((key, value) => MapEntry(key, value.storageValue)),
    'reply_to_message_id': replyToMessageId,
    'reply_preview': replyPreview?.toJson(),
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

List<String> _stringList(dynamic source) {
  if (source is List) {
    return source.whereType<String>().toList(growable: false);
  }
  return const [];
}

Map<String, int> _reactionsMap(dynamic source) {
  if (source is Map) {
    return source.map((key, value) {
      if (value is num) {
        return MapEntry(key.toString(), value.toInt());
      }
      return MapEntry(key.toString(), 0);
    });
  }
  return const {};
}

Map<String, MessageReceiptStatus> _receiptsMap(dynamic source) {
  if (source is Map) {
    return source.map((key, value) {
      final resolved = MessageReceiptStatusMapper.fromStorage(value as String?);
      return MapEntry(key.toString(), resolved);
    });
  }
  return const {};
}
