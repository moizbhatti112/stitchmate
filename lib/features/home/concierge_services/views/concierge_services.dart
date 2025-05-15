import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class ConciergeServices extends StatefulWidget {
  const ConciergeServices({super.key});

  @override
  State<ConciergeServices> createState() => _ConciergeServicesState();
}

class _ConciergeServicesState extends State<ConciergeServices> {
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
