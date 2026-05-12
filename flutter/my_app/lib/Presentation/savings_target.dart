import 'package:flutter/material.dart';
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
  final PageController _pageController = PageController();
  int _metalIndex = 0; // 0 = Gold, 1 = Silver

  // Rates will be updated from provider; fallback defaults shown here
  final List<Map<String, dynamic>> _metals = [
    {
      'label': 'Gold',
      'ratePerGram': 0.0, // will be set from GoldPriceProvider
      'quickTargets': [5000.0, 10000.0, 25000.0],
    },
    {
      'label': 'Silver',
      'ratePerGram': 0.0, // will be set from GoldPriceProvider
      'quickTargets': [500.0, 1000.0, 2500.0],
    },
  ];

  double get ratePerGram => _metals[_metalIndex]['ratePerGram'] as double;
  List<double> get quickTargets =>
      _metals[_metalIndex]['quickTargets'] as List<double>;
  String get metalLabel => _metals[_metalIndex]['label'] as String;

  bool isAmount = true;
  double amount = 0;
  double weight = 0;

  final TextEditingController _controller = TextEditingController(text: "0");

  int selectedTargetIndex = 1;
  int selectedDuration = 12;
  final List<int> durations = [1, 3, 6, 9, 12];

  @override
  void initState() {
    super.initState();
    // Fetch latest gold prices when screen opens
    Future.microtask(() {
      Provider.of<GoldPriceProvider>(context, listen: false).fetchGoldPrice();
    });
  }

  /// Called once GoldPriceProvider has data — syncs live rates into _metals
  /// and recalculates amount/weight so the displayed value stays consistent.
  void _syncRatesFromProvider(GoldPriceProvider provider) {
    final goldRate = provider.goldData?.sellPrice.toDouble() ?? 0.0;
    final silverRate = provider.silverData?.sellPrice.toDouble() ?? 0.0;

    bool ratesChanged = false;

    if (_metals[0]['ratePerGram'] != goldRate && goldRate > 0) {
      _metals[0]['ratePerGram'] = goldRate;
      ratesChanged = true;
    }
    if (_metals[1]['ratePerGram'] != silverRate && silverRate > 0) {
      _metals[1]['ratePerGram'] = silverRate;
      ratesChanged = true;
    }

    if (ratesChanged) {
      // Seed initial amount from quick-target default after rates are known
      if (amount == 0 && ratePerGram > 0) {
        final defaultTarget =
            (_metals[_metalIndex]['quickTargets'] as List<double>)[selectedTargetIndex];
        amount = defaultTarget;
        weight = amount / ratePerGram;
        _controller.text = amount.toStringAsFixed(0);
      } else {
        // Recalculate the derived value so it reflects the new rate
        if (isAmount) {
          weight = ratePerGram > 0 ? amount / ratePerGram : 0;
        } else {
          amount = weight * ratePerGram;
        }
      }
    }
  }

  void _onMetalChanged(int index) {
    setState(() {
      _metalIndex = index;
      selectedTargetIndex = 1;
      final newRate = _metals[index]['ratePerGram'] as double;
      if (newRate > 0) {
        if (isAmount) {
          weight = amount / newRate;
        } else {
          amount = weight * newRate;
        }
      }
      _controller.text =
          isAmount ? amount.toStringAsFixed(0) : weight.toStringAsFixed(3);
    });
  }

  void updateValues(String value) {
    if (value.isEmpty) {
      setState(() {
        amount = 0;
        weight = 0;
      });
      return;
    }
    final double input = double.tryParse(value) ?? 0;
    setState(() {
      if (isAmount) {
        amount = input;
        weight = ratePerGram > 0 ? amount / ratePerGram : 0;
      } else {
        weight = input;
        amount = weight * ratePerGram;
      }
    });
  }

  void onFieldTap() => _controller.clear();

  Future<void> _onSetTarget(BuildContext context) async {
    final raw = _controller.text;
    if (raw.isEmpty || (double.tryParse(raw) ?? 0) == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid value")),
      );
      return;
    }

    final model = SetTargetModel(
      assetType: metalLabel, // "Gold" or "Silver" → lowercased in toJson()
      targetAmount: amount,
      targetWeight: weight,
      durationMonths: selectedDuration,
    );

    final provider = Provider.of<SetTargetProvider>(context, listen: false);
    final success = await provider.setTarget(model);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Target set successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to set target. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── UI builders (design unchanged) ──────────────────────────────────────

  Widget buildValueInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onTap: onFieldTap,
              onChanged: updateValues,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            isAmount ? " ₹" : " g",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Duration",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                "$selectedDuration Months",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: durations.length,
              itemBuilder: (context, index) {
                final d = durations[index];
                final bool isSelected = selectedDuration == d;
                return GestureDetector(
                  onTap: () => setState(() => selectedDuration = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                            )
                          : null,
                      color: isSelected ? null : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: Text(
                        "${d}M",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
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

  Widget buildQuickTargets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Targets",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(quickTargets.length, (index) {
            final bool isSelected = selectedTargetIndex == index;
            final t = quickTargets[index];
            final label = t >= 1000
                ? "₹${(t / 1000).toStringAsFixed(t % 1000 == 0 ? 0 : 1)}k"
                : "₹${t.toInt()}";

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTargetIndex = index;
                    amount = t;
                    weight = ratePerGram > 0 ? amount / ratePerGram : 0;
                    _controller.text = isAmount
                        ? amount.toStringAsFixed(0)
                        : weight.toStringAsFixed(3);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade200,
                  ),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        index == 0
                            ? "Starter"
                            : index == 1
                                ? "Popular"
                                : "Pro",
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.orange
                              : Colors.grey.shade600,
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

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoldPriceProvider>(
      builder: (context, goldProvider, child) {
        // Sync live rates whenever provider updates (no setState needed here
        // because _syncRatesFromProvider only mutates _metals list entries
        // and recalculates amount/weight; the Consumer rebuild handles UI).
        _syncRatesFromProvider(goldProvider);

        return Consumer<SetTargetProvider>(
          builder: (context, setTargetProvider, _) {
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 248, 246, 246),
              body: Column(
                children: [
                  // ── HEADER ──────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white24,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Text(
                          "Set Savings Target",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Loading spinner in header when fetching rates
                        if (goldProvider.isLoading) ...[
                          const Spacer(),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── BODY ────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // ── Amount / Weight toggle ───────────────────
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isAmount = true;
                                        _controller.text =
                                            amount.toStringAsFixed(0);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25),
                                        gradient: isAmount
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF2A0912),
                                                  Color(0xFFE1094A),
                                                ],
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "₹ Amount (₹)",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isAmount
                                                ? Colors.white
                                                : Colors.grey,
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
                                        isAmount = false;
                                        _controller.text =
                                            weight.toStringAsFixed(3);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(25),
                                        gradient: !isAmount
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF2A0912),
                                                  Color(0xFFE1094A),
                                                ],
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "⚖ Weight (g)",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: !isAmount
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // ── Swipeable Target Card ────────────────────
                          SizedBox(
                            height: 220,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _metals.length,
                              onPageChanged: _onMetalChanged,
                              itemBuilder: (context, index) {
                                final m = _metals[index];
                                final liveRate =
                                    (m['ratePerGram'] as double);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DFC8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Target Amount (${m['label']})",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      // Live rate badge
                                      if (liveRate > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            "Live Rate: ₹${liveRate.toStringAsFixed(0)}/g",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      buildValueInput(),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isAmount
                                              ? "⚡ Est. ${m['label']}: ${weight.toStringAsFixed(3)}g"
                                              : "⚡ Est. Amount: ₹${amount.toStringAsFixed(0)}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // ── Dot Indicators ───────────────────────────
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_metals.length, (i) {
                              final isActive = i == _metalIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFE1094A)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),

                          buildDurationSelector(),
                          const SizedBox(height: 25),
                          buildQuickTargets(),
                          const SizedBox(height: 25),

                          // ── Set Target Button ────────────────────────
                          GestureDetector(
                            onTap: setTargetProvider.isLoading
                                ? null
                                : () => _onSetTarget(context),
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A0912),
                                    Color(0xFFE1094A),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: setTargetProvider.isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Set Target →",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
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
}