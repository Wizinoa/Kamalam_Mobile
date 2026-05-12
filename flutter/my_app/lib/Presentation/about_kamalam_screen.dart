import 'package:flutter/material.dart';
import 'package:my_app/Presentation/home_screen.dart';
import 'package:my_app/Presentation/kyc_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool isExpanded = false;
  List<bool> expandedList = [false, false, false];
  bool isShowroomExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 246, 246),
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
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "About Sri Kamalam",
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          width: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2A0912), Color(0xFFE1094A)],
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /// 🖼 IMAGE
                              Image.asset(
                                "assets/images/img20.png", // <-- your image path
                                width: 180,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Legacy of Excellence",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// 🔴 Read More
                        Text(
                          "Sri Kamalam Jewellers stands as a beacon of trust and craftsmanship in the Indian jewellery industry, creating timeless pieces that celebrate life's precious moments.",
                          textAlign: TextAlign.center,
                          maxLines: isExpanded ? null : 2, // 🔥 collapse/expand
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 8),

                            /// 🔴 Read More / Read Less
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? "Read Less" : "Read More",
                                style: const TextStyle(
                                  color: Color(0xFF7A0C0C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// ➖ Divider
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.grey.shade300, // softer line
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(
                              "https://srikamalamjewellers.com",
                            );

                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode
                                    .externalApplication, // opens browser
                              );
                            } else {
                              debugPrint("Could not launch $url");
                            }
                          },
                          child: Row(
                            children: [
                              /// 🌐 Gradient Icon Circle
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF7A0C0C),
                                      Color(0xFFE52D27),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.language,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// 📄 Text Section
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Visit Official Website",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "https://srikamalamjewellers.com",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ➡ Arrow
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Color(0xFF7A0C0C),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // OUR OFFERINGS
                  const Text(
                    "Our Offerings",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10), // title → grid gap
                  GridView.count(
                    padding: const EdgeInsets.only(top: 4), // 🔥 fine tune
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      /// ITEM 1
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFD4A93A),
                                child: Icon(Icons.star, color: Colors.white),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Gold Jewellery",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Pure 22K collections",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ITEM 2
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFD4A93A),
                                child: Icon(
                                  Icons.star_border,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Silver Ornaments",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "925 sterling silver",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ITEM 3
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFD4A93A),
                                child: Icon(Icons.diamond, color: Colors.white),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Diamonds",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Certified brilliance",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ITEM 4
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFD4A93A),
                                child: Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Platinum",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Premium collections",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // title → grid gap
                  // WHY CHOOSE US
                  const Text(
                    "Why Choose Us",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        /// ITEM 1
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedList[0] = !expandedList[0];
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Color(0xFFD4A93A),
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  /// TEXT
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Manufacturing Excellence",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          "State-of-the-art facilities",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  /// 🔽 DROPDOWN ICON
                                  AnimatedRotation(
                                    turns: expandedList[0] ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                  ),
                                ],
                              ),

                              if (expandedList[0]) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  "Our manufacturing unit is located in Madurai with advanced technology and skilled artisans.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ITEM 2
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedList[1] = !expandedList[1];
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Color(0xFFD4A93A),
                                    child: Icon(
                                      Icons.savings,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Savings Schemes",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          "Flexible payment plans",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  AnimatedRotation(
                                    turns: expandedList[1] ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                  ),
                                ],
                              ),

                              if (expandedList[1]) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  "We offer gold savings schemes with easy monthly installments and bonus benefits.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ITEM 3
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              expandedList[2] = !expandedList[2];
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Color(0xFFD4A93A),
                                    child: Icon(
                                      Icons.shopping_cart,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "E-Commerce Platform",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          "Shop online seamlessly",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  AnimatedRotation(
                                    turns: expandedList[2] ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                  ),
                                ],
                              ),

                              if (expandedList[2]) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  "Our online platform allows customers to browse and purchase jewellery securely from anywhere.",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OUR PRESENCE TITLE
                  const Text(
                    "Our Presence",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // FLAGSHIP SHOWROOM CARD
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isShowroomExpanded = !isShowroomExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 TOP ROW
                          Row(
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFD4A93A),
                                      Color(0xFFB8902E),
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// TEXT
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Flagship Showroom",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Premium shopping experience",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// 🔽 DROPDOWN ICON
                              AnimatedRotation(
                                turns: isShowroomExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),

                          /// 🔽 EXPANDED CONTENT
                          if (isShowroomExpanded) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),

                            const Text(
                              "Sri Kamalam Jewellers\n"
                              "158, Nethaji Rd, near Modern Restaurant, Valaiyal Kadai,"
                              "Madurai Main, Madurai, Tamil Nadu - 625001\n"
                              "Phone:  0452 235 0270",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // DIGIGOLD CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFD4A93A), Color(0xFFB8902E)],
                            ),
                          ),
                          child: const Icon(
                            Icons.phone_iphone,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "DigiGold",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Start your gold investment journey with as little as ₹100 Buy, sell, and accumulate digital gold with complete transparency and security.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 14),

                        // BUTTON
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4A93A), Color(0xFFB8902E)],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Start Saving in Gold",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                         const SizedBox(height: 14),
                      ],
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
