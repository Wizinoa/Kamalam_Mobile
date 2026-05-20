// ignore_for_file: unused_field

import 'package:flutter/foundation.dart';
import 'package:my_app/Api/terms_api.dart';
import 'package:my_app/Models/terms_models.dart';


class TermsProvider extends ChangeNotifier {
  TermsProvider({TermsApiService? apiService})
      : _api = apiService ?? TermsApiService();

  final TermsApiService _api;

  List<TermsModel> _termsList = [];
  List<TermsModel> _privacyList = [];

  bool _isLoadingTerms = false;
  bool _isLoadingPrivacy = false;

  String? _termsError;
  String? _privacyError;

  // ── Getters ──────────────────────────────────────────────
  List<TermsModel> get termsList => _termsList;
  List<TermsModel> get privacyList => _privacyList;

  bool get isLoadingTerms => _isLoadingTerms;
  bool get isLoadingPrivacy => _isLoadingPrivacy;
  bool get isLoading => _isLoadingTerms || _isLoadingPrivacy;

  String? get termsError => _termsError;
  String? get privacyError => _privacyError;

  // First published item with lowest display_order
  TermsModel? get activeTerms => _firstPublished(_termsList);
  TermsModel? get activePrivacy => _firstPublished(_privacyList);

  TermsModel? _firstPublished(List<TermsModel> list) =>
      list
          .where((e) => e.status == 'published')
          .toList()
          .fold<TermsModel?>(null, (prev, e) =>
              prev == null || e.displayOrder < prev.displayOrder ? e : prev);

  // ── Fetch Terms ──────────────────────────────────────────
  Future<void> fetchTerms() async {
    _isLoadingTerms = true;
    _termsError = null;
    notifyListeners();

    try {
      _termsList = await TermsApiService.fetchTerms();
      _termsList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    } catch (e) {
      _termsError = _friendlyError(e);
    } finally {
      _isLoadingTerms = false;
      notifyListeners();
    }
  }

  // ── Fetch Privacy ────────────────────────────────────────
  Future<void> fetchPrivacy() async {
    _isLoadingPrivacy = true;
    _privacyError = null;
    notifyListeners();

    try {
      _privacyList = await TermsApiService.fetchPrivacy();
      _privacyList.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    } catch (e) {
      _privacyError = _friendlyError(e);
    } finally {
      _isLoadingPrivacy = false;
      notifyListeners();
    }
  }

  // ── Fetch Both ───────────────────────────────────────────
  Future<void> fetchAll() async {
    await Future.wait([fetchTerms(), fetchPrivacy()]);
  }

  void clearErrors() {
    _termsError = null;
    _privacyError = null;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('connection')) {
      return 'Could not connect. Please try again.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    // Strip "Exception:" prefix if present
    return msg.replaceFirst('Exception: ', '');
  }
}