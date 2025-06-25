import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/services/notification_service.dart';
import 'package:stitchmate/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Send notification when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOrderNotification();
    });
  }

  Future<void> _sendOrderNotification() async {
    try {
      // Get current user's email
      final user = Supabase.instance.client.auth.currentUser;
      final userEmail = user?.email ?? 'Unknown User';

      // Fetch the latest order from order_history
      final userId = user?.id;
      if (userId == null) {
        debugPrint('No user ID found');
        return;
      }

      final response =
          await Supabase.instance.client
              .from('order_history')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false)
              .limit(1)
              .single();

      // Debug print to check the values
      debugPrint('Pickup: ${response['pickup']}');
      debugPrint('Dropoff: ${response['dropoff']}');
      debugPrint('Time: ${response['time']}');
      debugPrint('Date: ${response['date']}');
      debugPrint('User Email: $userEmail');

      await NotificationService().sendOrderNotification(
        pickupLocation: response['pickup'] ?? 'N/A',
        dropoffLocation: response['dropoff'] ?? 'N/A',
        time: response['time'] ?? 'N/A',
        date: response['date'] ?? 'N/A',
        userEmail: userEmail,
      );
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (bool didPop, dynamic result) => _handlePop(context, didPop),
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Order Placed',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your order has been placed successfully.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      // Clear booking data before navigating
                      Provider.of<BookingProvider>(
                        context,
                        listen: false,
                      ).clearBookingData();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: primaryColor,
                    ),
                    child: const Center(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handlePop(BuildContext context, bool didPop) async {
    if (!didPop) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    return false;
  }
}
