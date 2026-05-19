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
  int _attemptsLeft = 5;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    // Request focus and show keyboard after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isLocked) {
        _focusNode.requestFocus();
        // Force keyboard to show
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetLock() {
    setState(() {
      _isLocked = false;
      _attemptsLeft = 5;
      _controller.clear();
      otp = "";
    });
    
    // Request focus again after reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
  }

  void _showAttemptsExhaustedDialog() {
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
                /// 🔶 ERROR ICON
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
                    Icons.warning,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                
                /// 🔹 TITLE
                const Text(
                  "Maximum Attempts Exceeded!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                /// 🔹 MESSAGE
                const Text(
                  "You have exceeded the maximum number of attempts.\nPlease reset your MPIN to continue.",
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
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          "Reset MPIN",
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

  void _showRemainingAttemptsDialog(int attemptsLeft) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFE11B4C),
                  size: 50,
                ),
                const SizedBox(height: 15),
                Text(
                  "Incorrect MPIN!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE11B4C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "You have $attemptsLeft attempt${attemptsLeft != 1 ? 's' : ''} remaining",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      color: Color(0xFFE11B4C),
                      fontWeight: FontWeight.bold,
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

  void _onOtpChanged(String value) async {
    setState(() {
      otp = value;
    }); 

    if (value.length == 4 && !_isLocked) {
      try {
        final provider = Provider.of<AuthProvider>(context, listen: false);

        await provider.loginApi(
          mobile: widget.mobile,
          email: widget.email,
          mpin: value,
        );
        
        if (!mounted) return;
        
        // Reset attempts on successful login
        setState(() {
          _attemptsLeft = 5;
        });
        
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
                      "Congratulations!",
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
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
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
      } catch (e) {
        if (!mounted) return;
        
        // Decrease attempts on incorrect MPIN
        setState(() {
          _attemptsLeft--;
        });
        
        String errorMessage = e
            .toString()
            .replaceFirst("Exception: ", "")
            .trim();
            
        // Check if attempts are exhausted
        if (_attemptsLeft <= 0) {
          setState(() {
            _isLocked = true;
            _controller.clear();
            otp = "";
          });
          
          // Show dialog to reset MPIN
          _showAttemptsExhaustedDialog();
          return;
        }
        
        // Check if error is about user not found
        if (errorMessage.toLowerCase().contains("user not found")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage))
          );
          
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          });
          return;
        }
        
        // Show remaining attempts message for incorrect MPIN
        _showRemainingAttemptsDialog(_attemptsLeft);
        
        // Clear the input
        _controller.clear();
        setState(() => otp = "");
      }
    }
  }

  Widget buildOtpCircle(int index) {
    bool isActive = index == otp.length && !_isLocked;
    
    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(2),
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
                    : (_isLocked ? Colors.grey.shade300 : Colors.grey.shade300),
                width: 2,
              )
            : null,
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Text(
          index < otp.length ? otp[index] : "",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isLocked ? Colors.grey : const Color(0xFF7A0C0C),
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
          
          /// 🔹 Blur overlay when locked
          if (_isLocked)
            Container(
              color: Colors.black.withOpacity(0.5),
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
                      child: GestureDetector(
                        onTap: () {
                          if (!_isLocked) {
                            FocusScope.of(context).requestFocus(_focusNode);
                          }
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
                            
                            /// 🔢 Attempts remaining indicator
                            if (!_isLocked && _attemptsLeft < 5)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  "$_attemptsLeft attempts remaining",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            
                            if (!_isLocked && _attemptsLeft < 5)
                              const SizedBox(height: 15),
                            
                            /// 🔢 OTP Circles
                            GestureDetector(
                              onTap: () {
                                if (!_isLocked) {
                                  _focusNode.requestFocus();
                                  SystemChannels.textInput.invokeMethod('TextInput.show');
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                ignoring: _isLocked,
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  autofocus: true,
                                  enabled: !_isLocked,
                                  onChanged: _onOtpChanged,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 10),
                            
                            /// 🔹 Forgot MPIN link
                            GestureDetector(
                              onTap: _isLocked
                                  ? () {
                                      _showAttemptsExhaustedDialog();
                                    }
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OtpScreen(
                                            mobile: widget.mobile,
                                            email: widget.email,
                                            flow: OtpFlow.forgotMpin,
                                          ),
                                        ),
                                      ).then((_) {
                                        // Reset attempts if coming back from reset
                                        if (mounted && !_isLocked) {
                                          _resetLock();
                                        }
                                      });
                                    },
                              child: Text(
                                _isLocked ? "Reset MPIN" : "Forgot your MPIN?",
                                style: TextStyle(
                                  color: _isLocked 
                                      ? const Color(0xFFE11B4C)
                                      : const Color(0xFFE52D27),
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