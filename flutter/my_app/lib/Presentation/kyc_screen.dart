import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Presentation/payment_screen.dart';
import 'package:my_app/Providers/user_provider.dart';
import 'package:provider/provider.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({super.key, this.isSilverScheme = false});

  final bool isSilverScheme;

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  TextStyle _poppins(double size, FontWeight weight, Color color) {
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.2,
    );
  }

  bool isEditing = false;
  bool isNomineeEditing = false;

  final door = TextEditingController(text: "42/A");
  final pin = TextEditingController(text: "560001");
  final street = TextEditingController(text: "MG Road");
  final area = TextEditingController(text: "Shivaji Nagar");
  final city = TextEditingController(text: "Bangalore");
  final state = TextEditingController(text: "Karnataka");

  /// NOMINEE CONTROLLERS
  final nomineeName = TextEditingController(text: "Alagu");
  final nomineeMobile = TextEditingController(text: "+91 98765 12345");
  final nomineeEmail = TextEditingController(text: "priya.sharma@email.com");

  /// KYC CONTROLLERS
  final pan = TextEditingController();
  final aadhaar = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// 🔹 Listen PIN changes
    pin.addListener(() {
      if (pin.text.length == 6) {
        fetchPincode(pin.text);
      }
    });
  }

  /// 🔹 API CALL
  Future<void> fetchPincode(String pincode) async {
    try {
      final response = await http.get(
        Uri.parse("https://api.postalpincode.in/pincode/$pincode"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data[0]["Status"] == "Success") {
          final postOffice = data[0]["PostOffice"][0];

          setState(() {
            city.text = postOffice["District"] ?? "";
            state.text = postOffice["State"] ?? "";
          });
        }
      }
    } catch (e) {
      debugPrint("Pincode error: $e");
    }
  }

  @override
  void dispose() {
    door.dispose();
    pin.dispose();
    street.dispose();
    area.dispose();
    city.dispose();
    state.dispose();
    nomineeName.dispose();
    nomineeMobile.dispose();
    nomineeEmail.dispose();
    pan.dispose();
    aadhaar.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      if (userProvider.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
        final user = userProvider.user;
     return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: Column(
        children: [
          // HEADER
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
                const SizedBox(width: 12),
                const Text(
                  "Document Verification",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  // BASIC DETAILS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFD4A93A),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Basic Details",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text("Full Name", style: TextStyle(fontSize: 12)),
                       Text(user?.fullName ?? "N/A"),
                        const SizedBox(height: 10),
                        const Text(
                          "Mobile Number",
                          style: TextStyle(fontSize: 12),
                        ),
                             Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(user?.mobile ?? "N/A"),
                              Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F6EC),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 12,
                                    color: Color(0xFF13A64A),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: _poppins(
                                      11,
                                      FontWeight.w500,
                                      const Color(0xFF13A64A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                               ],
                             ),

                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Email", style: TextStyle(fontSize: 12)),
                                    Text(user?.email ?? "N/A"),
                              ],
                            ),
                           
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// ================= ADDRESS SECTION =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFD4A93A),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Address Details",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isEditing = !isEditing;
                                });
                              },
                              child: Icon(
                                isEditing ? Icons.check : Icons.edit,
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// ROW 1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Door No",
                                  style: TextStyle(fontSize: 12),
                                ),
                                isEditing
                                    ? SizedBox(
                                        width: 80,
                                        child: TextField(
                                          controller: door,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                          ),
                                        ),
                                      )
                                    : Text(door.text),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "PIN Code",
                                  style: TextStyle(fontSize: 12),
                                ),
                                isEditing
                                    ? SizedBox(
                                        width: 80,
                                        child: TextField(
                                          controller: pin,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                          ),
                                        ),
                                      )
                                    : Text(pin.text),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// STREET
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Street",
                                style: TextStyle(fontSize: 12),
                              ),
                              isEditing
                                  ? TextField(
                                      controller: street,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                      ),
                                    )
                                  : Text(street.text),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// AREA
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Area / Locality",
                                style: TextStyle(fontSize: 12),
                              ),
                              isEditing
                                  ? TextField(
                                      controller: area,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                      ),
                                    )
                                  : Text(area.text),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// ROW 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "City",
                                  style: TextStyle(fontSize: 12),
                                ),
                                isEditing
                                    ? SizedBox(
                                        width: 100,
                                        child: TextField(
                                          controller: city,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                          ),
                                        ),
                                      )
                                    : Text(city.text),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "State",
                                  style: TextStyle(fontSize: 12),
                                ),
                                isEditing
                                    ? SizedBox(
                                        width: 100,
                                        child: TextField(
                                          controller: state,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                          ),
                                        ),
                                      )
                                    : Text(state.text),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ================= NOMINEE EDITABLE =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFD4A93A),
                              child: Icon(Icons.group, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: Text("Nominee Details")),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isNomineeEditing = !isNomineeEditing;
                                });
                              },
                              child: Icon(
                                isNomineeEditing ? Icons.check : Icons.edit,
                                size: 18,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// NAME
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Nominee Name",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              isNomineeEditing
                                  ? TextField(controller: nomineeName)
                                  : Text(nomineeName.text),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// MOBILE
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Mobile Number"),
                              isNomineeEditing
                                  ? TextField(controller: nomineeMobile)
                                  : Text(nomineeMobile.text),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        

                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// ================= KYC PROOF =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: const [
                            CircleAvatar(
                              backgroundColor: Color(0xFFD4A93A),
                              child: Icon(Icons.badge, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Expanded(child: Text(" Proof")),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "PAN Number",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// PAN
                        TextField(
                          controller: pan,
                          decoration: InputDecoration(
                            hintText: "ABCD1234F",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "AADHAAR Number",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// AADHAAR
                        TextField(
                          controller: aadhaar,
                          decoration: InputDecoration(
                            hintText: "**** **** 4567",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  /// 🔥 CLEAR INPUT ON CANCEL
                                  pan.clear();
                                  aadhaar.clear();
                                  setState(() {});
                                },
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5A0015),
                                      Color(0xFFE6003A),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Save",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // FINAL CONFIRM BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DidigoldScreen(
                            isSilverScheme: widget.isSilverScheme,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5A0015), Color(0xFFE6003A)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
     );
});
  }
}
