import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/instant_purchase_screen.dart';
import 'package:my_app/Models/instant_transaction_models.dart';
import 'package:my_app/Providers/instant_transactions_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class GoldTransactionScreen extends StatefulWidget {
  const GoldTransactionScreen({super.key});

  @override
  State<GoldTransactionScreen> createState() => _GoldTransactionScreenState();
}

class _GoldTransactionScreenState extends State<GoldTransactionScreen> {
  int selectedFilter = 0; // 0=All, 1=Month, 2=3 Months, 3=Year
  int selectedMetal = 0;  // 0=Gold, 1=Silver

  final List<String> filters = ["All", "Month", "3 Months", "Year"];
  final List<String> metalType = ["Gold", "Silver"];

  /// Maps tab index → query param value (empty string = no filter = all)
  final List<String> filterParams = [
    "",            // All
    "thisMonth",
    "last3Months",
    "thisYear",
  ];

  @override
  void initState() {
    super.initState();
    // Fetch all transactions on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions(filter: "");
    });
  }

  void _onFilterTap(int index) {
    setState(() => selectedFilter = index);
    context
        .read<TransactionProvider>()
        .fetchTransactions(filter: filterParams[index]);
  }

  /// Returns only the transactions matching the selected metal tab
  List<TransactionModel> _filtered(List<TransactionModel> all) {
    final metal = selectedMetal == 0 ? "gold" : "silver";
    return all
        .where((t) => t.assetType.toLowerCase() == metal)
        .toList();
  }

  /// Summary helpers
  double _totalGrams(List<TransactionModel> all) {
    final metal = selectedMetal == 0 ? "gold" : "silver";
    return all
        .where((t) => t.assetType.toLowerCase() == metal)
        .fold(0.0, (sum, t) => sum + t.grams);
  }

  double _totalInvested(List<TransactionModel> all) {
    final metal = selectedMetal == 0 ? "gold" : "silver";
    return all
        .where((t) => t.assetType.toLowerCase() == metal)
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  String _formatCurrency(double value) {
    final f = NumberFormat('#,##,##0', 'en_IN');
    return '₹${f.format(value)}';
  }

  String _formatGrams(double value) {
    return '${value.toStringAsFixed(2)}g';
  }

// AFTER ✅
String _formatDate(DateTime dt) =>
    DateFormat('dd MMM yyyy').format(dt.toLocal());

String _formatTime(DateTime dt) =>
    DateFormat('hh:mm a').format(dt.toLocal());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF3A0A13), Color(0xFFC6003A)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "Gold Transaction",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final allTransactions = provider.transactions;
          final filtered = _filtered(allTransactions);

          return Column(
            children: [
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC6003A),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            /// ── SUMMARY CARDS ──
                            Row(
                              children: [
                                Expanded(
                                  child: _summaryCard(
                                    title: selectedMetal == 0
                                        ? "Gold Purchased"
                                        : "Silver Purchased",
                                    value: _formatGrams(
                                        _totalGrams(allTransactions)),
                                    suffix: "grams",
                                    light: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _summaryCard(
                                    title: "Total Invested",
                                    value: _formatCurrency(
                                        _totalInvested(allTransactions)),
                                    suffix: "",
                                    light: false,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),

                            /// ── TIME FILTER ──
                            _filterBar(
                              items: filters,
                              selected: selectedFilter,
                              onTap: _onFilterTap,
                            ),

                            const SizedBox(height: 24),

                            /// ── SECTION LABEL ──
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "TRANSACTIONS",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  letterSpacing: 1.2,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// ── METAL FILTER ──
                            _filterBar(
                              items: metalType,
                              selected: selectedMetal,
                              onTap: (index) =>
                                  setState(() => selectedMetal = index),
                            ),

                            const SizedBox(height: 16),

                            /// ── TRANSACTION LIST ──
                            filtered.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "No transactions found",
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filtered.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final item = filtered[index];
                                      final bool isGold =
                                          item.assetType.toLowerCase() ==
                                              "gold";

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 14),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const PurchaseSuccessScreen(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding:
                                                const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(.04),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                /// DATE ROW
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: const Color(
                                                            0xFFF8F2F2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_month_rounded,
                                                            size: 12,
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            _formatDate(
                                                                item.createdAt),
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .grey.shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      _formatTime(
                                                          item.createdAt),
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 9,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 14),

                                                /// CONTENT ROW
                                                Row(
                                                  children: [
                                                    /// ICON
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration:
                                                          BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        gradient:
                                                            LinearGradient(
                                                          colors: isGold
                                                              ? [
                                                                  const Color(
                                                                      0xFF7A4B00),
                                                                  const Color(
                                                                      0xFFFFC400),
                                                                ]
                                                              : [
                                                                  const Color(
                                                                      0xFF707070),
                                                                  const Color(
                                                                      0xFFE0E0E0),
                                                                ],
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        isGold
                                                            ? Icons
                                                                .workspace_premium
                                                            : Icons
                                                                .currency_exchange,
                                                        color: Colors.white,
                                                        size: 22,
                                                      ),
                                                    ),

                                                    const SizedBox(width: 12),

                                                    /// DETAILS
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            item.type
                                                                .replaceAll(
                                                                    '_', ' ')
                                                                .toUpperCase(),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: const Color(
                                                                  0xFF4B0012),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          Text(
                                                            _formatCurrency(
                                                                item.totalAmount),
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color: isGold
                                                                  ? const Color(
                                                                      0xFFB88900)
                                                                  : const Color(
                                                                      0xFF6B6B6B),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    /// RIGHT — grams + status
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          _formatGrams(
                                                              item.grams),
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: isGold
                                                                ? const Color(
                                                                    0xFF8B6B00)
                                                                : const Color(
                                                                    0xFF6B6B6B),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 9,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _statusBg(
                                                                item.status),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          child: Text(
                                                            item.status
                                                                .toUpperCase(),
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color:
                                                                  _statusColor(
                                                                      item.status),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 8,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                            const SizedBox(height: 22),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Reusable pill filter bar ──────────────────────────────────────────────
  Widget _filterBar({
    required List<String> items,
    required int selected,
    required ValueChanged<int> onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7E7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(
          items.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: selected == index
                      ? const LinearGradient(
                          colors: [Color(0xFF4B0012), Color(0xFFD5004F)],
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  items[index],
                  style: GoogleFonts.poppins(
                    color: selected == index
                        ? Colors.white
                        : const Color(0xFF6A5A5A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Status badge colours ──────────────────────────────────────────────────
  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return const Color(0xFFE7F9EA);
      case 'pending':
        return const Color(0xFFFFF8E1);
      case 'failed':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
        return const Color(0xFF179B46);
      case 'pending':
        return const Color(0xFFF9A825);
      case 'failed':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  // ── Summary card ──────────────────────────────────────────────────────────
  Widget _summaryCard({
    required String title,
    required String value,
    required String suffix,
    required bool light,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: light ? const Color(0xFFF5EBEB) : null,
        gradient: light
            ? null
            : const LinearGradient(
                colors: [Color(0xFF4B0012), Color(0xFFD5004F)],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: light ? Colors.grey.shade700 : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.poppins(
                    color: light ? const Color(0xFF4B0012) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (suffix.isNotEmpty)
                  TextSpan(
                    text: " $suffix",
                    style: GoogleFonts.poppins(
                      color: light ? Colors.grey.shade700 : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}