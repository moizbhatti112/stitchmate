import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class JetBooking extends StatefulWidget {
  const JetBooking({super.key});

  @override
  State<JetBooking> createState() => _JetBookingState();
}

class _JetBookingState extends State<JetBooking> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text("Feature Under Development!",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'PP Neue Montreal',
            fontWeight: FontWeight.w500,
            color: black,
          ),
        ),
      ),
    );
  }
}