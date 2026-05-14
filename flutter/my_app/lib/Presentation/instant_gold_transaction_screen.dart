import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/instant_purchase_screen.dart';

class GoldTransactionScreen extends StatefulWidget {
  const GoldTransactionScreen({super.key});

  @override
  State<GoldTransactionScreen> createState() =>
      _GoldTransactionScreenState();
}

class _GoldTransactionScreenState
    extends State<GoldTransactionScreen> {
  int selectedFilter = 3;

  int selectedMetal = 2;

  final List<String> filters = [
    "All",
    "Month",
    "3 Months",
    "Year",
  ];

  
  final List<String> metalType = [
    "Gold",
    "Silver",

  ];

  final List<Map<String, dynamic>> transactions = [
    {
      "title": "Instant Gold Purchase",
      "date": "24 Oct 2026",
      "time": "02:20 PM",
      "amount": "₹8,42,000",
      "grams": "8.42g",
      "status": "SUCCESS",
      "metal": "gold",
    },
    {
      "title": "Silver Savings",
      "date": "21 Oct 2026",
      "time": "11:10 AM",
      "amount": "₹1,25,000",
      "grams": "125g",
      "status": "SUCCESS",
      "metal": "silver",
    },
    {
      "title": "Gold Monthly Plan",
      "date": "18 Oct 2026",
      "time": "08:45 PM",
      "amount": "₹72,500",
      "grams": "7.20g",
      "status": "SUCCESS",
      "metal": "gold",
    },
    {
      "title": "Silver Purchase",
      "date": "14 Oct 2023",
      "time": "09:15 AM",
      "amount": "₹32,800",
      "grams": "42g",
      "status": "SUCCESS",
      "metal": "silver",
    },
  ];

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
                    // ── CHANGED: dynamic title ──
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

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// SUMMARY CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "Gold Purchased",
                          value: "142.50",
                          suffix: "grams",
                          light: true,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryCard(
                          title: "Total Invested",
                          value: "₹8,42,000",
                          suffix: "",
                          light: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// FILTERS
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E7E7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: List.generate(
                        filters.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFilter = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(22),
                                gradient: selectedFilter == index
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF4B0012),
                                          Color(0xFFD5004F),
                                        ],
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                filters[index],
                                style: GoogleFonts.poppins(
                                  color: selectedFilter == index
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
                  ),

                  const SizedBox(height: 24),

                  /// TITLE
            
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
                             /// FILTERS
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0E7E7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: List.generate(
                        metalType.length,
                        (index) => Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMetal = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 38,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(22),
                                gradient: selectedMetal == index
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF4B0012),
                                          Color(0xFFD5004F),
                                        ],
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                metalType[index],
                                style: GoogleFonts.poppins(
                                  color: selectedMetal == index
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
                  ),
                  

                  const SizedBox(height: 16),

                  /// TRANSACTION LIST
                  ListView.builder(
                    itemCount: transactions.length,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = transactions[index];

                      final bool isGold =
                          item['metal'] == "gold";

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 14),
                        child: GestureDetector(
                          onTap: (){
                              Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PurchaseSuccessScreen(),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                /// DATE SECTION
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF8F2F2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                          20,
                                        ),
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
                          
                                          const SizedBox(width: 5),
                          
                                          Text(
                                            item['date'],
                                            style:
                                                GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: Colors
                                                  .grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          
                                    const Spacer(),
                          
                                    Text(
                                      item['time'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        color:
                                            Colors.grey.shade600,
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                          
                                const SizedBox(height: 14),
                          
                                /// CONTENT
                                Row(
                                  children: [
                                    /// ICON
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: isGold
                                              ? [
                                                  const Color(
                                                    0xFF7A4B00,
                                                  ),
                                                  const Color(
                                                    0xFFFFC400,
                                                  ),
                                                ]
                                              : [
                                                  const Color(
                                                    0xFF707070,
                                                  ),
                                                  const Color(
                                                    0xFFE0E0E0,
                                                  ),
                                                ],
                                        ),
                                      ),
                                      child: Icon(
                                        isGold
                                            ? Icons.workspace_premium
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
                                            item['title'],
                                            maxLines: 1,
                                            overflow: TextOverflow
                                                .ellipsis,
                                            style:
                                                GoogleFonts.poppins(
                                              color:
                                                  const Color(
                                                0xFF4B0012,
                                              ),
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                          
                                          const SizedBox(
                                              height: 5),
                          
                                          Text(
                                            item['amount'],
                                            style:
                                                GoogleFonts.poppins(
                                              color: isGold
                                                  ? const Color(
                                                      0xFFB88900,
                                                    )
                                                  : const Color(
                                                      0xFF6B6B6B,
                                                    ),
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          
                                    /// RIGHT
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          item['grams'],
                                          style:
                                              GoogleFonts.poppins(
                                            color: isGold
                                                ? const Color(
                                                    0xFF8B6B00,
                                                  )
                                                : const Color(
                                                    0xFF6B6B6B,
                                                  ),
                                            fontWeight:
                                                FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                          
                                        const SizedBox(height: 8),
                          
                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 9,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                const Color(
                                              0xFFE7F9EA,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                              30,
                                            ),
                                          ),
                                          child: Text(
                                            item['status'],
                                            style:
                                                GoogleFonts.poppins(
                                              color:
                                                  const Color(
                                                0xFF179B46,
                                              ),
                                              fontWeight:
                                                  FontWeight.w700,
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
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required String suffix,
    required bool light,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: light ? const Color(0xFFF5EBEB) : null,
        gradient: light
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFF4B0012),
                  Color(0xFFD5004F),
                ],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: light
                  ? Colors.grey.shade700
                  : Colors.white70,
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
                    color: light
                        ? const Color(0xFF4B0012)
                        : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                TextSpan(
                  text: suffix.isNotEmpty ? " $suffix" : "",
                  style: GoogleFonts.poppins(
                    color: light
                        ? Colors.grey.shade700
                        : Colors.white70,
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