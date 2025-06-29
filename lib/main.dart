import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stitchmate/core/constants/stripe_keys.dart';
import 'package:stitchmate/core/helperfunctions/network_provider.dart';
import 'package:stitchmate/features/ai_planner/viewmodels/chat_viewmodel.dart';
import 'package:stitchmate/features/ai_planner/views/chat_screen.dart';
import 'package:stitchmate/features/ai_planner/views/travel_preference.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';

import 'package:stitchmate/features/authentication/views/add_phone.dart';
import 'package:stitchmate/features/authentication/views/email_address.dart';
import 'package:stitchmate/features/authentication/views/forgot_password_email_screen.dart';
import 'package:stitchmate/features/authentication/views/loginscreen.dart';
import 'package:stitchmate/features/authentication/views/reset_password_screen.dart';
import 'package:stitchmate/features/authentication/views/signup_screen.dart';
import 'package:stitchmate/features/authentication/views/verify_code_screen.dart';
import 'package:stitchmate/features/authentication/views/welcome.dart';
import 'package:stitchmate/features/home/concierge_services/views/concierge_services.dart';
import 'package:stitchmate/features/home/expense_tracker/views/expense_tracker.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/route_provider.dart';
import 'package:stitchmate/features/home/ground_transport/views/booking_confirmation.dart';
import 'package:stitchmate/features/home/ground_transport/views/choose_vehicle.dart';
import 'package:stitchmate/features/home/ground_transport/views/luxury_ground_transportation.dart';
import 'package:stitchmate/features/home/ground_transport/views/welcome_screen.dart';
import 'package:stitchmate/features/home/home_presentation/home_screen.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/chooseplane_provider.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/route_provider.dart';
import 'package:stitchmate/features/home/plane_transport/views/booking_confirmation.dart';
import 'package:stitchmate/features/home/plane_transport/views/choose_plane.dart';
// import 'package:stitchmate/features/home/jet_service/views/jet_booking.dart';
import 'package:stitchmate/features/home/plane_transport/views/jet_welcome.dart';
import 'package:stitchmate/features/home/plane_transport/views/luxury_plane_transportation.dart';
// import 'package:stitchmate/features/payment/views/payment_selection.dart';
import 'package:stitchmate/features/home/secure_travel/secure_travel.dart';
import 'package:stitchmate/features/profile/views/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/features/settings/views/help_support_screen.dart';
import 'package:stitchmate/features/settings/views/settings_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stitchmate/features/home/quick_tips/quick_tips_screen.dart';

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

  // Initialize Stripe
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();

  // Initialize Supabase
  await Supabase.initialize(
    anonKey:
        '',
    url: '',
  );

  // Initialize essential resources before app startup
  await _initializeResources();

  // Defer non-critical initialization work to after the first frame
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChooseVehicleProvider()),
        ChangeNotifierProvider(create: (_) => ChoosePlaneProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => PlaneBookingProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => PlaneRouteProvider()),
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
        '/forgot-password': (context) => const ForgotPasswordEmailScreen(),
        '/verify-code': (context) => const VerifyCodeScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/luxurywelcome': (context) => const WelcomeScreen(),
        '/choosevehicle': (context) => const ChooseVehicle(),
        //  '/choosevehicle': (context) => const CarSelectionScreen(),
        '/bookingconfirmation': (context) => const BookingConfirmation(),
        '/chatscreen': (context) => const ChatScreen(),
        '/jetwelcome': (context) => const JetWelcome(),
        '/jetbooking': (context) => const LuxuryPlaneTransportation(),
        '/chooseplane': (context) => const ChoosePlane(),
        '/event': (context) => const TripExpenseScreen(),
        '/concierge': (context) => const ConciergeServices(),
        '/securetravel': (context) => const SecureTravel(),
        '/planebc': (context) => const PlaneBookingConfirmation(),
        '/travelp': (context) => const TravelPreferencesScreen(),
        '/quick-tips': (context) => const QuickTipsScreen(),
        '/settings': (context) => const SettingsScreen(),
         '/support': (context) => const HelpSupportScreen(),
          // '/payment-methods': (context) => const HelpSupportScreen(),
        // '/paymentmethod': (context) => const PaymentSelectionScreen(),
      },
    );
  }
}
