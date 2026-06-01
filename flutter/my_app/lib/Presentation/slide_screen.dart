import 'package:flutter/material.dart';
import 'package:my_app/Presentation/login_screen.dart';
import 'package:my_app/Presentation/register_screen.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  // 🔥 Use multiple images
  final List<String> images = [
    'assets/images/img1.png',
    'assets/images/img2.png',
    'assets/images/img3.png',
  ];

  final List<String> titles = [
    "Welcome to Smart\nGold Investment",
    "You’re All Set to Own Gold Digitally",
    "Ready to Own Gold",
  ];

  final List<String> subtitles = [
    "A smarter way to save in gold.\nFully secure, insured, and easy to use.",
    "More than gold — a smart, secure way to save for your future.",
    "Experience gold investing that’s simple, secure, and designed for modern wealth builders.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // 🔥 FULL IMAGE BACKGROUND
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  images[index],
                  fit: BoxFit.cover, // 🔥 change to contain if needed
                ),
              ),

              // 🔥 GRADIENT OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),

              // 🔥 CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 🔴 DOTS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (dotIndex) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentIndex == dotIndex ? 10 : 6,
                            height: currentIndex == dotIndex ? 10 : 6,
                            decoration: BoxDecoration(
                              color: currentIndex == dotIndex
                                  ? const Color.fromARGB(255, 95, 10, 4)
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 25),

                      // 📝 TITLE
                      Text(
                        titles[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 📝 SUBTITLE
                      Text(
                        subtitles[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔴 BUTTON
                      (currentIndex == images.length - 1)
                          // 👉 LAST PAGE (Page 3)
                          ? Row(
                              children: [
                                // 🔴 SIGN UP
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegisterScreen(
                                            defaultLoginType:
                                                'email', // Always set to email
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),

                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2A0912),
                                            Color(0xFFE1094A),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // ⚪ LOGIN
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: const LinearGradient(
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
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          // 👉 SECOND LAST PAGE (Page 2)
                          : (currentIndex == images.length - 2)
                          ? GestureDetector(
                              onTap: () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2A0912),
                                      Color(0xFFE1094A),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Get Started",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          // 👉 FIRST PAGE (Page 1)
                          : GestureDetector(
                              onTap: () {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2A0912),
                                      Color(0xFFE1094A),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
