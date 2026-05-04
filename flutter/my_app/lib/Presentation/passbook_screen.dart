import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Utils/back_screen.dart';
import 'package:my_app/Utils/bottom_navigation.dart';

class PassbookScreen extends StatefulWidget {
  const PassbookScreen({super.key});

  @override
  State<PassbookScreen> createState() => _PassbookScreenState();
}

class _PassbookScreenState extends State<PassbookScreen> {
  bool _showRewards = false;

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_function_declarations_over_variables
    final p = (double s, FontWeight w, Color c) =>
        GoogleFonts.poppins(fontSize: s, fontWeight: w, color: c, height: 1.2);

        

    return WillPopScope(
  onWillPop: () => ExitDialog.show(context),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Scheme Passbook",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
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
        body: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          color: const Color(0xFFF7F7F7),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3A0013), Color(0xFFD1004C)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'DIGIGOLD',
                                      textAlign: TextAlign.center,
                                      style: p(12, FontWeight.w700, Colors.white),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.help,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _kv(p, 'Scheme Name', 'Alagu')),
                                Expanded(
                                  child: _kv(
                                    p,
                                    'Scheme ID',
                                    'TM2024001',
                                    right: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _kv(p, 'Total Amount Paid', '₹2,500'),
                                ),
                                Expanded(
                                  child: _kv(
                                    p,
                                    'Average Rate / g',
                                    '₹6,850',
                                    right: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _kv(p, 'Saved Weight', '0.214g')),
                                Expanded(
                                  child: _kv(
                                    p,
                                    'Benefit on Maturity',
                                    '₹500',
                                    right: true,
                                    valueColor: const Color(0xFF00A651),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3A0013), Color(0xFFD1004C)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Reward Earned   0g',
                                      style: p(
                                        10,
                                        FontWeight.w600,
                                        const Color(0xFFF4BE45),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB13A49),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.monetization_on,
                                          size: 14,
                                          color: Color(0xFFF4BE45),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total Gold Saved\n0.214g',
                                          style: p(
                                            8,
                                            FontWeight.w500,
                                            Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE6E6E6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _kv(
                                      p,
                                      'Date of Joining',
                                      '15 Jan 2024',
                                    ),
                                  ),
                                  Expanded(
                                    child: _kv(
                                      p,
                                      'Date of Maturity',
                                      '15 Jan 2025',
                                      right: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECECEE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _showRewards = false),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    gradient: _showRewards
                                        ? null
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFF3A0013),
                                              Color(0xFFD1004C),
                                            ],
                                          ),
                                    color: _showRewards
                                        ? Colors.transparent
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Receipts',
                                      style: p(
                                        12,
                                        FontWeight.w600,
                                        _showRewards
                                            ? const Color(0xFF80869A)
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _showRewards = true),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 34,
                                  decoration: BoxDecoration(
                                    gradient: _showRewards
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF3A0013),
                                              Color(0xFFD1004C),
                                            ],
                                          )
                                        : null,
                                    color: _showRewards
                                        ? null
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Rewards',
                                      style: p(
                                        12,
                                        FontWeight.w600,
                                        _showRewards
                                            ? Colors.white
                                            : const Color(0xFF80869A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_showRewards) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Transaction History',
                            style: p(
                              14,
                              FontWeight.w600,
                              const Color(0xFF2F2F2F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Status',
                                  style: p(
                                    10,
                                    FontWeight.w400,
                                    const Color(0xFF7D7D7D),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Date',
                                  style: p(
                                    10,
                                    FontWeight.w400,
                                    const Color(0xFF7D7D7D),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Amount',
                                  style: p(
                                    10,
                                    FontWeight.w400,
                                    const Color(0xFF7D7D7D),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Saved Weight',
                                  style: p(
                                    10,
                                    FontWeight.w400,
                                    const Color(0xFF7D7D7D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...List.generate(
                          5,
                          (_) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE5E5E5)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Color(0xFF79D09C),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '01 Feb',
                                    style: p(
                                      11,
                                      FontWeight.w500,
                                      const Color(0xFF343434),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '₹500',
                                    style: p(
                                      11,
                                      FontWeight.w500,
                                      const Color(0xFF343434),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '0.072g',
                                    style: p(
                                      11,
                                      FontWeight.w500,
                                      const Color(0xFF343434),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E5E5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Target Achieved',
                                    style: p(
                                      11,
                                      FontWeight.w500,
                                      const Color(0xFF5A5A5A),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '6.83% Completed',
                                    style: p(
                                      11,
                                      FontWeight.w600,
                                      const Color(0xFF00A651),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: 0.0683,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFE1E1E1),
                                  color: const Color(0xFF00A651),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 18),
                        Image.asset(
                          'assets/images/img19.png',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 18),
                      ],
                      const SizedBox(height: 16),
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 48,
                      //   child: DecoratedBox(
                      //     decoration: BoxDecoration(
                      //       gradient: const LinearGradient(
                      //         colors: [Color(0xFF3A0013), Color(0xFFD1004C)],
                      //       ),
                      //       borderRadius: BorderRadius.circular(24),
                      //     ),
                      //     child: ElevatedButton(
                      //       onPressed: () {},
                      //       style: ElevatedButton.styleFrom(
                      //         backgroundColor: Colors.transparent,
                      //         shadowColor: Colors.transparent,
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(24),
                      //         ),
                      //       ),
                      //       child: Text(
                      //         'Pay Now',
                      //         style: p(17 / 2 + 2, FontWeight.w600, Colors.white),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: AppBottomNavigation(currentIndex: 2),
        ),
      ),
    );
  }

  Widget _kv(
    TextStyle Function(double, FontWeight, Color) p,
    String k,
    String v, {
    bool right = false,
    Color valueColor = const Color(0xFF2D2D2D),
  }) {
    return Column(
      crossAxisAlignment: right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(k, style: p(10, FontWeight.w400, const Color(0xFF7A7A7A))),
        const SizedBox(height: 4),
        Text(v, style: p(14, FontWeight.w700, valueColor)),
      ],
    );
  }
}
