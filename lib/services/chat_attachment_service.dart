import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadedAttachment {
  const UploadedAttachment({
    required this.url,
    required this.name,
    required this.sizeBytes,
    required this.contentType,
  });

  final String url;
  final String name;
  final int sizeBytes;
  final String contentType;
}

enum ChatAttachmentSource { photoLibrary, camera, document, pdf }

typedef _FilePickerInvoker =
    Future<FilePickerResult?> Function({
      bool allowMultiple,
      bool withData,
      FileType type,
      List<String>? allowedExtensions,
    });

class ChatAttachmentService {
  ChatAttachmentService({ImagePicker? imagePicker, SupabaseClient? client})
    : _imagePicker = imagePicker ?? ImagePicker(),
      _client = client ?? Supabase.instance.client,
      _pickFiles = FilePicker.platform.pickFiles;

  final ImagePicker _imagePicker;
  final SupabaseClient _client;
  final _FilePickerInvoker _pickFiles;

  static const String _bucketName = 'chat-attachments';
  static const String _folderPrefix = 'messages';

  Future<UploadedAttachment?> pickAndUpload(ChatAttachmentSource source) async {
    switch (source) {
      case ChatAttachmentSource.photoLibrary:
        return _pickFromGallery();
      case ChatAttachmentSource.camera:
        return _pickFromCamera();
      case ChatAttachmentSource.document:
        return _pickDocument();
      case ChatAttachmentSource.pdf:
        return _pickPdf();
    }
  }

  Future<UploadedAttachment?> _pickFromGallery() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return null;
    }
    return _uploadXFile(file);
  }

  Future<UploadedAttachment?> _pickFromCamera() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file == null) {
      return null;
    }
    return _uploadXFile(file);
  }

  Future<UploadedAttachment?> _pickDocument() async {
    final result = await _pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return _uploadPlatformFile(result.files.single);
  }

  Future<UploadedAttachment?> _pickPdf() async {
    final result = await _pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return _uploadPlatformFile(result.files.single);
  }

  Future<UploadedAttachment> _uploadXFile(XFile source) async {
    final bytes = await source.readAsBytes();
    final name = source.name.isEmpty ? 'attachment.jpg' : source.name;
    final mimeType =
        lookupMimeType(name, headerBytes: bytes) ?? 'application/octet-stream';
    return _uploadBytes(
      bytes: bytes,
      originalName: name,
      contentType: mimeType,
    );
  }

  Future<UploadedAttachment> _uploadPlatformFile(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Unable to read file bytes.');
    }
    final name = file.name.isEmpty ? 'attachment.bin' : file.name;
    final mimeType =
        lookupMimeType(name, headerBytes: bytes) ?? 'application/octet-stream';
    return _uploadBytes(
      bytes: bytes,
      originalName: name,
      contentType: mimeType,
    );
  }

  Future<UploadedAttachment> _uploadBytes({
    required Uint8List bytes,
    required String originalName,
    required String contentType,
  }) async {
    final displayName = originalName.trim().isEmpty
        ? 'attachment-${DateTime.now().millisecondsSinceEpoch}.bin'
        : originalName.trim();
    final sanitizedName = _sanitizeFileName(displayName);
    final objectPath = _buildObjectPath(sanitizedName);
    final bucket = _client.storage.from(_bucketName);
    try {
      await bucket.uploadBinary(
        objectPath,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );
    } on StorageException catch (error, stackTrace) {
      debugPrint('Attachment upload failed: ${error.message}\n$stackTrace');
      rethrow;
    }
    final publicUrl = bucket.getPublicUrl(objectPath);
    return UploadedAttachment(
      url: publicUrl,
      name: displayName,
      sizeBytes: bytes.lengthInBytes,
      contentType: contentType,
    );
  }

  String _buildObjectPath(String sanitizedName) {
    final userId = _client.auth.currentUser?.id ?? 'anonymous';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$_folderPrefix/$userId/$timestamp-$sanitizedName';
  }

  String _sanitizeFileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'attachment-${DateTime.now().millisecondsSinceEpoch}.bin';
    }
    return trimmed.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }
}
