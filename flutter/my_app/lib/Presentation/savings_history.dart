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

  final List<String> _assetTypes = ['gold', 'silver'];
  final List<String> _assetLabels = ['Gold', 'Silver'];

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

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    context.read<SavingsHistoryProvider>().fetchSavingsHistory(
      _assetTypes[index],
    );
  }

  String _formatDate(DateTime dt) =>
      DateFormat('dd MMM, hh:mm a').format(dt.toLocal());

  String _formatCurrency(double amount) => '₹${amount.toStringAsFixed(2)}';

  String _formatWeight(double g) => '+${g.toStringAsFixed(4)}g';

  // ── trigger PDF for a transaction row ──
  Future<void> _downloadReceipt(BuildContext context, dynamic tx) async {
    // Derive metal value & GST from the stored total amount
    final double metalValue = tx.amount / 1.03;
    final double gst = tx.amount - metalValue;
    final double ratePerGram = metalValue / (tx.grams == 0 ? 1 : tx.grams);

    await PassbookInvoice.generateReceipt(
      context: context,

      /// CUSTOMER — replace with your auth provider values
      customerName: tx.user.fullName.isNotEmpty ? tx.user.fullName : 'Customer',
      phone: tx.user.mobile.isNotEmpty ? tx.user.mobile : '',

      /// METAL
      metalType: _assetTypes[_currentIndex],

      /// PAYMENT FIGURES
      weight: tx.grams,
      ratePerGram: ratePerGram,
      metalValue: metalValue,
      gst: gst,
      totalAmount: tx.amount,

      /// TRANSACTION META
      transactionId: tx.transactionId,
      paymentMethod: tx.paymentMethod,
      paymentStatus: tx.paymentStatus,
      createdAt: tx.createdAt,
      schemeId: tx.schemeId, // human-readable "SCH--2026-0005"
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
                final transactions = provider.transactions;
                final isLoading = provider.isLoading;
                final hasNoData = provider.hasNoData;
                final currentLabel = _assetLabels[_currentIndex];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  : isActive && hasNoData
                                  // ── no data state ──
                                  ? _summaryCardContent(
                                      label: label,
                                      savedAmount: '₹0.00',
                                      accumulated: '0.0000g',
                                      percentage: '0.0%',
                                    )
                                  // ── real data state ──
                                  : _summaryCardContent(
                                      label: label,
                                      savedAmount: isActive && summary != null
                                          ? _formatCurrency(
                                              summary.totalSavedAmount,
                                            )
                                          : '₹0.00',
                                      accumulated: isActive && summary != null
                                          ? '${summary.totalGoldAccumulated.toStringAsFixed(4)}g'
                                          : '0.0000g',
                                      percentage: isActive && summary != null
                                          ? '+${(summary.targetAchievedPercentage > 100 ? 100 : summary.targetAchievedPercentage).toStringAsFixed(0)}%'
                                          : '0.0%',
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

                      // ── PROGRESS CARD ─────────────────────────
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

                      Text(
                        'Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── TRANSACTION LIST ──────────────────────
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
                            : hasNoData || transactions.isEmpty
                            ? _emptyState(currentLabel)
                            : Column(
                                key: ValueKey(
                                  'list_${_currentIndex}_${transactions.length}',
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

  // ── Summary card inner content ──────────────────────────────
  Widget _summaryCardContent({
    required String label,
    required String savedAmount,
    required String accumulated,
    required String percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Saved Value',
          style: TextStyle(fontSize: 12, color: Colors.white70),
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
                  'Total $label Accumulated',
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
                Text(
                  'Buy ${_assetLabels[_currentIndex]}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
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
                // scheme name if available
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
              // receipt download hint
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

  // ── Empty state ───────────────────────────────────────────────
  Widget _emptyState(String label) {
    return Padding(
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
}
