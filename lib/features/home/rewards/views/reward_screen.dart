import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back behavior
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context); // Manually navigate back
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
       
        body: const Center(child: Text("Rewards Screen")),
      ),
    );
  }
}
