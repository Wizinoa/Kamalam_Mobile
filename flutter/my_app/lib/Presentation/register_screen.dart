// ignore_for_file: unused_field

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Presentation/terms_and_conditions.dart';
import 'package:my_app/Providers/auth_provider.dart';
import 'package:my_app/Utils/enum.dart';
import 'package:provider/provider.dart';
import 'package:my_app/Presentation/login_screen.dart';
import 'package:my_app/Presentation/otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? defaultLoginType; // 'email' or 'mobile'

  const RegisterScreen({super.key, this.defaultLoginType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isChecked = false;
  bool showEmailField = true;
  bool showMobileField = true;

  // Validation error messages
  String? _nameError;
  String? _mobileError;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Set field visibility based on the passed parameter
    if (widget.defaultLoginType == 'email') {
      showEmailField = true;
      showMobileField = false;
    } else if (widget.defaultLoginType == 'mobile') {
      showEmailField = false;
      showMobileField = true;
    } else {
      // Default: show both fields
      showEmailField = true;
      showMobileField = true;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Name validation
  String? validateName(String name) {
    if (name.isEmpty) {
      return "Name is required";
    }
    if (name.length < 3) {
      return "Name must be at least 3 characters";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return "Name should only contain letters and spaces";
    }
    return null;
  }

  // Mobile validation
  String? validateMobile(String mobile) {
    if (showMobileField) {
      if (mobile.isEmpty) {
        return "Mobile number is required";
      }

      final cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanMobile.length != 10) {
        return "Mobile number must be exactly 10 digits";
      }

      if (!RegExp(r'^[0-9]{10}$').hasMatch(cleanMobile)) {
        return "Please enter a valid 10-digit mobile number";
      }

      if (cleanMobile.startsWith('0')) {
        return "Mobile number cannot start with 0";
      }
    }
    return null;
  }

  // Email validation
  String? validateEmail(String email) {
    if (showEmailField) {
      if (email.isEmpty) {
        return "Email is required";
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return "Please enter a valid email address";
      }
    }
    return null;
  }

  // Password validation (if needed)
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return "Password is required";
    }
    if (password.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  // Clear specific error when field changes
  void onNameChanged(String value) {
    if (_nameError != null) {
      setState(() {
        _nameError = null;
      });
    }
  }

  void onMobileChanged(String value) {
    if (_mobileError != null) {
      setState(() {
        _mobileError = null;
      });
    }
  }

  void onEmailChanged(String value) {
    if (_emailError != null) {
      setState(() {
        _emailError = null;
      });
    }
  }

  // Validate all fields before submission
  bool validateAllFields() {
    bool isValid = true;

    setState(() {
      _nameError = validateName(nameController.text.trim());
      _mobileError = validateMobile(mobileController.text.trim());
      _emailError = validateEmail(emailController.text.trim());

      if (_nameError != null) isValid = false;
      if (_mobileError != null && showMobileField) isValid = false;
      if (_emailError != null && showEmailField) isValid = false;
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// Background
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

                          /// Logo
                          Image.asset(
                            "assets/images/img5.png",
                            width: 200,
                            height: 80,
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            "Register now",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "Please Enter Your details to Continue",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 25),

                          /// Name Field (Always visible)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                onChanged: onNameChanged,
                                decoration: inputDecoration(
                                  Icons.person,
                                  "Full Name",
                                  errorText: _nameError,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          /// Mobile Field (Conditional visibility)
                          if (showMobileField)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: mobileController,
                                  keyboardType: TextInputType.phone,
                                  onChanged: onMobileChanged,
                                  decoration: inputDecoration(
                                    Icons.phone,
                                    "Mobile Number",
                                    errorText: _mobileError,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 12,
                                  ),
                                  child: Text(
                                    "Enter 10-digit mobile number",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (showMobileField) const SizedBox(height: 15),

                          /// Email Field (Conditional visibility)
                          if (showEmailField)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: onEmailChanged,
                                  decoration: inputDecoration(
                                    Icons.email,
                                    "Email Address",
                                    errorText: _emailError,
                                  ),
                                ),
                              ],
                            ),

                          if (showEmailField) const SizedBox(height: 15),

                          /// Terms Checkbox
                          CheckboxListTile(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.grey),
                                children: [
                                  const TextSpan(text: "I agree to the "),
                                  TextSpan(
                                    text: "Terms of use",
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const TermsAndConditionsScreen(),
                                          ),
                                        );
                                      },
                                  ),
                                  const TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const TermsAndConditionsScreen(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// Register Button with Provider
                          Consumer<AuthProvider>(
                            builder: (context, provider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          // Validate all fields
                                          if (!isChecked) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please accept terms and conditions",
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          if (!validateAllFields()) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please fix all errors before proceeding",
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          try {
                                            await provider.registerUser(
                                              mobile: showMobileField
                                                  ? mobileController.text.trim()
                                                  : "",
                                              fullName: nameController.text
                                                  .trim(),
                                              email: showEmailField
                                                  ? emailController.text.trim()
                                                  : "",
                                              // password: "password123",
                                              role: "user",
                                            );

                                            if (showEmailField &&
                                                emailController.text
                                                    .trim()
                                                    .isNotEmpty) {
                                              await provider.sendOtp(
                                                emailController.text.trim(),
                                                isEmail: true,
                                              );
                                            } else if (showMobileField &&
                                                mobileController.text
                                                    .trim()
                                                    .isNotEmpty) {
                                              await provider.sendOtp(
                                                mobileController.text.trim(),
                                                isEmail: false,
                                              );
                                            }

                                            if (!mounted) return;

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OtpScreen(
                                                  mobile: showMobileField
                                                      ? mobileController.text
                                                            .trim()
                                                      : "",
                                                  email: showEmailField
                                                      ? emailController.text
                                                            .trim()
                                                      : "",
                                                  flow: OtpFlow.signup,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            String error = e
                                                .toString()
                                                .toLowerCase();
                                            print("ERROR: $error");

                                            /// If user already exists
                                            if (error.contains(
                                              "already exists",
                                            )) {
                                              try {
                                                if (showEmailField &&
                                                    emailController.text
                                                        .trim()
                                                        .isNotEmpty) {
                                                  await provider.sendOtp(
                                                    emailController.text.trim(),
                                                  );
                                                } else if (showMobileField &&
                                                    mobileController.text
                                                        .trim()
                                                        .isNotEmpty) {
                                                  await provider.sendOtp(
                                                    mobileController.text
                                                        .trim(),
                                                  );
                                                }

                                                if (!mounted) return;

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OtpScreen(
                                                          mobile:
                                                              showMobileField
                                                              ? mobileController
                                                                    .text
                                                                    .trim()
                                                              : "",
                                                          email: showEmailField
                                                              ? emailController
                                                                    .text
                                                                    .trim()
                                                              : "",
                                                          flow: OtpFlow.signup,
                                                        ),
                                                  ),
                                                );
                                              } catch (otpError) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      otpError
                                                          .toString()
                                                          .replaceAll(
                                                            "Exception: ",
                                                            "",
                                                          ),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                              return;
                                            }

                                            /// Other errors
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
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
                                    child: Center(
                                      child: provider.isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              "Get OTP",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          /// Bottom text - Navigate to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already Have An Account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign In",
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
    );
  }

  /// Reusable Input Decoration with error support
  InputDecoration inputDecoration(
    IconData icon,
    String hint, {
    String? errorText,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: errorText != null ? Colors.red : null),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorText != null ? Colors.red : const Color(0xFFE1094A),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorText: errorText,
      errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
    );
  }
}
