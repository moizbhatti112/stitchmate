import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class EventTransportation extends StatefulWidget {
  const EventTransportation({super.key});

  @override
  State<EventTransportation> createState() => _EventTransportationState();
}

class _EventTransportationState extends State<EventTransportation> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Text(
          'Feature Under Development!',
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
