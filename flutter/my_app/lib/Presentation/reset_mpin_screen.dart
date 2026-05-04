import 'package:flutter/material.dart';
import 'package:my_app/Presentation/login_screen.dart';
import 'package:my_app/Providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ResetScreen extends StatefulWidget {
  final String mobile;
  final String email;
  final String otp;

  const ResetScreen({
    super.key,
    required this.mobile,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final TextEditingController _mpinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final FocusNode _mpinFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  String mpin = "";
  String confirmMpin = "";
  bool isLoading = false;

  /// 🔹 MPIN Input
  void _onMpinChanged(String value) {
    setState(() {
      mpin = value;
    });
  }

  /// 🔹 Confirm MPIN Input (ONLY UPDATE STATE)
  void _onConfirmChanged(String value) {
    setState(() {
      confirmMpin = value;
    });
  }

  /// 🔥 BUTTON CLICK → VALIDATION + API CALL
  void _validateAndSubmit() async {
    if (isLoading) return;

    if (mpin.length != 4 || confirmMpin.length != 4) {
      _showError("Please enter 4-digit MPIN");
      return;
    }

    if (mpin != confirmMpin) {
      _showError("MPIN does not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final provider = Provider.of<AuthProvider>(context, listen: false);

      await provider.registerMpin(
        mobile: widget.mobile,
        email: widget.email,
        mpin: mpin,
      );

      if (!mounted) return;

      /// ✅ SUCCESS
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      String error = e.toString().replaceFirst("Exception: ", "").trim();

      /// 👉 USER NOT FOUND → LOGIN
      if (error.toLowerCase().contains("user not found")) {
        _showError(error);

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        });
      } else {
        _showError(error);
      }

      _mpinController.clear();
      _confirmController.clear();

      setState(() {
        mpin = "";
        confirmMpin = "";
      });
    }

    setState(() => isLoading = false);
  }

  /// ✅ Success Popup
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔶 SUCCESS ICON
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF2B0A12), Color(0xFFE11B4C)],
                    ),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),

                const SizedBox(height: 20),

                /// 🔹 TITLE
                const Text(
                  "Congratulation!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                /// 🔹 MESSAGE
                const Text(
                  "Your reset MPIN successfully. Please login again with new MPIN.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                /// 🔴 BUTTON
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B0A12), Color(0xFFE11B4C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // IMPORTANT
                        shadowColor: Colors.transparent, // remove shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Continue",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ❌ Error Snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 🔢 Circle UI (UNCHANGED)
  Widget buildOtpCircle(int index, String value) {
    bool isActive = index == value.length;

    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? const Color(0xFFE52D27)
              : index < value.length
              ? const Color(0xFF7A0C0C)
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Text(
        index < value.length ? value[index] : "",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7A0C0C),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/img4.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),

                          Center(
                            child: Image.asset(
                              "assets/images/img5.png",
                              width: 200,
                              height: 80,
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Center(
                            child: Text(
                              "Reset MPIN",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          const Text("Your MPIN"),
                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: () {
                              FocusScope.of(context).requestFocus(_mpinFocus);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (index) => buildOtpCircle(index, mpin),
                              ),
                            ),
                          ),

                          Opacity(
                            opacity: 0,
                            child: TextField(
                              controller: _mpinController,
                              focusNode: _mpinFocus,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              onChanged: _onMpinChanged,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text("Confirm MPIN"),
                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: () {
                              FocusScope.of(
                                context,
                              ).requestFocus(_confirmFocus);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (index) => buildOtpCircle(index, confirmMpin),
                              ),
                            ),
                          ),

                          Opacity(
                            opacity: 0,
                            child: TextField(
                              controller: _confirmController,
                              focusNode: _confirmFocus,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              onChanged: _onConfirmChanged,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _validateAndSubmit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Ink(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(30),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF7A0C0C),
                                            Color(0xFFE52D27),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Change MPIN",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
