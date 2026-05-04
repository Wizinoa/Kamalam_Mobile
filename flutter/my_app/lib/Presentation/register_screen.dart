import 'package:flutter/material.dart';
import 'package:my_app/Providers/auth_provider.dart';
import 'package:my_app/Utils/enum.dart';
import 'package:provider/provider.dart';
import 'package:my_app/Presentation/login_screen.dart';
import 'package:my_app/Presentation/otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isChecked = false;

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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 80),

                          /// 🔶 Logo
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

                          /// 🔹 Name
                          TextField(
                            controller: nameController,
                            decoration: inputDecoration(Icons.person, "Name"),
                          ),

                          const SizedBox(height: 15),

                          /// 🔹 Mobile
                          TextField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: inputDecoration(
                              Icons.phone,
                              "Mobile Number",
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// 🔹 Email
                          TextField(
                            controller: emailController,
                            decoration: inputDecoration(Icons.email, "Email"),
                          ),

                          const SizedBox(height: 15),

                          /// 🔹 Password
                          // TextField(
                          //   controller: passwordController,
                          //   obscureText: true,
                          //   decoration: inputDecoration(Icons.lock, "Password"),
                          // ),
                          const SizedBox(height: 15),

                          /// ✅ Terms Checkbox
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
                              text: const TextSpan(
                                style: TextStyle(color: Colors.grey),
                                children: [
                                  TextSpan(text: "I agree to the "),
                                  TextSpan(
                                    text: "Terms of use",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(text: " and "),
                                  TextSpan(
                                    text: "Privacy Policy",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            fillColor: MaterialStateProperty.all(Colors.grey),
                            checkColor: Colors.black,
                          ),

                          const SizedBox(height: 15),

                          /// 🔥 Button with Provider
                          Consumer<AuthProvider>(
                            builder: (context, provider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          if (!isChecked) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Please accept terms",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          try {
                                            await provider.registerUser(
                                              mobile: mobileController.text,
                                              fullName: nameController.text,
                                              email: emailController.text,
                                              password: "password123",
                                              role: "user",
                                            );

                                            /// ✅ NEW USER FLOW
                                            await provider.sendOtp(
                                              emailController.text,
                                            );

                                            if (!mounted) return;

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OtpScreen(
                                                  mobile: mobileController.text,
                                                  email: emailController.text,
                                                  flow: OtpFlow
                                                      .signup, // 👈 THIS LINE
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            String error = e
                                                .toString()
                                                .toLowerCase();

                                            print("ERROR: $error");

                                            /// 🔥 IMPORTANT FIX
                                            if (error.contains(
                                              "already exists",
                                            )) {
                                              try {
                                                /// 👉 RESEND OTP FOR EXISTING USER
                                                await provider.sendOtp(
                                                  emailController.text,
                                                );

                                                if (!mounted) return;

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => OtpScreen(
                                                      mobile:
                                                          mobileController.text,
                                                      email:
                                                          emailController.text,
                                                      flow: OtpFlow
                                                          .signup, // 👈 THIS LINE
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
                                                  ),
                                                );
                                              }

                                              return; // ✅ VERY IMPORTANT
                                            }

                                            /// ❌ OTHER ERRORS
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

                          /// 🔻 Bottom text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already Have An Account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
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

  /// 🔹 Reusable Input Decoration
  InputDecoration inputDecoration(IconData icon, String hint) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
