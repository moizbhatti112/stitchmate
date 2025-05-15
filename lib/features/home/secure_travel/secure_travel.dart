import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class SecureTravel extends StatefulWidget {
  const SecureTravel({super.key});

  @override
  State<SecureTravel> createState() => _SecureTravelState();
}

class _SecureTravelState extends State<SecureTravel> {
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