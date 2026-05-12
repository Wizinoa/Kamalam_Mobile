import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/Presentation/slide_screen.dart';
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
import 'package:my_app/Providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const CarouselScreen(),
    );
  }
}
