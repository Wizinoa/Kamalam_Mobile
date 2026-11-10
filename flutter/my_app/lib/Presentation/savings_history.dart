import 'package:flutter/material.dart';
import 'package:my_app/Utils/passbook_invoice.dart';
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
  int _frequencyIndex = 0; // 0 = All, 1 = Daily, 2 = Monthly, 3 = Anytime

  final List<String> _assetTypes = ['gold', 'silver'];
  final List<String> _assetLabels = ['Gold', 'Silver'];
  final List<String> _frequencyLabels = ['All', 'Daily', 'Monthly', 'Anytime'];

  // ── colours ──
  static const Color _maroonMid = Color(0xFF2A0912);
  static const Color _maroonVivid = Color(0xFFE1094A);

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

  // Called when the card is swiped
  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _frequencyIndex = 0; // reset frequency filter on metal change
    });
    context.read<SavingsHistoryProvider>().fetchSavingsHistory(
      _assetTypes[index],
    );
  }

  // Called when the Gold / Silver tab is tapped
  void _onMetalTabTap(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ); // onPageChanged will do the fetch + setState
  }

  // ── Detect Daily / Monthly / Anytime for a transaction ──
  // 1 = Daily, 2 = Monthly, 3 = Anytime
  // 👉 Replace this with your real field if your model has one.
  int _frequencyOf(dynamic tx) {
    String raw = '';
    try {
      raw = (tx.schemeType ?? '').toString();
    } catch (_) {}
    if (raw.isEmpty) {
      try {
        raw = (tx.frequency ?? '').toString();
      } catch (_) {}
    }
    if (raw.isEmpty) {
      final name = (tx.schemeName ?? '').toString();
      final id = (tx.schemeId ?? '').toString();
      raw = '$name $id';
    }
    final t = raw.toLowerCase();
    if (t.contains('daily')) return 1;
    if (t.contains('monthly')) return 2;
    return 3;
  }

  List<dynamic> _applyFilter(List<dynamic> all) {
    if (_frequencyIndex == 0) return all;
    return all.where((tx) => _frequencyOf(tx) == _frequencyIndex).toList();
  }

  int _countFor(List<dynamic> all, int freqIndex) {
    if (freqIndex == 0) return all.length;
    return all.where((tx) => _frequencyOf(tx) == freqIndex).length;
  }

  // ── Only successful payments are counted in totals ──
  bool _isSuccess(dynamic tx) =>
      tx.paymentStatus.toString().toLowerCase() == 'success';

  double _sumAmount(List<dynamic> list) => list
      .where(_isSuccess)
      .fold<double>(0.0, (sum, tx) => sum + (tx.amount as num).toDouble());

  // grams after the 3% deduction (same as shown in each row)
  double _sumGrams(List<dynamic> list) => list
      .where(_isSuccess)
      .fold<double>(
        0.0,
        (sum, tx) => sum + (tx.grams as num).toDouble() ,
      );

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM, hh:mm a').format(dt.toLocal());

  String _formatCurrency(double amount) => '₹${amount.toStringAsFixed(2)}';

  String _formatWeight(double g) => '+${g.toStringAsFixed(4)}g';

  // ── trigger PDF for a transaction row ──
  Future<void> _downloadReceipt(BuildContext context, dynamic tx) async {
    final double metalValue = tx.amount / 1.03;
    final double gst = tx.amount - metalValue;
    final double ratePerGram = metalValue;

    await PassbookInvoice.generateReceipt(
      context: context,
      customerName: tx.user.fullName.isNotEmpty ? tx.user.fullName : 'Customer',
      phone: tx.user.mobile.isNotEmpty ? tx.user.mobile : '',
      metalType: _assetTypes[_currentIndex],
      weight: tx.grams,
      ratePerGram: ratePerGram,
      metalValue: metalValue,
      gst: gst,
      totalAmount: tx.amount,
      transactionId: tx.transactionId,
      paymentMethod: tx.paymentMethod,
      paymentStatus: tx.paymentStatus,
      createdAt: tx.createdAt,
      schemeName: tx.schemeName.isNotEmpty ? tx.schemeName : '',
      schemeId: tx.schemeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: Column(
        children: [
          // ── HEADER ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_maroonMid, _maroonVivid],
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
                  'Savings History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── BODY ───────────────────────────────────────────────
          Expanded(
            child: Consumer<SavingsHistoryProvider>(
              builder: (context, provider, _) {
                final summary = provider.summary;
                final List<dynamic> allTransactions = provider.transactions;
                final transactions = _applyFilter(allTransactions);
                final isLoading = provider.isLoading;
                final hasNoData = provider.hasNoData;
                final currentLabel = _assetLabels[_currentIndex];

                // ── Summary card values (change with frequency tab) ──
                final bool isFiltered = _frequencyIndex != 0;
                final String freqLabel = _frequencyLabels[_frequencyIndex];

                String activeSaved = '₹0.00';
                String activeAcc = '0.0000g';
                String activePill = '0.0%';

                if (!hasNoData) {
                  if (isFiltered) {
                    // Daily / Monthly / Anytime → totals of filtered list
                    activeSaved = _formatCurrency(_sumAmount(transactions));
                    activeAcc =
                        '${_sumGrams(transactions).toStringAsFixed(4)}g';
                    activePill = freqLabel;
                  } else if (summary != null) {
                    // All → overall values from the summary
                    activeSaved = _formatCurrency(summary.totalSavedAmount);
                    activeAcc =
                        '${(summary.totalGoldAccumulated ).toStringAsFixed(4)}g';
                    activePill =
                        '+${(summary.targetAchievedPercentage > 100 ? 100 : summary.targetAchievedPercentage).toStringAsFixed(0)}%';
                  }
                }

                final String cardTitle = isFiltered
                    ? '$freqLabel Saved Value'
                    : 'Total Saved Value';
                final String accPrefix = isFiltered ? freqLabel : 'Total';

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── GOLD / SILVER TAB ─────────────────────
                      _metalTabs(),

                      const SizedBox(height: 14),

                      // ── SWIPEABLE SUMMARY CARD ────────────────
                      SizedBox(
                        height: 185,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _assetLabels.length,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            final isActive = index == _currentIndex;
                            final label = _assetLabels[index];

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [_maroonMid, _maroonVivid],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: isLoading && isActive
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : _summaryCardContent(
                                      title: isActive
                                          ? cardTitle
                                          : 'Total Saved Value',
                                      accLabel: isActive
                                          ? '$accPrefix $label Accumulated'
                                          : 'Total $label Accumulated',
                                      savedAmount:
                                          isActive ? activeSaved : '₹0.00',
                                      accumulated:
                                          isActive ? activeAcc : '0.0000g',
                                      percentage:
                                          isActive ? activePill : '0.0%',
                                    ),
                            );
                          },
                        ),
                      ),

                      // ── DOT INDICATORS ───────────────────────
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_assetLabels.length, (i) {
                          final on = i == _currentIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: on ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: on ? _maroonVivid : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // ── SECTION TITLE ─────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '$currentLabel Savings History',
                            key: ValueKey(_currentIndex),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── PROGRESS CARD (overall target) ────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey('progress_$_currentIndex'),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Target Achieved',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    !hasNoData && summary != null
                                        ? '${(summary.targetAchievedPercentage > 100 ? 100 : summary.targetAchievedPercentage).toStringAsFixed(0)}% Completed'
                                        : '0.00% Completed',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: !hasNoData && summary != null
                                      ? (summary.targetAchievedPercentage / 100)
                                            .clamp(0.0, 1.0)
                                      : 0.0,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: const AlwaysStoppedAnimation(
                                    Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── ALL / DAILY / MONTHLY / ANYTIME TABS ──
                      _frequencyTabs(allTransactions),

                      const SizedBox(height: 16),

                      // ── TRANSACTION LIST ──────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFE1094A),
                                  ),
                                ),
                              )
                            : hasNoData || allTransactions.isEmpty
                            ? _emptyState(currentLabel)
                            : transactions.isEmpty
                            ? _emptyFilterState(currentLabel, freqLabel)
                            : Column(
                                key: ValueKey(
                                  'list_${_currentIndex}_${_frequencyIndex}_${transactions.length}',
                                ),
                                children: transactions.map((tx) {
                                  return GestureDetector(
                                    onTap: () => _downloadReceipt(context, tx),
                                    child: _transactionCard(context, tx),
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

  // ── Gold / Silver segmented tab ─────────────────────────────
  Widget _metalTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: List.generate(_assetLabels.length, (i) {
          final selected = i == _currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onMetalTabTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [_maroonMid, _maroonVivid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: selected
                          ? (i == 0 ? Colors.amber : Colors.blueGrey.shade100)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _assetLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── All / Daily / Monthly / Anytime chips ───────────────────
  Widget _frequencyTabs(List<dynamic> all) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_frequencyLabels.length, (i) {
          final selected = i == _frequencyIndex;
          final count = _countFor(all, i);
          return GestureDetector(
            onTap: () => setState(() => _frequencyIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _maroonVivid : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _maroonVivid : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _frequencyLabels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white24 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Summary card inner content ──────────────────────────────
  Widget _summaryCardContent({
    required String title,
    required String accLabel,
    required String savedAmount,
    required String accumulated,
    required String percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 5),
        Text(
          savedAmount,
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
                  accLabel,
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
                      accumulated,
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
                percentage,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Single transaction row card ──────────────────────────────
  Widget _transactionCard(BuildContext context, dynamic tx) {
    final isSuccess = tx.paymentStatus.toLowerCase() == 'success';
    final freq = _frequencyLabels[_frequencyOf(tx)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          // ── DOWNLOAD ICON (tappable) ──
          GestureDetector(
            onTap: () => _downloadReceipt(context, tx),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Icon(
                Icons.download_rounded,
                color: Colors.orange.shade700,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── LABEL + DATE ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Buy ${_assetLabels[_currentIndex]}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _maroonVivid.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        freq,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _maroonVivid,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(tx.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatWeight(tx.grams),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tx.schemeName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.schemeName,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),

          // ── AMOUNT + STATUS ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(tx.amount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSuccess
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Text(
                  tx.paymentStatus.isNotEmpty
                      ? tx.paymentStatus[0].toUpperCase() +
                            tx.paymentStatus.substring(1).toLowerCase()
                      : '',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap 🧾 for receipt',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state (no data at all) ─────────────────────────────
  Widget _emptyState(String label) {
    return Padding(
      key: const ValueKey('empty_all'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.savings_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No $label savings found.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Start saving today!',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state (filter has no matches) ──────────────────────
  Widget _emptyFilterState(String metal, String freq) {
    return Padding(
      key: ValueKey('empty_${_currentIndex}_$_frequencyIndex'),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.filter_list_off, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No $freq $metal transactions.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}