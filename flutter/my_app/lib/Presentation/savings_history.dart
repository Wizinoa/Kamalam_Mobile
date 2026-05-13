import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/Providers/savings_history_provider.dart';
import 'package:intl/intl.dart';

class SavingsHistory extends StatefulWidget {
  const SavingsHistory({super.key});

  @override
  State<SavingsHistory> createState() => _SavingsHistoryState();
}

class _SavingsHistoryState extends State<SavingsHistory> {
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0 = Gold, 1 = Silver

  final List<String> _assetTypes = ['gold', 'silver'];
  final List<String> _assetLabels = ['Gold', 'Silver'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsHistoryProvider>().fetchSavingsHistory('gold');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    context
        .read<SavingsHistoryProvider>()
        .fetchSavingsHistory(_assetTypes[index]);
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM, hh:mm a').format(dt.toLocal());
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatWeight(double targetWeight) {
    return '+${targetWeight.toStringAsFixed(4)}g';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 246, 246),
      body: Column(
        children: [
          // ── HEADER ───────────────────────────
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
            child: Consumer<SavingsHistoryProvider>(
              builder: (context, provider, _) {
                final summary = provider.summary;
                final transactions = provider.transactions;
                final isLoading = provider.isLoading;
                final hasNoData = provider.hasNoData;
                final currentLabel = _assetLabels[_currentIndex];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Swipeable Summary Card ──
                      SizedBox(
                        height: 185,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _assetLabels.length,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            final isCurrentPage = index == _currentIndex;
                            final label = _assetLabels[index];

                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A0912),
                                    Color(0xFFE1094A)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: isLoading && isCurrentPage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : isCurrentPage && hasNoData
                                      // ── No data state inside card ──
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Total Saved Value",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70),
                                            ),
                                            const SizedBox(height: 5),
                                            const Text(
                                              '₹0.00',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Container(
                                                height: 1,
                                                color: Colors.white24),
                                            const SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Total $label Accumulated",
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.white70),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    const Row(
                                                      children: [
                                                        Icon(
                                                          Icons.monetization_on,
                                                          color: Colors.amber,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          '0.0000g',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: const Text(
                                                    '0.0%',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      // ── Normal data state ──
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Total Saved Value",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              isCurrentPage && summary != null
                                                  ? _formatCurrency(
                                                      summary.totalSavedAmount)
                                                  : '₹0.00',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Container(
                                                height: 1,
                                                color: Colors.white24),
                                            const SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Total $label Accumulated",
                                                      style: const TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.white70),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.monetization_on,
                                                          color: Colors.amber,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          isCurrentPage &&
                                                                  summary !=
                                                                      null
                                                              ? '${summary.totalGoldAccumulated.toStringAsFixed(4)}g'
                                                              : '0.0000g',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    isCurrentPage &&
                                                            summary != null
                                                        ? '+${summary.targetAchievedPercentage.toStringAsFixed(1)}%'
                                                        : '0.0%',
                                                    style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.white),
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
                        children: List.generate(_assetLabels.length, (i) {
                          final isActive = i == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
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

                      const SizedBox(height: 20),

                      // ── Section Title ────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "$currentLabel Savings History",
                            key: ValueKey(_currentIndex),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Progress Card ──
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey('progress_$_currentIndex'),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Target Achieved"),
                                  Text(
                                    !hasNoData && summary != null
                                        ? '${summary.targetAchievedPercentage.toStringAsFixed(2)}% Completed'
                                        : '0.00% Completed',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: !hasNoData && summary != null
                                      ? (summary.targetAchievedPercentage /
                                              100)
                                          .clamp(0.0, 1.0)
                                      : 0.0,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: const AlwaysStoppedAnimation(
                                      Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ── Table Header ─────────────
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

                      // ── Transaction List ──
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE1094A),
                                  ),
                                ),
                              )
                            : hasNoData || transactions.isEmpty
                                // ── No savings found state ──
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.savings_outlined,
                                            size: 48,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'No $currentLabel savings found.',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                // ── Real transaction list ──
                                : Column(
                                    key: ValueKey(
                                        'list_${_currentIndex}_${transactions.length}'),
                                    children: transactions.map((tx) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 5)
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(10),
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
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Buy $currentLabel',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${_formatDate(tx.createdAt)}  ${_formatWeight(tx.grams)}',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _formatCurrency(tx.amount),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: tx.paymentStatus
                                                                .toLowerCase() ==
                                                            'success'
                                                        ? Colors.green.shade100
                                                        : Colors.red.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    tx.paymentStatus
                                                            .isNotEmpty
                                                        ? tx.paymentStatus[0]
                                                                .toUpperCase() +
                                                            tx.paymentStatus
                                                                .substring(1)
                                                                .toLowerCase()
                                                        : '',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: tx.paymentStatus
                                                                  .toLowerCase() ==
                                                              'success'
                                                          ? Colors.green
                                                          : Colors.red,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}