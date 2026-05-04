import 'package:flutter/material.dart';

class SavingsTarget extends StatefulWidget {
  const SavingsTarget({super.key});

  @override
  State<SavingsTarget> createState() => _SavingsTargetState();
}

class _SavingsTargetState extends State<SavingsTarget> {
  final PageController _pageController = PageController();
  int _metalIndex = 0; // 0 = Gold, 1 = Silver

  final List<Map<String, dynamic>> _metals = [
    {
      'label': 'Gold',
      'ratePerGram': 14000.0,
      'quickTargets': [5000.0, 10000.0, 25000.0],
    },
    {
      'label': 'Silver',
      'ratePerGram': 850.0,
      'quickTargets': [500.0, 1000.0, 2500.0],
    },
  ];

  double get ratePerGram => _metals[_metalIndex]['ratePerGram'] as double;
  List<double> get quickTargets => _metals[_metalIndex]['quickTargets'] as List<double>;
  String get metalLabel => _metals[_metalIndex]['label'] as String;

  bool isAmount = true;
  double amount = 5000;
  double weight = 5000 / 14000;

  final TextEditingController _controller = TextEditingController(text: "5000");

  int selectedTargetIndex = 1;
  int selectedDuration = 12;
  final List<int> durations = [1, 3, 6, 9, 12];

  void _onMetalChanged(int index) {
    setState(() {
      _metalIndex = index;
      selectedTargetIndex = 1;
      final newRate = _metals[index]['ratePerGram'] as double;
      if (isAmount) {
        weight = amount / newRate;
      } else {
        amount = weight * newRate;
      }
      if (isAmount) {
        _controller.text = amount.toStringAsFixed(0);
      } else {
        _controller.text = weight.toStringAsFixed(2);
      }
    });
  }

  void updateValues(String value) {
    if (value.isEmpty) {
      setState(() { amount = 0; weight = 0; });
      return;
    }
    double input = double.tryParse(value) ?? 0;
    setState(() {
      if (isAmount) {
        amount = input;
        weight = amount / ratePerGram;
      } else {
        weight = input;
        amount = weight * ratePerGram;
      }
    });
  }

  void onFieldTap() => _controller.clear();

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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const Text("Duration", style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text(
                "$selectedDuration Months",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
                bool isSelected = selectedDuration == d;
                return GestureDetector(
                  onTap: () => setState(() => selectedDuration = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: isSelected
                          ? const LinearGradient(colors: [Color(0xFF2A0912), Color(0xFFE1094A)])
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
        const Text("Quick Targets", style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(quickTargets.length, (index) {
            bool isSelected = selectedTargetIndex == index;
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
                    weight = amount / ratePerGram;
                    if (isAmount) {
                      _controller.text = amount.toStringAsFixed(0);
                    } else {
                      _controller.text = weight.toStringAsFixed(2);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFF2A0912), Color(0xFFE1094A)])
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
                        index == 0 ? "Starter" : index == 1 ? "Popular" : "Pro",
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.orange : Colors.grey.shade600,
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 246, 246),
      body: Column(
        children: [
          // ── HEADER (unchanged) ───────────────────────────
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
                    child: const Icon(Icons.arrow_back, color: Colors.white),
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
              ],
            ),
          ),



          // ── BODY ─────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                       const SizedBox(height: 20),

                  // ── Amount / Weight toggle (unchanged) ───
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
                                _controller.text = amount.toStringAsFixed(0);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: isAmount
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "₹ Amount (₹)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isAmount ? Colors.white : Colors.grey,
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
                                _controller.text = weight.toStringAsFixed(2);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: !isAmount
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  "⚖ Weight (g)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: !isAmount ? Colors.white : Colors.grey,
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

                  // ── Swipeable Target Card ────────────────
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _metals.length,
                      onPageChanged: _onMetalChanged,
                      itemBuilder: (context, index) {
                        final m = _metals[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
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
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              buildValueInput(),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isAmount
                                      ? "⚡ Est. ${m['label']}: ${weight.toStringAsFixed(2)}g"
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

                  // ── Dot Indicators ───────────────────────
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_metals.length, (i) {
                      final isActive = i == _metalIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFE1094A) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

             
                  buildDurationSelector(),
                  const SizedBox(height: 25),
                  buildQuickTargets(),
                  const SizedBox(height: 25),

                  // ── Set Target Button (unchanged) ────────
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.isEmpty ||
                          (double.tryParse(_controller.text) ?? 0) == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter valid value")),
                        );
                        return;
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
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
  }
}