import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:myapp/common/models/plan_package.dart';
import 'package:myapp/common/models/user.dart';

class UserController extends ChangeNotifier {
  UserController({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  UserPlanState _planState = UserPlanState(
    activePackage: PlanCatalog.generalFree,
  );

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserPlanState get planState {
    _ensurePlanFreshness();
    return _planState;
  }

  PlanPackage get activePlan => planState.activePackage;
  bool get hasPremiumAccess => planState.hasPremiumAccess;

  bool canCreateProject(int ownedProjects) {
    final limit = planState.projectLimit;
    if (limit == null) {
      return true;
    }
    return ownedProjects < limit;
  }

  bool canCreateDocument(int createdDocuments) {
    final limit = planState.documentLimit;
    if (limit == null) {
      return true;
    }
    return createdDocuments < limit;
  }

  Future<void> activateProTrial({
    Duration duration = const Duration(days: 1),
  }) async {
    _planState = UserPlanState(
      activePackage: PlanCatalog.generalPro,
      trialEndsAt: DateTime.now().add(duration),
    );
    notifyListeners();
  }

  void _ensurePlanFreshness() {
    final expiry = _planState.trialEndsAt;
    if (expiry == null) {
      return;
    }
    if (expiry.isAfter(DateTime.now())) {
      return;
    }
    if (_planState.activePackage.id == PlanCatalog.generalFree.id &&
        _planState.trialEndsAt == null) {
      return;
    }
    if (_planState.activePackage.id == PlanCatalog.generalFree.id) {
      // Just drop the trial marker.
      _planState = UserPlanState(activePackage: PlanCatalog.generalFree);
    } else {
      _planState = UserPlanState(activePackage: PlanCatalog.generalFree);
    }
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      _profile = null;
      _errorMessage = null;
      if (_isLoading) {
        _isLoading = false;
      }
      notifyListeners();
      return;
    }

    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final result = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (result is Map<String, dynamic>) {
        _profile = UserProfile.fromMap(result);
      } else {
        final authUser = _client.auth.currentUser;
        if (authUser != null) {
          _profile = UserProfile.fromAuthUser(authUser);
        }
      }
      _errorMessage = null;
    } catch (error, stackTrace) {
      _errorMessage = 'Unable to load profile';
      debugPrint('UserController.loadProfile failed: $error');
      debugPrint('$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadProfile();

  void clear() {
    _profile = null;
    _errorMessage = null;
    if (_isLoading) {
      _isLoading = false;
    }
    _planState = UserPlanState(activePackage: PlanCatalog.generalFree);
    notifyListeners();
  }
}

class UserPlanState {
  const UserPlanState({required this.activePackage, this.trialEndsAt});

  final PlanPackage activePackage;
  final DateTime? trialEndsAt;

  bool get isTrialActive =>
      trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());

  bool get hasPremiumAccess => !activePackage.isFree || isTrialActive;

  int? get projectLimit => hasPremiumAccess ? null : activePackage.maxProjects;

  int? get documentLimit =>
      hasPremiumAccess ? null : activePackage.maxDocuments;
}
