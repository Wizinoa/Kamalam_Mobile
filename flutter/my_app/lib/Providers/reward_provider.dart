import 'package:flutter/material.dart';
import 'package:my_app/Api/reward_api.dart';
import 'package:my_app/Models/reward_models.dart';

class RewardProvider extends ChangeNotifier {
  List<RewardModel> _rewards = [];
  bool _isLoading = false;

  List<RewardModel> get rewards => _rewards;
  bool get isLoading => _isLoading;

  Future<void> fetchRewards(String savingsId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _rewards = await RewardApi.getRewards(savingsId);
    } catch (e) {
      debugPrint("Reward Error: $e");
      _rewards = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _rewards = [];
    _isLoading = false; // ← Show spinner immediately, not old data
    notifyListeners();
  }
}