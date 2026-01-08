import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/models/industry.dart';

class IndustryModuleService {
  IndustryModuleService(this._client);

  final SupabaseClient _client;

  static const String _profileTable = 'user_industry_profiles';
  static const String _extensionsTable = 'project_industry_extensions';

  Future<IndustryProfile> fetchProfile(String ownerId) async {
    final response = await _client
        .from(_profileTable)
        .select()
        .eq('owner_id', ownerId)
        .maybeSingle();

    if (response is Map<String, dynamic>) {
      return IndustryProfile.fromJson(response);
    }
    return const IndustryProfile.core();
  }

  Future<IndustryProfile> upsertProfile({
    required String ownerId,
    required IndustryKey industry,
    bool? isReferenceIndustry,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = <String, dynamic>{
      'owner_id': ownerId,
      'industry': industry.storageValue,
      'is_reference': isReferenceIndustry ?? industry == IndustryKey.caterer,
      'activated_at': now,
      'updated_at': now,
    };

    final response = await _client
        .from(_profileTable)
        .upsert(payload, onConflict: 'owner_id')
        .select()
        .single();
    return IndustryProfile.fromJson(response);
  }

  Future<Map<String, ProjectIndustryExtension>> fetchProjectExtensions({
    required String ownerId,
    required List<String> projectIds,
  }) async {
    if (projectIds.isEmpty) {
      return const {};
    }
    final formattedIds = projectIds.map((id) => '"$id"').join(',');
    final response = await _client
        .from(_extensionsTable)
        .select()
        .eq('owner_id', ownerId)
        .filter('project_id', 'in', '($formattedIds)');
    final extensions = <String, ProjectIndustryExtension>{};
    for (final record in response as List<dynamic>) {
      if (record is! Map<String, dynamic>) {
        continue;
      }
      final projectId = record['project_id'] as String?;
      if (projectId == null) {
        continue;
      }
      final extension = projectExtensionFromRecord(record);
      if (extension == null) {
        continue;
      }
      extensions[projectId] = extension;
    }
    return extensions;
  }

  Future<ProjectIndustryExtension?> upsertProjectExtension({
    required String ownerId,
    required String projectId,
    required ProjectIndustryExtension extension,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final payload = <String, dynamic>{
      'owner_id': ownerId,
      'project_id': projectId,
      'industry': extension.industry.storageValue,
      'payload': extension.toJson(),
      'updated_at': now,
    };

    final response = await _client
        .from(_extensionsTable)
        .upsert(payload, onConflict: 'project_id,industry')
        .select()
        .single();
    return projectExtensionFromRecord(response);
  }
}
