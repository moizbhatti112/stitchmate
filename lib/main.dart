import 'package:flutter/material.dart';
import 'package:gyde/core/helperfunctions/network_provider.dart';
import 'package:gyde/features/authentication/views/add_phone.dart';
import 'package:gyde/features/authentication/views/email_address.dart';
import 'package:gyde/features/authentication/views/signup_screen.dart';
import 'package:gyde/features/authentication/views/welcome.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/route_provider.dart';
import 'package:gyde/features/home/ground_transport/views/booking_confirmation.dart';
import 'package:gyde/features/home/ground_transport/views/choose_vehicle.dart';
import 'package:gyde/features/home/ground_transport/views/luxury_ground_transportation.dart';
import 'package:gyde/features/home/ground_transport/views/welcome_screen.dart';
import 'package:gyde/features/home/home_presentation/home_screen.dart';
import 'package:gyde/features/profile/views/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChooseVehicleProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
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
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Gyde',
      theme: ThemeData(fontFamily: 'HelveticaNeueMedium'),
      builder: (context, child) {
        // Use the NetworkAwareOverlay here - it will overlay a message
        // rather than replacing the entire screen
        return NetworkAwareOverlay(child: child!);
      },
      // home: const HomeScreen(),
      home: const SignupScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/addphone': (context) => const AddPhone(),
        '/welcome': (context) => const Welcome(),
        '/enteremail': (context) => const EnterEmail(),
        '/profilescreen': (context) => const ProfileScreen(),
        '/homescreen': (context) => const HomeScreen(),
        '/luxurytransport': (context) => const LuxuryGroundTransportation(),
        '/luxurywelcome': (context) => const WelcomeScreen(),
        '/choosevehicle': (context) => const ChooseVehicle(),
        '/bookingconfirmation': (context) => const BookingConfirmation()
      },
    );
  }
}