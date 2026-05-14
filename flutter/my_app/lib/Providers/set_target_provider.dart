// ─────────────────────────────────────────────────────────────
//  set_target_provider.dart
// ─────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:my_app/Api/set_target_api.dart';
import 'package:my_app/Models/set_target_models.dart';

class SetTargetProvider extends ChangeNotifier {
  // ── Set target state ──────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Fetch target state ────────────────────────────────────────
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  // One target per asset type, keyed by 'gold' | 'silver'
  final Map<String, SavingsTargetData?> _targets = {
    'gold': null,
    'silver': null,
  };

  SavingsTargetData? targetFor(String assetType) =>
      _targets[assetType.toLowerCase()];

  bool hasTarget(String assetType) =>
      _targets[assetType.toLowerCase()] != null;

  // ── POST: set / update a target ──────────────────────────────
  Future<bool> setTarget(SetTargetModel model) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await SetTargetApi.setTarget(model);
      if (success) {
        // Refresh the fetched target so UI reflects the new one immediately
        await fetchTarget(model.assetType);
      }
      return success;
    } catch (e) {
      debugPrint('SetTargetProvider.setTarget error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── GET: fetch existing target ────────────────────────────────
  Future<void> fetchTarget(String assetType) async {
    final key = assetType.toLowerCase();
    _isFetching = true;
    notifyListeners();
    try {
      final response = await SetTargetApi.getTarget(key);
      _targets[key] = response?.target;
    } catch (e) {
      debugPrint('SetTargetProvider.fetchTarget error: $e');
      _targets[key] = null;
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  // ── Fetch both at once (call on screen open) ──────────────────
  Future<void> fetchAllTargets() async {
    await Future.wait([fetchTarget('gold'), fetchTarget('silver')]);
  }

  void clearTarget(String assetType) {
    _targets[assetType.toLowerCase()] = null;
    notifyListeners();
  }
}