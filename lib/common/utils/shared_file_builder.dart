import 'package:intl/intl.dart';

import 'package:myapp/common/models/shared_file_record.dart';
import 'package:myapp/controllers/project_controller.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/models/project.dart';

/// Public representation of a file shared within the workspace.
class SharedFileSummary {
  const SharedFileSummary({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.sizeLabel,
    required this.uploadedAt,
    required this.timestampLabel,
    required this.uploader,
    required this.projectName,
    required this.origin,
    this.projectId,
  });

  final String id;
  final String name;
  final String url;
  final SharedFileCategory category;
  final String sizeLabel;
  final DateTime uploadedAt;
  final String timestampLabel;
  final String uploader;
  final String projectName;
  final SharedFileOrigin origin;
  final String? projectId;
}

enum SharedFileCategory { pdf, image, spreadsheet }

extension SharedFileCategoryLabel on SharedFileCategory {
  String label(AppLocalizations loc) => switch (this) {
    SharedFileCategory.pdf => loc.sharedFilesFilterPdf,
    SharedFileCategory.image => loc.sharedFilesFilterImage,
    SharedFileCategory.spreadsheet => loc.sharedFilesFilterSpreadsheet,
  };
}

class SharedFileAggregator {
  SharedFileAggregator({
    required ProjectController controller,
    required AppLocalizations loc,
  }) : _controller = controller,
       _loc = loc,
       _viewerId = controller.currentUserId;

  final ProjectController _controller;
  final AppLocalizations _loc;
  final String? _viewerId;

  List<SharedFileSummary> build({String? projectId}) {
    final projects = {
      for (final project in _controller.projects) project.id: project,
    };
    final records = projectId == null
        ? _controller.sharedFiles
        : _controller.sharedFiles
              .where((record) => record.projectId == projectId)
              .toList(growable: false);

    final summaries = records
        .map((record) => _toSummary(record, projects))
        .toList(growable: false);
    summaries.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return summaries;
  }

  SharedFileSummary _toSummary(
    SharedFileRecord record,
    Map<String, Project> projects,
  ) {
    final projectLabel =
        record.projectName ??
        (record.projectId != null ? projects[record.projectId!]?.name : null) ??
        _loc.sharedFilesWorkspaceLibrary;
    final uploaderLabel = _viewerId != null && record.uploaderId == _viewerId
        ? _loc.homeAuthorYou
        : record.uploaderName;

    return SharedFileSummary(
      id: record.id,
      name: record.fileName,
      url: record.fileUrl,
      projectId: record.projectId,
      category: _resolveCategory(
        filename: record.fileName,
        contentType: record.contentType,
      ),
      sizeLabel: _formatSize(record.sizeBytes),
      uploadedAt: record.uploadedAt,
      timestampLabel: _formatTimestamp(record.uploadedAt),
      uploader: uploaderLabel,
      projectName: projectLabel,
      origin: record.origin,
    );
  }

  SharedFileCategory _resolveCategory({
    required String filename,
    required String contentType,
  }) {
    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';
    final mime = contentType.toLowerCase();
    if (extension == 'pdf' ||
        extension == 'doc' ||
        extension == 'docx' ||
        mime.contains('pdf') ||
        mime.contains('msword') ||
        mime.contains('officedocument')) {
      return SharedFileCategory.pdf;
    }
    if (<String>{
          'png',
          'jpg',
          'jpeg',
          'gif',
          'webp',
          'heic',
        }.contains(extension) ||
        mime.startsWith('image/')) {
      return SharedFileCategory.image;
    }
    if (<String>{'xls', 'xlsx', 'csv', 'ods'}.contains(extension) ||
        mime.contains('spreadsheet') ||
        mime.contains('excel')) {
      return SharedFileCategory.spreadsheet;
    }
    return SharedFileCategory.pdf;
  }

  String _formatSize(int sizeBytes) {
    if (sizeBytes <= 0) {
      return '0 KB';
    }
    const int kb = 1024;
    const int mb = kb * 1024;
    if (sizeBytes >= mb) {
      final value = sizeBytes / mb;
      return '${value.toStringAsFixed(value >= 10 ? 1 : 2)} MB';
    }
    if (sizeBytes >= kb) {
      final value = sizeBytes / kb;
      return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} KB';
    }
    return '$sizeBytes B';
  }

  String _formatTimestamp(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    final now = DateTime.now();
    final bool sameYear = localDate.year == now.year;
    final pattern = sameYear ? 'MMM d • HH:mm' : 'MMM d, yyyy • HH:mm';
    return DateFormat(pattern, _loc.localeName).format(localDate);
  }
}
