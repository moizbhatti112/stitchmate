import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stitchmate/core/helperfunctions/network_provider.dart';
import 'package:stitchmate/features/ai_planner/viewmodels/chat_viewmodel.dart';
import 'package:stitchmate/features/ai_planner/views/chat_screen.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';

import 'package:stitchmate/features/authentication/views/add_phone.dart';
import 'package:stitchmate/features/authentication/views/email_address.dart';
import 'package:stitchmate/features/authentication/views/loginscreen.dart';
import 'package:stitchmate/features/authentication/views/signup_screen.dart';
import 'package:stitchmate/features/authentication/views/welcome.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/route_provider.dart';
import 'package:stitchmate/features/home/ground_transport/views/booking_confirmation.dart';
import 'package:stitchmate/features/home/ground_transport/views/choose_vehicle.dart';
import 'package:stitchmate/features/home/ground_transport/views/luxury_ground_transportation.dart';
import 'package:stitchmate/features/home/ground_transport/views/welcome_screen.dart';
import 'package:stitchmate/features/home/home_presentation/home_screen.dart';
import 'package:stitchmate/features/profile/views/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Initialize common resources before app starts
Future<void> _initializeResources() async {
  // Set preferred orientations to reduce layout rebuilds
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style once to avoid later main thread work
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhlZ3V4enpnYXNvbHpwanZjbW15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMDY2NjgsImV4cCI6MjA1OTY4MjY2OH0.dTV6HB5S8A10DaDbR0Q2Ip7mOBwFziDwr_I6xl_eeEc',
    url: 'https://heguxzzgasolzpjvcmmy.supabase.co',
  );
  
  // Initialize essential resources before app startup
  await _initializeResources();

  // Defer non-critical initialization work to after the first frame
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChooseVehicleProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
         ChangeNotifierProvider(create: (_) => ChatViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

// Simple auth check wrapper
class AuthStateCheck extends StatelessWidget {
  const AuthStateCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    


    
    // Simple check: if authenticated go to home, otherwise login
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Stitchmate',
      theme: ThemeData(
        fontFamily: 'HelveticaNeueMedium',
        // Optimize theme settings
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) {
        return NetworkAwareOverlay(child: child!);
      },
      // Use AuthStateCheck as the home widget
      home: const AuthStateCheck(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/addphone': (context) => const AddPhone(),
        '/welcome': (context) => const Welcome(),
        '/enteremail': (context) => const EnterEmail(),
        '/profilescreen': (context) => const ProfileScreen(),
        '/homescreen': (context) => const HomeScreen(),
        '/luxurytransport': (context) => const LuxuryGroundTransportation(),
        '/login': (context) => const LoginScreen(), 
        '/luxurywelcome': (context) => const WelcomeScreen(),
        '/choosevehicle': (context) => const ChooseVehicle(),
        '/bookingconfirmation': (context) => const BookingConfirmation(),
        '/chatscreen': (context) => const ChatScreen(),
      },
    );
  }
}