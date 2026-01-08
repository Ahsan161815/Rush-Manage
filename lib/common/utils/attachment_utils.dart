class AttachmentUtils {
  const AttachmentUtils._();

  static String displayName(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      return 'attachment';
    }
    final withoutQuery = trimmed.split('?').first;
    final segments = withoutQuery.split('/');
    final name = segments.isNotEmpty ? segments.last : withoutQuery;
    if (name.isEmpty) {
      return 'attachment';
    }
    return name;
  }

  static String normalizedName(String source) {
    return displayName(source).toLowerCase();
  }
}
