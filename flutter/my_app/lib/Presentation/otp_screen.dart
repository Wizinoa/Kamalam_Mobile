import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Presentation/create_mpin_screen.dart';
import 'package:my_app/Presentation/reset_mpin_screen.dart';
import 'package:my_app/Providers/auth_provider.dart';
import 'package:my_app/Utils/enum.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final String email;
  final OtpFlow flow;

  const OtpScreen({
    super.key,
    required this.mobile,
    required this.email, 
    required this.flow,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String otp = "";
  
  // Timer variables
  int _remainingSeconds = 0;
  bool _isTimerActive = false;
  Timer? _timer;
  
  // App lifecycle listener
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    
    // Add observer for app lifecycle
    WidgetsBinding.instance.addObserver(this);
    
    // Set up lifecycle listener for better control
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        // Request focus when app resumes from background
        _requestFocusWithDelay();
      },
    );

    // Request focus and show keyboard after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _resendOtp();
    });
  }
  
  // Helper method to request focus with a small delay
  void _requestFocusWithDelay() {
    // Small delay to ensure the UI is ready
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _focusNode.canRequestFocus) {
        _focusNode.requestFocus();
        
        // If there's already some OTP entered, move cursor to the end
        if (_controller.text.isNotEmpty) {
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Handle different lifecycle states
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - request focus
        _requestFocusWithDelay();
        break;
      case AppLifecycleState.inactive:
        // App is in inactive state (like when switching apps)
        break;
      case AppLifecycleState.paused:
        // App is in background - can optionally save state here
        break;
      case AppLifecycleState.detached:
        // App is about to be destroyed
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.

        throw UnimplementedError();
    }
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _isTimerActive = true;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _isTimerActive = false;
    setState(() {});
  }

  void _onOtpChanged(String value) async {
    setState(() {
      otp = value;
    });

    if (value.length == 4) {
      final provider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await provider.otpVerification(
          mobile: widget.mobile,
          otp: value,
          email: widget.email,
        );

        if (!mounted) return;

        if (widget.flow == OtpFlow.signup) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateMpin(
                mobile: widget.mobile,
                email: widget.email,
                otp: value,
              ),
            ),
          );
        } else if (widget.flow == OtpFlow.forgotMpin) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetScreen(
                mobile: widget.mobile,
                email: widget.email,
                otp: value,
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );

        _controller.clear();
        setState(() {
          otp = "";
        });
        
        // Keep focus and keyboard after error
        _focusNode.requestFocus();
      }
    }
  }

  void _resendOtp() async {
    // Don't allow resend if timer is active
    if (_isTimerActive) return;

    try {
      final provider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      bool otpSent = false;

      /// FIRST TRY MOBILE OTP
      if (widget.mobile.isNotEmpty) {
        try {
          await provider.sendOtp(
            widget.mobile,
            isEmail: false,
          );
          otpSent = true;
        } catch (mobileError) {
          print("Mobile OTP failed: $mobileError");

          /// IF MOBILE FAILS -> SEND EMAIL OTP
          if (widget.email.isNotEmpty && _isValidEmail(widget.email)) {
            await provider.sendOtp(
              widget.email,
              isEmail: true,
            );
            otpSent = true;

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Mobile OTP failed. OTP sent to email",
                  ),
                ),
              );
            }
          }
        }
      }

      /// IF MOBILE NOT AVAILABLE -> DIRECT EMAIL
      else if (widget.email.isNotEmpty && _isValidEmail(widget.email)) {
        await provider.sendOtp(
          widget.email,
          isEmail: true,
        );
        otpSent = true;
      }

      /// NO CONTACT FOUND
      if (!otpSent) {
        throw Exception(
          "No valid mobile number or email found",
        );
      }

      if (!mounted) return;

      /// START TIMER
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP resent successfully"),
        ),
      );
      
      // Keep focus after resend
      _focusNode.requestFocus();

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
          ),
        ),
      );
    }
  }
  
  // Helper method to validate email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Widget buildOtpCircle(int index) {
    bool isActive = index == otp.length;

    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? const Color(0xFFE52D27)
              : index < otp.length
              ? const Color(0xFF7A0C0C)
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Text(
        index < otp.length ? otp[index] : "",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF7A0C0C),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Remove observer and dispose lifecycle listener
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener?.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _stopTimer();
    super.dispose();
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
                              "assets/images/img5.png",
                              width: 200,
                              height: 80,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 30),

                            /// 🔹 Title
                            const Text(
                              "OTP Verification",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              "Enter the OTP sent to your DigiGold registered email or mobile number",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 25),

                            const SizedBox(height: 30),

                            /// 🔢 OTP Circles
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context).requestFocus(_focusNode);
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
                              child: IgnorePointer(
                                ignoring: false,
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
                            ),

                            const SizedBox(height: 10),

                            /// ℹ️ Info
                            const Text(
                              "Trying to fetch your OTP. Kamalam DigiGold\ncannot read your other SMS's",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 30),

                            /// 🔁 Resend with Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Didn't receive OTP? ",
                                  style: TextStyle(color: Colors.grey),
                                ),

                                _isTimerActive
                                    ? Text(
                                        "Resend in $_remainingSeconds sec",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: _resendOtp,
                                        child: const Text(
                                          "Resend Now",
                                          style: TextStyle(
                                            color: Color(0xFFE52D27),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ],
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