import 'package:flutter/material.dart';

class SavingsHistory extends StatefulWidget {
  const SavingsHistory({super.key});

  @override
  State<SavingsHistory> createState() => _SavingsHistoryState();
}

class _SavingsHistoryState extends State<SavingsHistory> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0 = Gold, 1 = Silver

  final List<Map<String, dynamic>> _metalData = [
    {
      'label': 'Gold',
      'totalValue': '₹14,250.00',
      'accumulated': '215.5g',
      'growth': '+12.4%',
      'progress': 0.0683,
      'progressLabel': '6.83% Completed',
      'transactions': [
        {'title': 'Buy Gold', 'date': '01 Feb, 10:42 AM', 'weight': '+5.0g', 'amount': '₹500', 'status': 'Success'},
        {'title': 'Buy Gold', 'date': '15 Jan, 09:15 AM', 'weight': '+3.2g', 'amount': '₹320', 'status': 'Success'},
        {'title': 'Buy Gold', 'date': '01 Jan, 11:00 AM', 'weight': '+8.1g', 'amount': '₹810', 'status': 'Success'},
        {'title': 'Buy Gold', 'date': '20 Dec, 08:30 AM', 'weight': '+2.5g', 'amount': '₹250', 'status': 'Success'},
      ],
    },
    {
      'label': 'Silver',
      'totalValue': '₹4,820.00',
      'accumulated': '1,240.0g',
      'growth': '+8.1%',
      'progress': 0.0420,
      'progressLabel': '4.20% Completed',
      'transactions': [
        {'title': 'Buy Silver', 'date': '03 Feb, 02:10 PM', 'weight': '+200.0g', 'amount': '₹800', 'status': 'Success'},
        {'title': 'Buy Silver', 'date': '18 Jan, 03:45 PM', 'weight': '+150.0g', 'amount': '₹600', 'status': 'Success'},
        {'title': 'Buy Silver', 'date': '05 Jan, 01:20 PM', 'weight': '+300.0g', 'amount': '₹1,200', 'status': 'Success'},
        {'title': 'Buy Silver', 'date': '22 Dec, 10:00 AM', 'weight': '+100.0g', 'amount': '₹400', 'status': 'Success'},
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metal = _metalData[_currentIndex];

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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                  "Savings History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Swipeable Summary Card (same design, only text changes) ──
                  SizedBox(
                    height: 185,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _metalData.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (context, index) {
                        final m = _metalData[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Saved Value",
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                m['totalValue'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(height: 1, color: Colors.white24),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total ${m['label']} Accumulated",
                                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.monetization_on,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            m['accumulated'] as String,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      m['growth'] as String,
                                      style: const TextStyle(fontSize: 11, color: Colors.white),
                                    ),
                                  ),
                                ],
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
                    children: List.generate(_metalData.length, (i) {
                      final isActive = i == _currentIndex;
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

                  const SizedBox(height: 20),

                  // ── Section Title ────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${metal['label']} Savings History",
                        key: ValueKey(_currentIndex),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Progress Card (same design, only values change) ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey('progress_$_currentIndex'),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Target Achieved"),
                              Text(
                                metal['progressLabel'] as String,
                                style: const TextStyle(fontSize: 12, color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: metal['progress'] as double,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation(Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ── Table Header (unchanged) ─────────────
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status", style: TextStyle(fontSize: 12)),
                      Text("Date", style: TextStyle(fontSize: 12)),
                      Text("Amount", style: TextStyle(fontSize: 12)),
                      Text("Saved Weight", style: TextStyle(fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Transaction List (same design, only text changes) ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey('list_$_currentIndex'),
                      children: (metal['transactions'] as List<Map<String, String>>).map((tx) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                          ),
                          child: Row(
                            children: [
                              // Icon — same orange style always
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.orange,
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx['title']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      "${tx['date']}  ${tx['weight']}",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              // Amount + Status — same green style always
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    tx['amount']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Success",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}