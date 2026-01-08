import 'package:equatable/equatable.dart';

typedef JsonMap = Map<String, dynamic>;

enum SharedFileOrigin { chat, task, library }

extension SharedFileOriginMapper on SharedFileOrigin {
  static const Map<SharedFileOrigin, String> _storage = {
    SharedFileOrigin.chat: 'chat',
    SharedFileOrigin.task: 'task',
    SharedFileOrigin.library: 'library',
  };

  String get storageValue => _storage[this] ?? 'chat';

  static SharedFileOrigin fromStorage(String? value) {
    final normalized = value?.toLowerCase();
    return _storage.entries
        .firstWhere(
          (entry) => entry.value == normalized,
          orElse: () => const MapEntry(SharedFileOrigin.chat, 'chat'),
        )
        .key;
  }
}

class SharedFileRecord extends Equatable {
  const SharedFileRecord({
    required this.id,
    required this.ownerId,
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.origin,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploadedAt,
    this.projectId,
    this.projectName,
  });

  final String id;
  final String ownerId;
  final String fileUrl;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final SharedFileOrigin origin;
  final String uploaderId;
  final String uploaderName;
  final DateTime uploadedAt;
  final String? projectId;
  final String? projectName;

  SharedFileRecord copyWith({
    String? id,
    String? ownerId,
    String? fileUrl,
    String? fileName,
    String? contentType,
    int? sizeBytes,
    SharedFileOrigin? origin,
    String? uploaderId,
    String? uploaderName,
    DateTime? uploadedAt,
    String? projectId,
    String? projectName,
  }) {
    return SharedFileRecord(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      contentType: contentType ?? this.contentType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      origin: origin ?? this.origin,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
    );
  }

  factory SharedFileRecord.fromJson(JsonMap json) {
    return SharedFileRecord(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      contentType:
          json['content_type'] as String? ?? 'application/octet-stream',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      origin: SharedFileOriginMapper.fromStorage(json['origin'] as String?),
      uploaderId: json['uploader_id'] as String? ?? '',
      uploaderName: json['uploader_name'] as String? ?? '',
      uploadedAt: _parseDate(json['uploaded_at']) ?? DateTime.now(),
      projectId: json['project_id'] as String?,
      projectName: json['project_name'] as String?,
    );
  }

  JsonMap toJson() => {
    'id': id,
    'owner_id': ownerId,
    'file_url': fileUrl,
    'file_name': fileName,
    'content_type': contentType,
    'size_bytes': sizeBytes,
    'origin': origin.storageValue,
    'uploader_id': uploaderId,
    'uploader_name': uploaderName,
    'uploaded_at': uploadedAt.toIso8601String(),
    'project_id': projectId,
    'project_name': projectName,
  };

  @override
  List<Object?> get props => [
    id,
    ownerId,
    fileUrl,
    fileName,
    contentType,
    sizeBytes,
    origin,
    uploaderId,
    uploaderName,
    uploadedAt,
    projectId,
    projectName,
  ];
}

class SharedFileDraft {
  const SharedFileDraft({
    required this.fileUrl,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.origin,
    required this.uploaderId,
    required this.uploaderName,
    this.projectId,
    this.projectName,
    this.id,
  });

  final String? id;
  final String fileUrl;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final SharedFileOrigin origin;
  final String uploaderId;
  final String uploaderName;
  final String? projectId;
  final String? projectName;

  JsonMap toInsertPayload({required String ownerId, required String recordId}) {
    return {
      'id': recordId,
      'owner_id': ownerId,
      'file_url': fileUrl,
      'file_name': fileName,
      'content_type': contentType,
      'size_bytes': sizeBytes,
      'origin': origin.storageValue,
      'uploader_id': uploaderId,
      'uploader_name': uploaderName,
      if (projectId != null) 'project_id': projectId,
      if (projectName != null) 'project_name': projectName,
    };
  }
}

DateTime? _parseDate(dynamic source) {
  if (source == null) {
    return null;
  }
  if (source is DateTime) {
    return source;
  }
  if (source is String && source.isNotEmpty) {
    return DateTime.tryParse(source);
  }
  return null;
}
