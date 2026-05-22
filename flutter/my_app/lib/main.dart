import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Presentation/slide_screen.dart';
import 'package:my_app/Presentation/mpin_screen.dart';
import 'package:my_app/Providers/faq_provider.dart';
import 'package:my_app/Providers/instant_transactions_provider.dart';
import 'package:my_app/Providers/savings_history_provider.dart';
import 'package:my_app/Providers/terms_provider.dart';
import 'package:my_app/Utils/local_storage.dart';
import 'package:my_app/Providers/auth_provider.dart';
import 'package:my_app/Providers/banner_provider.dart';
import 'package:my_app/Providers/gold_Provider.dart';
import 'package:my_app/Providers/notification_provider.dart';
import 'package:my_app/Providers/passbook_providers.dart';
import 'package:my_app/Providers/payment_provider.dart';
import 'package:my_app/Providers/receipt_provider.dart';
import 'package:my_app/Providers/reward_provider.dart';
import 'package:my_app/Providers/savings_details_provider.dart';
import 'package:my_app/Providers/scheme_provider.dart';
import 'package:my_app/Providers/set_target_provider.dart';
import 'package:my_app/Providers/user_provider.dart';
import 'package:provider/provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoldPriceProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => SchemeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
        ChangeNotifierProvider(create: (_) => PassbookProviders()),
        ChangeNotifierProvider(create: (_) => ReceiptsProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => SetTargetProvider()),
        ChangeNotifierProvider(create: (_) => SavingsHistoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => TermsProvider()),
        ChangeNotifierProvider(create: (_) => FaqProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: LocalStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: LocalStorage.getEmail(),
            builder: (context, emailSnapshot) {
              if (emailSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return MpinScreen(
                mobile: "",
                email: emailSnapshot.data ?? "",
              );
            },
          );
        } else {
          return const CarouselScreen();
        }
      },
    );
  }
}