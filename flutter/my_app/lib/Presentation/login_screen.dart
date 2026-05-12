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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ExitDialog.show(context),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ important
        body: Stack(
        children: [
          /// 🔹 Background Image (light marble)
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

                          /// 🔶 Logo Card with Image
                          Image.asset(
                            "assets/images/img5.png", // replace with your logo path
                            width: 200, // adjust as needed
                            height: 80, // adjust as needed
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 50),

                        /// 🔹 Title
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

                          /// 🔘 Toggle Buttons
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
                                    onTap: () {
                                      setState(() {
                                        isEmailSelected = true;
                                      });
                                    },
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
                                    onTap: () {
                                      setState(() {
                                        isEmailSelected = false;
                                      });
                                    },
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
                                              color: isEmailSelected
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

                          /// 📩 Input Field
                          TextField(
                            controller: inputController, // ✅ ADD THIS
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                isEmailSelected ? Icons.email : Icons.phone,
                              ),
                              hintText: isEmailSelected
                                  ? "Email"
                                  : "Mobile Number",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// 🔥 Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () async {
                                final input = inputController.text.trim();

                                if (input.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter email or mobile",
                                      ),
                                    ),
                                  );
                                  return;
                                }

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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// 🔻 Bottom Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't Have An Account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterScreen(),
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
