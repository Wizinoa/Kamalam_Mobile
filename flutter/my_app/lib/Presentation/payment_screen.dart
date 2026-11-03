// ignore_for_file: prefer_function_declarations_over_variables, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Presentation/passbook_screen.dart';
import 'package:my_app/Presentation/terms_and_conditions.dart';
import 'package:my_app/Providers/gold_Provider.dart';
import 'package:my_app/Providers/payment_provider.dart';
import 'package:my_app/Providers/scheme_provider.dart';
import 'package:my_app/Utils/local_storage.dart';
import 'package:my_app/Utils/razar_pay.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DidigoldScreen extends StatefulWidget {
  const DidigoldScreen({
    super.key,
    this.isSilverScheme = false,
    required this.schemeId,
    required this.name,
    this.maturityDate,
    this.purity,
  });

  final bool isSilverScheme;
  final String schemeId;
  final String name;
  final DateTime? maturityDate;

  /// Optional: "18k" / "22k" / "24k". If it is not passed, the purity is read
  /// from the scheme (found by [schemeId]) and falls back to 22k.
  final String? purity;

  @override
  State<DidigoldScreen> createState() => _DidigoldScreenState();
}

class _DidigoldScreenState extends State<DidigoldScreen> {
  double _weight = 0;
  int _amount = 0;
  int _minDailyDeposit = 100;
  bool _agreed = false;
  bool _isAmountMode = true;
  bool _isProcessing = false; // ✅ prevent double tap
  final RazorPayService _razorPayService = RazorPayService();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _schemeController = TextEditingController();
  static const String _razorpayKey = 'rzp_live_TqtjPFxl6JQjSM';
  static const double _gstRate = 0.03; // 3% GST

  // ✅ The gold rate from the API is for 22 carat.
  // 18K / 24K rates are calculated from it: rate22 * karat / 22.
  static const int _baseKarat = 22;
  int _karat = 22; // carat of THIS scheme (18 / 22 / 24)

  String get _schemeName => widget.isSilverScheme ? 'DigiSilver' : 'DigiGold';

  // ✅ Defaults for the Anytime scheme when there is no backend scheme
  int get _fallbackMinDeposit => widget.isSilverScheme ? 500 : 5000;

  // ✅ Bigger +/- step when the minimum deposit is large
  int get _amountStep => _minDailyDeposit >= 1000 ? 500 : 100;

  // ============================================================
  // RATE (carat based)
  // ============================================================

  /// Rate per gram for THIS scheme:
  /// silver -> silver rate, gold -> 22K rate converted to the scheme's carat.
  double _rateFrom(double goldBase22, double silverBase) {
    if (widget.isSilverScheme) return silverBase;
    return goldBase22 * _karat / _baseKarat;
  }

  double get _currentRate {
    final provider = Provider.of<GoldPriceProvider>(context, listen: false);
    return _rateFrom(
      provider.goldData?.sellPrice.toDouble() ?? 0,
      provider.silverData?.sellPrice.toDouble() ?? 0,
    );
  }

  /// "18k" / "22K" / "24 carat" -> 18 / 22 / 24 (default 22).
  static int _karatFromPurity(String? purity) {
    final m = RegExp(r'\d+').firstMatch(purity ?? '');
    final k = int.tryParse(m?.group(0) ?? '');
    if (k == 18 || k == 22 || k == 24) return k!;
    return _baseKarat;
  }

  String formatIndianCurrency(num number) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(number);
  }

  // ============================================================
  // SCHEME LOOKUP / INIT
  // ============================================================

  /// Finds this screen's scheme. Returns null for an empty / unknown id
  /// (e.g. the default Anytime card) instead of throwing.
  dynamic _findSchemeById(SchemeProvider provider) {
    if (widget.schemeId.isEmpty) return null;
    for (final s in provider.schemes) {
      if (s.id == widget.schemeId) return s;
    }
    return null;
  }

  String? _purityOf(dynamic scheme) {
    if (scheme == null) return null;
    try {
      return scheme.purity as String?;
    } catch (_) {
      return null; // model has no purity field
    }
  }

  int _minOf(dynamic scheme) {
    if (scheme != null && (scheme.minDailyDeposit ?? 0) > 0) {
      return (scheme.minDailyDeposit as num).toInt();
    }
    return _fallbackMinDeposit;
  }

  /// Sets carat / minimum / amount / text field synchronously (no setState).
  void _applySchemeDefaults(dynamic scheme) {
    _karat = widget.isSilverScheme
        ? _baseKarat
        : _karatFromPurity(widget.purity ?? _purityOf(scheme));
    final min = _minOf(scheme);
    _minDailyDeposit = min;
    _amount = min;
    _controller.text =
        _isAmountMode ? _amount.toString() : _weight.toStringAsFixed(3);
  }

  @override
  void initState() {
    super.initState();

    // ✅ Use what HomeScreen already loaded, so the right carat and minimum
    // are shown immediately (no flicker from 22K to 18K).
    final scheme = _findSchemeById(context.read<SchemeProvider>());
    _applySchemeDefaults(scheme);

    Future.microtask(_loadInitialData);
  }

  Future<void> _loadInitialData() async {
    final goldProvider = Provider.of<GoldPriceProvider>(
      context,
      listen: false,
    );
    final schemeProvider = Provider.of<SchemeProvider>(
      context,
      listen: false,
    );

    try {
      await goldProvider.fetchGoldPrice();
      await schemeProvider.fetchSchemes();
    } catch (_) {
      // keep the defaults if the network call fails
    }
    if (!mounted) return;

    final scheme = _findSchemeById(schemeProvider);

    // carat first - the rate depends on it
    _karat = widget.isSilverScheme
        ? _baseKarat
        : _karatFromPurity(widget.purity ?? _purityOf(scheme));
    final int minDeposit = _minOf(scheme);
    final double rate = _currentRate;

    setState(() {
      _minDailyDeposit = minDeposit;
      _amount = minDeposit;
      _weight = rate > 0 ? minDeposit / rate : 0;
      _controller.text =
          _isAmountMode ? _amount.toString() : _weight.toStringAsFixed(3);
    });
  }

  @override
  void dispose() {
    _razorPayService.dispose();
    _controller.dispose();
    _schemeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // AMOUNT / WEIGHT HELPERS
  // ============================================================

  void _decrementWeight() {
    setState(() {
      if (_isAmountMode) {
        if (_amount <= _minDailyDeposit) return;
        _amount -= _amountStep;
        if (_amount < _minDailyDeposit) _amount = _minDailyDeposit;
        _controller.text = _amount.toString();
      } else {
        double newWeight = _weight - 0.001;
        int calculatedAmount = (newWeight * _currentRate).round();
        if (calculatedAmount < _minDailyDeposit) return;
        _weight = newWeight;
        _controller.text = _weight.toStringAsFixed(3);
      }
    });
  }

  void _incrementWeight() {
    setState(() {
      if (_isAmountMode) {
        _amount += _amountStep;
        _controller.text = _amount.toString();
      } else {
        _weight += 0.001;
        _controller.text = _weight.toStringAsFixed(3);
      }
    });
  }

  /// ✅ Clamp the typed value to the minimum AFTER the user finishes typing.
  /// (Clamping on every keystroke makes it impossible to type e.g. 7000
  /// when the minimum is 5000, because "7" would instantly become 5000.)
  void _enforceMinimum() {
    setState(() {
      if (_isAmountMode) {
        if (_amount < _minDailyDeposit) _amount = _minDailyDeposit;
        _controller.text = _amount.toString();
      } else {
        if (_currentRate > 0) {
          final calculatedAmount = (_weight * _currentRate).round();
          if (calculatedAmount < _minDailyDeposit) {
            _weight = _minDailyDeposit / _currentRate;
          }
        }
        _controller.text = _weight.toStringAsFixed(3);
      }
    });
    FocusScope.of(context).unfocus();
  }

  // ✅ Calculate net weight after deducting 3% GST
  String _receiveWeightFromAmount() {
    if (_currentRate == 0) return "0 g";

    // Calculate gross weight from amount (at THIS scheme's carat rate)
    final grossGrams = _amount / _currentRate;

    // Deduct 3% GST from the weight
    final netGrams = grossGrams * (1 - _gstRate);

    return '${netGrams.toStringAsFixed(4)} g';
  }

  // ✅ Calculate net weight when user enters weight directly (after GST deduction)
  String _getNetWeightFromGrossWeight() {
    if (_currentRate == 0) return "0 g";

    // Deduct 3% GST from the entered weight
    final netGrams = _weight * (1 - _gstRate);

    return '${netGrams.toStringAsFixed(4)} g';
  }

  // ✅ Get the gross weight before GST deduction
  String _getGrossWeightForDisplay() {
    if (_isAmountMode) {
      // In amount mode, calculate from amount
      if (_currentRate == 0) return "0 g";
      final grossGrams = _amount / _currentRate;
      return '${grossGrams.toStringAsFixed(4)} g';
    } else {
      // In weight mode, show the entered weight as gross weight
      return '${_weight.toStringAsFixed(4)} g';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    const double overallPadding = 20;

    final p = (double s, FontWeight w, Color c) =>
        GoogleFonts.poppins(fontSize: s, fontWeight: w, color: c, height: 1.2);

    return Consumer<GoldPriceProvider>(
      builder: (context, provider, child) {
        final gold = provider.goldData;
        final silver = provider.silverData;

        final double goldRate = gold?.sellPrice.toDouble() ?? 0.0;
        final double silverRate = silver?.sellPrice.toDouble() ?? 0.0;

        // ✅ Rate of THIS scheme's carat (18K scheme -> 18K rate)
        final currentRate = _rateFrom(goldRate, silverRate);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(128),
            child: AppBar(
              toolbarHeight: 100,
              automaticallyImplyLeading: false,
              flexibleSpace: SafeArea(
                bottom: false,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF3A0A13), Color(0xFFC6003A)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Join $_schemeName Scheme',
                                  textAlign: TextAlign.center,
                                  style: p(18, FontWeight.w600, Colors.white),
                                ),
                              ),
                              const SizedBox(width: 30),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You are just one step away from starting your dream jewellery journey',
                            textAlign: TextAlign.center,
                            style: p(12, FontWeight.w400, Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: -22,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF6EAC1),
                              ),
                              child: const Icon(
                                Icons.currency_rupee,
                                size: 16,
                                color: Color(0xFFB8860B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.isSilverScheme
                                        ? 'Silver Rate'
                                        : 'Gold Rate - ${_karat}KT',
                                    style: p(
                                      10.5,
                                      FontWeight.w400,
                                      const Color(0xFF666666),
                                    ),
                                  ),
                                  provider.isLoading
                                      ? const Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: CircularProgressIndicator(),
                                        )
                                      : Text(
                                          '₹${formatIndianCurrency(currentRate)} /gram',
                                          style: p(
                                            14,
                                            FontWeight.w700,
                                            const Color(0xFF2E2E2E),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Today',
                                  style: p(
                                    9,
                                    FontWeight.w400,
                                    Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(DateTime.now()),
                                  style: p(
                                    8.5,
                                    FontWeight.w400,
                                    Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      overallPadding,
                      0,
                      overallPadding,
                      overallPadding,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E6E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAmountMode = true;
                                        _controller.text = _amount.toString();
                                      });
                                    },
                                    child: Container(
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _isAmountMode
                                            ? const Color(0xFF6A0020)
                                            : const Color(0xFFE6E6E6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Amount (₹)',
                                          style: p(
                                            10.5,
                                            FontWeight.w600,
                                            _isAmountMode
                                                ? Colors.white
                                                : const Color(0xFF6D6D6D),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAmountMode = false;
                                        // ✅ keep weight in sync with the amount
                                        if (_currentRate > 0) {
                                          _weight = _amount / _currentRate;
                                        }
                                        _controller.text = _weight
                                            .toStringAsFixed(3);
                                      });
                                    },
                                    child: Container(
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _isAmountMode
                                            ? const Color(0xFFE6E6E6)
                                            : const Color(0xFF6A0020),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Weight (g)',
                                          style: p(
                                            10.5,
                                            FontWeight.w600,
                                            _isAmountMode
                                                ? const Color(0xFF6D6D6D)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          constraints: const BoxConstraints(minHeight: 190),
                          padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                          decoration: BoxDecoration(
                            color: _isAmountMode
                                ? const Color(0xFFF1ECDA)
                                : const Color(0xFFF2EDD8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isAmountMode
                                  ? const Color(0xFFE4D7AD)
                                  : const Color(0x00000000),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _isAmountMode ? 'Enter Amount' : 'Enter Weight',
                                style: p(
                                  14,
                                  FontWeight.w400,
                                  const Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _controller,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      style: p(
                                        34,
                                        FontWeight.w700,
                                        const Color(0xFF2E2E2E),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      onChanged: (value) {
                                        if (value.isEmpty) return;

                                        final double number =
                                            double.tryParse(value) ?? 0.0;

                                        // ✅ Do NOT clamp while typing - the
                                        // minimum is enforced on "done" and on
                                        // Pay Now.
                                        setState(() {
                                          if (_isAmountMode) {
                                            _amount = number.toInt();
                                          } else {
                                            _weight = number;
                                          }
                                        });
                                      },
                                      onEditingComplete: _enforceMinimum,
                                      onTapOutside: (_) {
                                        if (FocusScope.of(
                                          context,
                                        ).hasFocus) {
                                          _enforceMinimum();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isAmountMode ? '₹' : 'g',
                                    style: p(
                                      22,
                                      FontWeight.w600,
                                      _isAmountMode
                                          ? const Color(0xFFC89F2C)
                                          : const Color(0xFFD4AF37),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _decrementWeight,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFE1E1E1),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        size: 22,
                                        color: Color(0xFF7A7A7A),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      indent: 12,
                                      endIndent: 12,
                                      color: Color(0xFFD8D8D8),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _incrementWeight,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isAmountMode
                                            ? const Color(0xFFCDA52F)
                                            : const Color(0xFFD4AF37),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.sync,
                                    size: 12,
                                    color: Color(0xFF9C9C9C),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.isSilverScheme
                                        ? 'Auto-calculated at today\'s silver rate'
                                        : 'Auto-calculated at today\'s ${_karat}KT gold rate',
                                    style: p(
                                      9,
                                      FontWeight.w400,
                                      _isAmountMode
                                          ? const Color(0xFF7B7B7B)
                                          : const Color(0xFF8B8B8B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              // ✅ Show both gross weight and net weight after GST
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Gross Weight',
                                        style: p(
                                          12,
                                          FontWeight.w400,
                                          const Color(0xFF777777),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getGrossWeightForDisplay(),
                                        style: p(
                                          16,
                                          FontWeight.w600,
                                          const Color(0xFF555555),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    width: 1,
                                    height: 40,
                                    color: const Color(0xFFCCCCCC),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'You Receive (After ${(_gstRate * 100).toInt()}% GST)',
                                        style: p(
                                          12,
                                          FontWeight.w400,
                                          const Color(0xFF777777),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isAmountMode
                                            ? _receiveWeightFromAmount()
                                            : _getNetWeightFromGrossWeight(),
                                        style: p(
                                          20,
                                          FontWeight.w700,
                                          const Color(0xFF2E2E2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE6E6E6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scheme Nickname',
                                style: p(
                                  10.5,
                                  FontWeight.w400,
                                  const Color(0xFF7A7A7A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 34,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: TextField(
                                  controller: _schemeController,
                                  style: p(
                                    10.5,
                                    FontWeight.w500,
                                    const Color(0xFF2E2E2E),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.name,
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFF0DB9A),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Maturity date',
                                          style: p(
                                            12,
                                            FontWeight.w600,
                                            const Color(0xFF434343),
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD4AF37),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            widget.maturityDate != null
                                                ? DateFormat(
                                                    'dd MMM yyyy',
                                                  ).format(widget.maturityDate!)
                                                : '-',
                                            style: p(
                                              8.5,
                                              FontWeight.w600,
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Your investment will mature in 12 months with\nguaranteed returns',
                                      style: p(
                                        9.5,
                                        FontWeight.w400,
                                        const Color(0xFF7B7B7B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5F8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFF1CBD8),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Color(0xFFB00034),
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '*Gold Rates Are Subject To Market Fluctuations.\nBonus Percentage May Vary Based On Scheme\nDuration And Market Conditions.\n*3% GST will be deducted from the weight.',
                                        style: p(
                                          9,
                                          FontWeight.w400,
                                          const Color(0xFF7B7B7B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.05,
                              child: Checkbox(
                                value: _agreed,
                                onChanged: (value) =>
                                    setState(() => _agreed = value ?? false),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF979797),
                                ),
                                activeColor: const Color(0xFF6A0020),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: p(
                                        10,
                                        FontWeight.w400,
                                        const Color(0xFF787878),
                                      ),
                                    ),

                                    /// Terms & Conditions
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style:
                                          p(
                                            10,
                                            FontWeight.w500,
                                            const Color(0xFFD4AF37),
                                          ).copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TermsAndConditionsScreen(),
                                            ),
                                          );
                                        },
                                    ),

                                    TextSpan(
                                      text: ' and\n',
                                      style: p(
                                        10,
                                        FontWeight.w400,
                                        const Color(0xFF787878),
                                      ),
                                    ),

                                    /// Privacy Policy
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style:
                                          p(
                                            10,
                                            FontWeight.w500,
                                            const Color(0xFFD4AF37),
                                          ).copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const TermsAndConditionsScreen(),
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isProcessing
                                        ? [Colors.grey, Colors.grey]
                                        : [
                                            const Color(0xFF3A0013),
                                            const Color(0xFFD1004C),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : _openRazorpayCheckout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  child: _isProcessing
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Pay Now',
                                          style: p(
                                            10,
                                            FontWeight.w600,
                                            Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6A0020),
                                  side: const BorderSide(
                                    color: Color(0xFFD1004C),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  minimumSize: const Size.fromHeight(44),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: p(
                                    14,
                                    FontWeight.w500,
                                    const Color(0xFF6A0020),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  // ✅ STEP 1: Create order on backend FIRST, then open Razorpay
  void _openRazorpayCheckout() async {
    if (!_agreed) {
      _showMessage("Please accept Terms & Conditions");
      return;
    }

    if (_isProcessing) return; // prevent double tap

    int finalAmount = _isAmountMode
        ? _amount
        : (_weight * _currentRate).round();

    if (finalAmount <= 0) {
      _showMessage("Please enter valid amount");
      return;
    }

    // ✅ Minimum is enforced here too (not while typing)
    if (finalAmount < _minDailyDeposit) {
      _showMessage(
        "Minimum amount is ₹${formatIndianCurrency(_minDailyDeposit)}",
      );
      return;
    }

    setState(() => _isProcessing = true);

    final paymentProvider = context.read<PaymentProvider>();

    // ✅ Call backend /deposit/create — this creates Razorpay order + deposit record
    final orderData = await paymentProvider.createPayment(
      amount: finalAmount.toString(),
      paymentMethod: "upi",
      schemeId: widget.schemeId,
    );

    setState(() => _isProcessing = false);

    if (orderData == null) {
      _showMessage("Failed to create order. Try again.");
      return;
    }

    // ✅ Backend returns: { success: true, order: { id: "order_xxx", ... }, deposit: {...} }
    final razorpayOrderId = orderData['order']?['id'] as String?;

    if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
      _showMessage("Invalid order response from server.");
      return;
    }

    final schemeName = _schemeController.text.trim();
    final String email = await LocalStorage.getEmail() ?? '';

    // ✅ STEP 2: Open Razorpay with the real order_id from backend
    _razorPayService.openCheckout(
      amountInRupees: finalAmount,
      key: _razorpayKey,
      name: widget.name,
      id: razorpayOrderId, // ← real Razorpay order ID, NOT widget.schemeId
      description: '$schemeName Scheme Payment',
      prefillContact: '',
      prefillEmail: email,
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
      onPluginError: _showMessage,
    );
  }

  // ✅ STEP 3: Razorpay returns all 3 values — verify with backend
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _showMessage("Payment Successful...");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PassbookScreen()),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showMessage('Payment failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showMessage('External wallet selected: ${response.walletName ?? ''}');
  }
}