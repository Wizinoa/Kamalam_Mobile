import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/Presentation/payment_screen.dart';
import 'package:my_app/Providers/user_provider.dart';
import 'package:provider/provider.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({
    super.key,
    this.isSilverScheme = false,
    required this.schemeId,
    required this.name,
    required this.maturityDate,
  });

  final bool isSilverScheme;
  final String schemeId;
  final String name;
  final DateTime maturityDate;

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

  bool isEditingAddress = false;
  bool isEditingBasicDetails = false;

  // Address controllers
  final door = TextEditingController();
  final pin = TextEditingController();
  final street = TextEditingController();
  final area = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();

  // Basic details controllers
  final fullNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  final nomineeName = TextEditingController(text: "Alagu");
  final nomineeMobile = TextEditingController(text: "+91 98765 12345");
  final nomineeEmail = TextEditingController(text: "priya.sharma@email.com");

  final pan = TextEditingController();
  final aadhaar = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Fetch fresh data then fill all fields once API responds
      userProvider.fetchUser().then((_) {
        final user = userProvider.user;
        if (user != null) {
          setAddressFromUser(user);
          setKycFromUser(user);
          setBasicDetailsFromUser(user);
        }
      });
    });

    pin.addListener(() {
      if (pin.text.length == 6) {
        fetchPincode(pin.text);
      }
    });
  }

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

  void setAddressFromUser(user) {
    if (user == null) return;
    final addr = user.address;
    if (addr != null) {
      setState(() {
        door.text = addr['door'] ?? '';
        street.text = addr['street'] ?? '';
        area.text = addr['area'] ?? '';
        city.text = addr['city'] ?? '';
        state.text = addr['state'] ?? '';
        pin.text = addr['pincode'] ?? '';
      });
    }
  }

  void setBasicDetailsFromUser(user) {
    if (user == null) return;
    setState(() {
      fullNameController.text = user.fullName ?? '';
      mobileController.text = user.mobile ?? '';
      emailController.text = user.email ?? '';
    });
  }

  void setKycFromUser(user) {
    if (user == null) return;
    setState(() {
      pan.text = user.panNumber ?? '';
      aadhaar.text = user.aadharNumber ?? '';
    });
  }

  Future<void> saveAddress(UserProvider userProvider) async {
    final user = userProvider.user;
    final success = await userProvider.updateUser(
      fullName: user?.fullName ?? '',
      email: user?.email ?? '',
      mobile: user?.mobile ?? '',
      address: {
        "door": door.text.trim(),
        "street": street.text.trim(),
        "area": area.text.trim(),
        "city": city.text.trim(),
        "state": state.text.trim(),
        "pincode": pin.text.trim(),
        "country": "India",
      },
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Address Updated")));
      setState(() => isEditingAddress = false);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Update Failed")));
    }
  }

  Future<void> saveBasicDetails(UserProvider userProvider) async {
    final fullName = fullNameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter full name")));
      return;
    }

    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter mobile number")),
      );
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter email")));
      return;
    }

    final user = userProvider.user;
    final success = await userProvider.updateUser(
      fullName: fullName,
      email: email,
      mobile: mobile,
      address: user?.address,
      panNumber: user?.panNumber,
      aadharNumber: user?.aadharNumber,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Basic details updated"),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => isEditingBasicDetails = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update basic details"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveKyc(UserProvider userProvider) async {
    final panText = pan.text.trim();
    final aadhaarText = aadhaar.text.trim();

    if (panText.isEmpty || aadhaarText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter PAN and Aadhaar")),
      );
      return;
    }

    final user = userProvider.user;
    final success = await userProvider.updateUser(
      fullName: user?.fullName ?? '',
      email: user?.email ?? '',
      mobile: user?.mobile ?? '',
      address: user?.address,
      panNumber: panText,
      aadharNumber: aadhaarText,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("KYC details saved"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save KYC"),
          backgroundColor: Colors.red,
        ),
      );
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
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
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
        // Show loader only on very first load when no user data yet
        if (userProvider.isLoading && userProvider.user == null) {
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
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
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFD4A93A),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Basic Details",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isEditingBasicDetails) {
                                      await saveBasicDetails(userProvider);
                                    } else {
                                      setState(
                                        () => isEditingBasicDetails = true,
                                      );
                                    }
                                  },
                                  child: Icon(
                                    isEditingBasicDetails
                                        ? Icons.check
                                        : Icons.edit,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              "Full Name",
                              style: TextStyle(fontSize: 12),
                            ),
                            isEditingBasicDetails
                                ? TextField(
                                    controller: fullNameController,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                : Text(user?.fullName ?? "N/A"),
                            const SizedBox(height: 10),
                            const Text(
                              "Mobile Number",
                              style: TextStyle(fontSize: 12),
                            ),
                            isEditingBasicDetails
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: mobileController,
                                          keyboardType: TextInputType.phone,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F6EC),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
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
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(user?.mobile ?? "N/A"),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F6EC),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
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
                            const Text("Email", style: TextStyle(fontSize: 12)),
                            isEditingBasicDetails
                                ? TextField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                : Text(user?.email ?? "N/A"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ADDRESS SECTION
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (isEditingAddress) {
                                      await saveAddress(userProvider);
                                    } else {
                                      setState(() => isEditingAddress = true);
                                    }
                                  },
                                  child: Icon(
                                    isEditingAddress ? Icons.check : Icons.edit,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Address Line",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  isEditingAddress
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "PIN Code",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    isEditingAddress
                                        ? SizedBox(
                                            width: 80,
                                            child: TextField(
                                              controller: pin,
                                              keyboardType:
                                                  TextInputType.number,
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
                                    isEditingAddress
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
                                    isEditingAddress
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

                      const SizedBox(height: 14),

                      // KYC PROOF SECTION
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
                                Expanded(child: Text("KYC Proof")),
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
                            const SizedBox(height: 8),
                            TextField(
                              controller: pan,
                              textCapitalization: TextCapitalization.characters,
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
                            const SizedBox(height: 8),
                            TextField(
                              controller: aadhaar,
                              keyboardType: TextInputType.number,
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
                                    onPressed: () => setKycFromUser(user),
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => saveKyc(userProvider),
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CONFIRM BUTTON
                      GestureDetector(
                        onTap: () {
                          if (pan.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter your PAN number"),
                              ),
                            );
                            return;
                          }

                          if (aadhaar.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter your Aadhaar number",
                                ),
                              ),
                            );
                            return;
                          }

                          if (mobileController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter your mobile number",
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DidigoldScreen(
                                isSilverScheme: widget.isSilverScheme,
                                schemeId: widget.schemeId,
                                name: widget.name,
                                maturityDate: widget.maturityDate,
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
      },
    );
  }
}
