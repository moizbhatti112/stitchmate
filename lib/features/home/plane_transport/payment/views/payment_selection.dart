import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/ground_transport/payment/views/payment_success.dart';
import 'package:stitchmate/features/home/plane_transport/services/plane_order_service.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/location_service.dart';
import 'package:stitchmate/features/home/plane_transport/payment/services/stripe_service.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final int price;
  const PaymentSelectionScreen({super.key, required this.price});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String? selectedPaymentMethod;
  late LocationService locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Payment Method'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Choose Payment Method',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Cash Option
              PaymentOptionCard(
                title: 'Cash',
                icon: Icons.money,
                isSelected: selectedPaymentMethod == 'cash',
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 'cash';
                  });
                },
              ),
              const SizedBox(height: 20),
              // Card Option
              PaymentOptionCard(
                title: 'Card',
                icon: Icons.credit_card,
                isSelected: selectedPaymentMethod == 'card',
                onTap: () {
                  setState(() {
                    selectedPaymentMethod = 'card';
                  });
                },
              ),
              const Spacer(),
              // Price Display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Total Price: ${widget.price} Rs',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Proceed Button
              ElevatedButton(
                onPressed:
                    selectedPaymentMethod != null
                        ? () async {
                          if (selectedPaymentMethod == 'card') {
                            try {
                              await StripeService.instance.makePayment(
                                amount: widget.price,
                                onPaymentSuccess: () async {
                                  // Navigate to success screen after payment
                                  // Get booking details from provider
                                  final bookingProvider =
                                      Provider.of<PlaneBookingProvider>(
                                        context,
                                        listen: false,
                                      );

                                  // Save order to Supabase
                                  await PlaneOrderService().addPlaneOrder(
                                    pickup: bookingProvider.pickupLocation,
                                    dropoff: bookingProvider.dropoffLocation,
                                    date: bookingProvider.date,
                                    time: bookingProvider.time,
                                  );

                                  // Clear booking data
                                  bookingProvider.clearBookingData();

                                  // Navigate to success screen after payment
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const PaymentSuccessScreen(),
                                      ),
                                    );
                                  }
                                },
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Payment failed: ${e.toString()}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else if (selectedPaymentMethod == 'cash') {
                             final bookingProvider =
                                      Provider.of<PlaneBookingProvider>(
                                        context,
                                        listen: false,
                                      );

                                  // Save order to Supabase
                                  await PlaneOrderService().addPlaneOrder(
                                    pickup: bookingProvider.pickupLocation,
                                    dropoff: bookingProvider.dropoffLocation,
                                    date: bookingProvider.date,
                                    time: bookingProvider.time,
                                  );

                                  // Clear booking data
                                  bookingProvider.clearBookingData();
                            // For cash payment, directly navigate to success screen
                           if(context.mounted)
                           {
                             Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder:
                                    (context) => const PaymentSuccessScreen(),
                              ),
                            );
                           }
                          }
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: primaryColor,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? white : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
