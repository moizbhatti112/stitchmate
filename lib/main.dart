import 'package:flutter/material.dart';

import 'package:gyde/features/authentication/views/add_phone.dart';
import 'package:gyde/features/authentication/views/email_address.dart';
import 'package:gyde/features/authentication/views/signup_screen.dart';
import 'package:gyde/features/authentication/views/welcome.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/map_provider.dart';
import 'package:gyde/features/home/ground_transport/views/booking_confirmation.dart';
import 'package:gyde/features/home/ground_transport/views/choose_vehicle.dart';
import 'package:gyde/features/home/ground_transport/views/luxury_ground_transportation.dart';
import 'package:gyde/features/home/ground_transport/views/welcome_screen.dart';
import 'package:gyde/features/home/home_presentation/home_screen.dart';
import 'package:gyde/features/profile/views/profile_screen.dart';
import 'package:provider/provider.dart';

void main() {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> ChooseVehicleProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
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

      title: 'Flutter Demo',
      theme: ThemeData(fontFamily: 'HelveticaNeueMedium'),
      // home: const LuxuryGroundTransportation(),
       home: const WelcomeScreen(),
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
        '/bookingconfirmation':(context)=>const BookingConfirmation()
      },
    );
  }
}
