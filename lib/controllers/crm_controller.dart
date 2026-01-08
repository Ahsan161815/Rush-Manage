import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/common/models/contact_form_models.dart';
import 'package:myapp/models/crm_contact.dart';
import 'package:myapp/services/crm_data_service.dart';

class CrmController extends ChangeNotifier {
  CrmController({required SupabaseClient client, CrmDataService? dataService})
    : _client = client,
      _service = dataService ?? CrmDataService(client);

  final SupabaseClient _client;
  final CrmDataService _service;

  final List<CrmContact> _contacts = [];
  bool _hasInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  List<CrmContact> get contacts => List.unmodifiable(_contacts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_hasInitialized) {
      return;
    }
    if (_client.auth.currentUser?.id == null) {
      return;
    }
    _hasInitialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    final ownerId = _requireUserId();
    _setLoading(true);
    try {
      final data = await _service.fetchContacts(ownerId);
      _contacts
        ..clear()
        ..addAll(data);
      _errorMessage = null;
      notifyListeners();
    } catch (error, stackTrace) {
      _errorMessage = 'Unable to load contacts';
      _logError('refresh', error, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  CrmContact? getById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<CrmContact> createContact(ContactFormData form) async {
    final ownerId = _requireUserId();
    final draft = _contactFromForm(form, id: _generateContactId());
    _contacts.insert(0, draft);
    notifyListeners();
    try {
      final saved = await _service.createContact(draft, ownerId: ownerId);
      _replaceContact(saved);
      return saved;
    } catch (error, stackTrace) {
      _contacts.removeWhere((contact) => contact.id == draft.id);
      notifyListeners();
      _logError('createContact', error, stackTrace);
      rethrow;
    }
  }

  Future<CrmContact> updateContact(
    String contactId,
    ContactFormData form,
  ) async {
    final index = _contacts.indexWhere((contact) => contact.id == contactId);
    if (index == -1) {
      throw StateError('Contact $contactId not found');
    }
    final previous = _contacts[index];
    final next = previous.copyWith(
      name: form.name?.trim().isEmpty == true
          ? previous.name
          : form.name?.trim(),
      email: form.email?.trim().isEmpty == true ? null : form.email?.trim(),
      phone: form.phone?.trim().isEmpty == true ? null : form.phone?.trim(),
      address: form.address?.trim().isEmpty == true
          ? null
          : form.address?.trim(),
      notes: form.notes?.trim().isEmpty == true ? null : form.notes?.trim(),
      type: _typeFromValue(form.type) ?? previous.type,
    );
    _contacts[index] = next;
    notifyListeners();
    try {
      final saved = await _service.updateContact(next);
      _contacts[index] = saved;
      notifyListeners();
      return saved;
    } catch (error, stackTrace) {
      _contacts[index] = previous;
      notifyListeners();
      _logError('updateContact', error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    final index = _contacts.indexWhere((contact) => contact.id == contactId);
    if (index == -1) {
      return;
    }
    final removed = _contacts.removeAt(index);
    notifyListeners();
    try {
      await _service.deleteContact(contactId);
    } catch (error, stackTrace) {
      _contacts.insert(index, removed);
      notifyListeners();
      _logError('deleteContact', error, stackTrace);
      rethrow;
    }
  }

  ContactFormData formDataFor(CrmContact contact) {
    return ContactFormData(
      name: contact.name,
      email: contact.email,
      phone: contact.phone,
      address: contact.address,
      type: contact.type.storageValue,
      notes: contact.notes,
    );
  }

  CrmContact _contactFromForm(ContactFormData form, {required String id}) {
    final type = _typeFromValue(form.type) ?? CrmContactType.client;
    return CrmContact(
      id: id,
      name: (form.name ?? '').trim().isEmpty
          ? 'Untitled contact'
          : form.name!.trim(),
      type: type,
      email: form.email?.trim().isEmpty == true ? null : form.email?.trim(),
      phone: form.phone?.trim().isEmpty == true ? null : form.phone?.trim(),
      address: form.address?.trim().isEmpty == true
          ? null
          : form.address?.trim(),
      notes: form.notes?.trim().isEmpty == true ? null : form.notes?.trim(),
    );
  }

  CrmContactType? _typeFromValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == 'client') {
      return CrmContactType.client;
    }
    if (normalized == 'collaborator') {
      return CrmContactType.collaborator;
    }
    if (normalized == 'supplier') {
      return CrmContactType.supplier;
    }
    return null;
  }

  void _replaceContact(CrmContact contact) {
    final index = _contacts.indexWhere((item) => item.id == contact.id);
    if (index == -1) {
      _contacts.insert(0, contact);
    } else {
      _contacts[index] = contact;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void reset() {
    _hasInitialized = false;
    _contacts.clear();
    _errorMessage = null;
    notifyListeners();
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('User not authenticated');
    }
    return userId;
  }

  void _logError(String action, Object error, StackTrace stackTrace) {
    debugPrint('CrmController.$action failed: $error');
    debugPrint(stackTrace.toString());
  }

  String _generateContactId() =>
      'crm${DateTime.now().millisecondsSinceEpoch.toString()}';
}
