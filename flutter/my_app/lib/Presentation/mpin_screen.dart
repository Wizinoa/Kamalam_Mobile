import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Presentation/otp_screen.dart';
import 'package:my_app/Presentation/login_screen.dart';
import 'package:my_app/Providers/auth_provider.dart';
import 'package:my_app/Utils/enum.dart';
import 'package:provider/provider.dart';

class MpinScreen extends StatefulWidget {
  final String mobile;
  final String email;

  const MpinScreen({super.key, required this.mobile, required this.email});

  @override
  State<MpinScreen> createState() => _MpinScreenState();
}

class _MpinScreenState extends State<MpinScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String otp = "";

  @override
  void initState() {
    super.initState();
    // Request focus and show keyboard after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        // Force keyboard to show
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
  }

  void _onOtpChanged(String value) async {
    setState(() {
      otp = value;
    }); 

    if (value.length == 4) {
      try {
        final provider = Provider.of<AuthProvider>(context, listen: false);

        await provider.loginApi(
          mobile: widget.mobile,
          email: widget.email,
          mpin: value,
        );
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
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
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 TITLE
                    const Text(
                      "Congratulation!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔹 MESSAGE
                    const Text(
                      "Your registration with Kamalam DigiGold\nis completed successfully",
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
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
      } catch (e) {
        if (!mounted) return;

        String errorMessage = e
            .toString()
            .replaceFirst("Exception: ", "")
            .trim();

        if (errorMessage.toLowerCase().contains("user not found")) {
          /// 👉 Show message first
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));

          /// 👉 Wait, then navigate
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          });

          return;
        }

        /// 👉 Other errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));

        _controller.clear();
        setState(() => otp = "");
      }
    }
  }

  Widget buildOtpCircle(int index) {
    bool isActive = index == otp.length;

    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(2), // 🔑 border thickness
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
              )
            : null,
        border: !isActive
            ? Border.all(
                color: index < otp.length
                    ? const Color(0xFF7A0C0C)
                    : Colors.grey.shade300,
                width: 2,
              )
            : null,
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white, // 🔑 inner background
        ),
        child: Text(
          index < otp.length ? otp[index] : "",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7A0C0C),
          ),
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
          /// 🔹 Background
          Positioned.fill(
            child: Image.asset("assets/images/img4.png", fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  /// ✅ THIS FIXES OVERFLOW
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        },
                        child: Column(
                          children: [
                            const SizedBox(height: 80),

                            /// 🔶 Logo Card with Image
                            Image.asset(
                              "assets/images/img5.png", // replace with your logo path
                              width: 200, // adjust as needed
                              height: 80, // adjust as needed
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 30),

                            /// 🔹 Title
                            const Text(
                              "Enter MPIN",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Enter your MPIN to continue your account is protected at all times",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 25),

                            /// 🔢 OTP Circles
                            GestureDetector(
                              onTap: () {
                                _focusNode.requestFocus();
                                SystemChannels.textInput.invokeMethod('TextInput.show');
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(
                                  4,
                                  (index) => buildOtpCircle(index),
                                ),
                              ),
                            ),

                            /// 🔐 Hidden Input
                            Opacity(
                              opacity: 0,
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                autofocus: true,
                                onChanged: _onOtpChanged,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: "",
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpScreen(
                                      mobile: widget.mobile,
                                      email: widget.email,
                                      flow: OtpFlow.forgotMpin,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Forgot your MPIN ?",
                                style: TextStyle(
                                  color: Color(0xFFE52D27),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
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
    );
  }
}
