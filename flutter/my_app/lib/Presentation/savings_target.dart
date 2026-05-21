import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/Models/set_target_models.dart';
import 'package:my_app/Providers/gold_Provider.dart';
import 'package:my_app/Providers/set_target_provider.dart';
import 'package:provider/provider.dart';

class SavingsTarget extends StatefulWidget {
  const SavingsTarget({super.key});

  @override
  State<SavingsTarget> createState() => _SavingsTargetState();
}

class _SavingsTargetState extends State<SavingsTarget> {
  static const Color _maroonDark = Color(0xFF2A0912);

  static const Color _maroonVivid = Color(0xFFE1094A);

  final PageController _pageController = PageController();

  int _metalIndex = 0;

  final List<Map<String, dynamic>> _metals = [
    {
      'label': 'gold',
      'display': 'Gold',
      'ratePerGram': 0.0,
      'quickTargets': [5000.0, 10000.0, 25000.0],
    },
    {
      'label': 'silver',
      'display': 'Silver',
      'ratePerGram': 0.0,
      'quickTargets': [500.0, 1000.0, 2500.0],
    },
  ];

  double get ratePerGram => _metals[_metalIndex]['ratePerGram'] as double;

  List<double> get quickTargets =>
      _metals[_metalIndex]['quickTargets'] as List<double>;

  String get metalLabel => _metals[_metalIndex]['label'] as String;

  String get metalDisplay => _metals[_metalIndex]['display'] as String;

  bool isAmount = true;

  double amount = 0;
  double weight = 0;

  int selectedTargetIndex = -1;
  int selectedDuration = 12;

  final List<int> durations = [1, 3, 6, 9, 12];

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Provider.of<GoldPriceProvider>(
        context,
        listen: false,
      ).fetchGoldPrice();

      await Provider.of<SetTargetProvider>(
        context,
        listen: false,
      ).fetchAllTargets();

      _loadExistingTarget();
    });
  }

  void _loadExistingTarget() {
    final provider = Provider.of<SetTargetProvider>(context, listen: false);

    final target = provider.targetFor(metalLabel);

    if (target != null) {
      amount = target.targetAmount;

      weight = target.targetWeight;

      selectedDuration = target.durationMonths;

      _controller.text = isAmount
          ? amount.toStringAsFixed(0)
          : weight.toStringAsFixed(3);

      _updateSelection();

      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _syncRates(GoldPriceProvider provider) {
    final goldRate = provider.goldData?.sellPrice.toDouble() ?? 0.0;

    final silverRate = provider.silverData?.sellPrice.toDouble() ?? 0.0;

    _metals[0]['ratePerGram'] = goldRate;

    _metals[1]['ratePerGram'] = silverRate;
  }

  void _onMetalChanged(int index) {
    setState(() {
      _metalIndex = index;
    });

    _loadExistingTarget();
  }

  void _updateValues(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        amount = 0;
        weight = 0;
        selectedTargetIndex = -1;
      });

      return;
    }

    final input = double.tryParse(value) ?? 0;

    setState(() {
      if (isAmount) {
        amount = input;

        weight = ratePerGram > 0 ? amount / ratePerGram : 0;
      } else {
        weight = input;

        amount = weight * ratePerGram;
      }

      _updateSelection();
    });
  }

  void _updateSelection() {
    selectedTargetIndex = quickTargets.indexWhere(
      (e) => (e - amount).abs() < 1,
    );
  }

  String _fmtCurrency(double v) {
    final f = NumberFormat('#,##,##0', 'en_IN');

    return '₹${f.format(v)}';
  }

  Future<void> _onSetTarget(BuildContext context) async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter value")));

      return;
    }

    final provider = Provider.of<SetTargetProvider>(context, listen: false);

    final model = SetTargetModel(
      assetType: metalLabel,
      targetAmount: amount,
      targetWeight: weight,
      durationMonths: selectedDuration,
    );

    final success = await provider.setTarget(model);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          success
              ? "$metalDisplay target saved successfully"
              : "Failed to save target",
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoldPriceProvider>(
      builder: (context, goldProvider, _) {
        _syncRates(goldProvider);

        return Consumer<SetTargetProvider>(
          builder: (context, targetProvider, _) {
            return Scaffold(
              backgroundColor: const Color(0xFFF7F7F7),

              body: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_maroonDark, _maroonVivid],
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(.15),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          "Set Savings Target",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _toggleRow(),

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 230,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _metals.length,
                              onPageChanged: _onMetalChanged,
                              itemBuilder: (context, index) {
                                final metal = _metals[index];

                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE7DCC7),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          metal['display'],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "Live Rate ₹${(metal['ratePerGram'] as double).toStringAsFixed(0)}/g",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),

                                        const SizedBox(height: 18),

                                        _valueInput(),

                                        const SizedBox(height: 14),

                                        FittedBox(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 9,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                            child: Text(
                                              isAmount
                                                  ? "Estimated ${(weight * (1 - 0.03)).toStringAsFixed(4)} g"
                                                  : "Estimated ₹${amount.toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          _durationSelector(),

                          const SizedBox(height: 20),

                          _quickTargets(),

                          const SizedBox(height: 28),

                          GestureDetector(
                            onTap: targetProvider.isLoading
                                ? null
                                : () => _onSetTarget(context),
                            child: Container(
                              height: 52,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [_maroonDark, _maroonVivid],
                                ),
                              ),
                              child: Center(
                                child: targetProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Set $metalDisplay Target",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _toggleRow() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        children: [
          _toggleButton("₹ Amount", isAmount, () {
            setState(() {
              isAmount = true;

              _controller.text = amount.toStringAsFixed(0);
            });
          }),

          _toggleButton("⚖ Weight", !isAmount, () {
            setState(() {
              isAmount = false;

              _controller.text = weight.toStringAsFixed(3);
            });
          }),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: active
                ? const LinearGradient(colors: [_maroonDark, _maroonVivid])
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _valueInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              onChanged: _updateValues,
            ),
          ),

          Text(
            isAmount ? "₹" : "g",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Duration",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: durations.length,
              itemBuilder: (context, i) {
                final duration = durations[i];

                final active = selectedDuration == duration;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDuration = duration;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: active
                          ? const LinearGradient(
                              colors: [_maroonDark, _maroonVivid],
                            )
                          : null,
                      color: active ? null : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        "$duration M",
                        style: TextStyle(
                          fontSize: 12,
                          color: active ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickTargets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Targets",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),

        const SizedBox(height: 14),

        Row(
          children: List.generate(quickTargets.length, (i) {
            final target = quickTargets[i];

            final active = selectedTargetIndex == i;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    amount = target;

                    weight = ratePerGram > 0 ? amount / ratePerGram : 0;

                    selectedTargetIndex = i;

                    _controller.text = isAmount
                        ? amount.toStringAsFixed(0)
                        : weight.toStringAsFixed(4);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: active
                        ? const LinearGradient(
                            colors: [_maroonDark, _maroonVivid],
                          )
                        : null,
                    color: active ? null : Colors.grey.shade200,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _fmtCurrency(target),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: active ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        i == 0
                            ? "Starter"
                            : i == 1
                            ? "Popular"
                            : "Pro",
                        style: TextStyle(
                          color: active ? Colors.orange : Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
