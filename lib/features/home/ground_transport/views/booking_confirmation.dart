import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';

class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation({super.key});

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {


 
  @override


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/map.png', fit: BoxFit.cover),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.4,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Confirmation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "PP Neue Montreal",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                   
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        height: size.height * 1,
                       
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

 
}