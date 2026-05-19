import 'package:flutter/foundation.dart';
import 'package:my_app/Api/faq_api.dart';
import 'package:my_app/Models/faq_models.dart';

class FaqProvider extends ChangeNotifier {
  List<FaqModel> _faqList = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────
  List<FaqModel> get faqList => _faqList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Published items sorted by display_order
  List<FaqModel> get publishedFaqs => _faqList
      .where((e) => e.status == 'published')
      .toList()
    ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

  // ── Fetch FAQ ────────────────────────────────────────────
  Future<void> fetchFaq() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _faqList = await FaqApiService.fetchFaq();
      _faqList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearError() {
    _error = null;
    notifyListeners();
  }

}