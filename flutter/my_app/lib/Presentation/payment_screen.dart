// ignore_for_file: prefer_function_declarations_over_variables, prefer_final_fields, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Presentation/passbook_screen.dart';
import 'package:my_app/Providers/gold_Provider.dart';
import 'package:my_app/Providers/payment_provider.dart';
import 'package:my_app/Providers/scheme_provider.dart';
import 'package:my_app/Utils/razar_pay.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class DidigoldScreen extends StatefulWidget {
  const DidigoldScreen({
    super.key,
    this.isSilverScheme = false,
    required this.schemeId,
    required this.name,
  });

  final bool isSilverScheme;
  final String schemeId;
  final String name;

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
  static const String _razorpayKey = 'rzp_test_RwfT1KcdoB1A7T';

  String get _schemeName => widget.isSilverScheme ? 'DigiSilver' : 'DigiGold';

  double get _currentRate {
    final provider = Provider.of<GoldPriceProvider>(context, listen: false);
    if (widget.isSilverScheme) {
      return provider.silverData?.sellPrice.toDouble() ?? 0;
    } else {
      return provider.goldData?.sellPrice.toDouble() ?? 0;
    }
  }

  String formatIndianCurrency(num number) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(number);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Provider.of<GoldPriceProvider>(
        context,
        listen: false,
      ).fetchGoldPrice();
      await Provider.of<SchemeProvider>(context, listen: false).fetchSchemes();

      final schemeProvider = Provider.of<SchemeProvider>(
        context,
        listen: false,
      );

      final scheme = schemeProvider.schemes.firstWhere(
        (e) => e.id == widget.schemeId,
      );

      setState(() {
        final minDeposit = scheme.minDailyDeposit;

        final rate = widget.isSilverScheme
            ? Provider.of<GoldPriceProvider>(
                    context,
                    listen: false,
                  ).silverData?.sellPrice.toDouble() ??
                  1
            : Provider.of<GoldPriceProvider>(
                    context,
                    listen: false,
                  ).goldData?.sellPrice.toDouble() ??
                  1;

        final calculatedWeight = minDeposit / rate;

        setState(() {
          _minDailyDeposit = minDeposit;
          _amount = minDeposit;
          _weight = calculatedWeight;
          _controller.text = _isAmountMode
              ? _amount.toString()
              : _weight.toString();
        });

        _controller.text = _amount.toString();
      });
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

  void _decrementWeight() {
    setState(() {
      if (_isAmountMode) {
        if (_amount <= _minDailyDeposit) return;
        _amount -= 100;
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
        _amount += 100;
        _controller.text = _amount.toString();
      } else {
        _weight += 0.001;
        _controller.text = _weight.toStringAsFixed(3);
      }
    });
  }

  String _receiveAmount() {
    final amount = _isAmountMode ? _amount : (_weight * _currentRate).round();
    return "₹${formatIndianCurrency(amount)}";
  }

  String _receiveWeightFromAmount() {
    if (_currentRate == 0) return "0 g";
    final grams = _amount / _currentRate;
    return '${grams.toStringAsFixed(3)} g';
  }

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

    // ✅ STEP 2: Open Razorpay with the real order_id from backend
    _razorPayService.openCheckout(
      amountInRupees: finalAmount,
      key: _razorpayKey,
      name: widget.name,
      id: razorpayOrderId, // ← real Razorpay order ID, NOT widget.schemeId
      description: '$schemeName Scheme Payment',
      prefillContact: '9876543210',
      prefillEmail: 'customer@example.com',
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
        final currentRate = widget.isSilverScheme ? silverRate : goldRate;

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
                                        : 'Gold Rate - 22KT',
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

                                        // ✅ explicitly typed as double
                                        final double number =
                                            double.tryParse(value) ?? 0.0;

                                        setState(() {
                                          if (_isAmountMode) {
                                            // ✅ explicitly typed as int
                                            int enteredAmount = number.toInt();

                                            if (enteredAmount <
                                                _minDailyDeposit) {
                                              enteredAmount = _minDailyDeposit;

                                              _controller.text =
                                                  _minDailyDeposit.toString();

                                              _controller.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset: _controller
                                                          .text
                                                          .length,
                                                    ),
                                                  );
                                            }

                                            _amount = enteredAmount;
                                          } else {
                                            // ✅ explicitly typed as double
                                            double enteredWeight = number;

                                            // ✅ explicitly typed as int
                                            int calculatedAmount =
                                                (enteredWeight * _currentRate)
                                                    .round();

                                            if (calculatedAmount <
                                                _minDailyDeposit) {
                                              enteredWeight =
                                                  _minDailyDeposit /
                                                  _currentRate;

                                              _controller.text = enteredWeight
                                                  .toStringAsFixed(3);

                                              _controller.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset: _controller
                                                          .text
                                                          .length,
                                                    ),
                                                  );
                                            }

                                            _weight = enteredWeight;
                                          }
                                        });
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
                                        : 'Auto-calculated at today\'s gold rate',
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
                              Text(
                                _isAmountMode
                                    ? 'You Receive (Gold Weight)'
                                    : 'You Receive (Amount)',
                                style: p(
                                  14,
                                  FontWeight.w400,
                                  const Color(0xFF777777),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isAmountMode
                                    ? _receiveWeightFromAmount()
                                    : _receiveAmount(),
                                style: p(
                                  38 / 2,
                                  FontWeight.w700,
                                  const Color(0xFF2E2E2E),
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
                                            '25 Jan 2027',
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
                                        '*Gold Rates Are Subject To Market Fluctuations.\nBonus Percentage May Vary Based On Scheme\nDuration And Market Conditions.',
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
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: p(
                                        10,
                                        FontWeight.w500,
                                        const Color(0xFFD4AF37),
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and\n',
                                      style: p(
                                        10,
                                        FontWeight.w400,
                                        const Color(0xFF787878),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: p(
                                        10,
                                        FontWeight.w500,
                                        const Color(0xFFD4AF37),
                                      ),
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
}
