import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/models/crm_contact.dart';

class CrmDataService {
  CrmDataService(this._client);

  final SupabaseClient _client;

  static const String _contactsTable = 'crm_contacts';

  Future<List<CrmContact>> fetchContacts(String ownerId) async {
    final response = await _client
        .from(_contactsTable)
        .select()
        .eq('owner_id', ownerId)
        .order('updated_at', ascending: false);
    return (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(CrmContact.fromJson)
        .toList(growable: false);
  }

  Future<CrmContact> createContact(
    CrmContact contact, {
    required String ownerId,
  }) async {
    final payload = contact.toJson()..addAll({'owner_id': ownerId});
    final record = await _client
        .from(_contactsTable)
        .insert(payload)
        .select()
        .single();
    return CrmContact.fromJson(record);
  }

  Future<CrmContact> updateContact(CrmContact contact) async {
    final updated = contact.copyWith(updatedAt: DateTime.now());
    final record = await _client
        .from(_contactsTable)
        .update(updated.toJson())
        .eq('id', contact.id)
        .select()
        .single();
    return CrmContact.fromJson(record);
  }

  Future<void> deleteContact(String contactId) async {
    await _client.from(_contactsTable).delete().eq('id', contactId);
  }
}
