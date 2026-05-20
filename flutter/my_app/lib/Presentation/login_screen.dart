import 'package:flutter/material.dart';
import 'package:my_app/Presentation/mpin_screen.dart';
import 'package:my_app/Presentation/register_screen.dart';
import 'package:my_app/Utils/back_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isEmailSelected = true;
  final TextEditingController inputController = TextEditingController();
  
  // Validation error messages
  String? _errorMessage;

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  // Email validation method
  String? validateEmail(String email) {
    if (email.isEmpty) {
      return "Email is required";
    }
    
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return "Please enter a valid email address";
    }
    
    // Check if email ends with @gmail.com (optional strict check)
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      return "Please use a valid Gmail address (@gmail.com)";
    }
    
    return null;
  }

  // Mobile number validation method
  String? validateMobile(String mobile) {
    if (mobile.isEmpty) {
      return "Mobile number is required";
    }
    
    // Remove any non-digit characters
    final cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanMobile.length != 10) {
      return "Mobile number must be exactly 10 digits";
    }
    
    // Check if all characters are digits
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanMobile)) {
      return "Please enter a valid 10-digit mobile number";
    }
    
    // Optional: Check for common invalid patterns
    if (cleanMobile.startsWith('0')) {
      return "Mobile number cannot start with 0";
    }
    
    return null;
  }

  // Validate based on selected type
  bool validateInput() {
    final input = inputController.text.trim();
    
    if (isEmailSelected) {
      _errorMessage = validateEmail(input);
    } else {
      _errorMessage = validateMobile(input);
    }
    
    setState(() {});
    return _errorMessage == null;
  }

  // Clear error when input changes
  void onInputChanged(String value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void toggleSelection(bool isEmail) {
    setState(() {
      isEmailSelected = isEmail;
      inputController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ExitDialog.show(context),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            /// Background Image (light marble)
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
                          children: [
                            const SizedBox(height: 80),

                            /// Logo Card with Image
                            Image.asset(
                              "assets/images/img5.png",
                              width: 200,
                              height: 80,
                              fit: BoxFit.contain,
                            ),

                            const SizedBox(height: 50),

                            /// Title
                            const Text(
                              "Get Started now",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Create an account or log in to explore\nabout our app",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 25),

                            /// Toggle Buttons
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  /// Email Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => toggleSelection(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isEmailSelected
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF2A0912),
                                                    Color(0xFFE1094A),
                                                  ],
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.email,
                                                color: isEmailSelected
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                  color: isEmailSelected
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  /// Mobile Button
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => toggleSelection(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: !isEmailSelected
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF2A0912),
                                                    Color(0xFFE1094A),
                                                  ],
                                                )
                                              : null,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.phone,
                                                color: !isEmailSelected
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Mobile",
                                                style: TextStyle(
                                                  color: !isEmailSelected
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// Input Field with Validation
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: inputController,
                                  keyboardType: isEmailSelected
                                      ? TextInputType.emailAddress
                                      : TextInputType.phone,
                                  onChanged: onInputChanged,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      isEmailSelected ? Icons.email : Icons.phone,
                                      color: _errorMessage != null 
                                          ? Colors.red 
                                          : null,
                                    ),
                                    hintText: isEmailSelected
                                        ? "Enter your email"
                                        : "Enter 10-digit mobile number",
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: _errorMessage != null 
                                            ? Colors.red 
                                            : const Color(0xFFE1094A),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    errorText: _errorMessage,
                                    errorStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                
                                /// Helper text for mobile number
                            
                                  
                          
                              ],
                            ),

                            const SizedBox(height: 25),

                            /// Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Validate input before proceeding
                                  if (!validateInput()) {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(_errorMessage!),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    return;
                                  }

                                  final input = inputController.text.trim();

                                  try {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MpinScreen(
                                          mobile: isEmailSelected ? "" : input,
                                          email: isEmailSelected ? input : "",
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceAll(
                                            "Exception: ",
                                            "",
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                                child: Ink(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2A0912),
                                        Color(0xFFE1094A),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Bottom Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't Have An Account? "),
                                GestureDetector(
                                   onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterScreen(
                                          defaultLoginType: isEmailSelected ? 'email' : 'mobile',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Colors.red,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}