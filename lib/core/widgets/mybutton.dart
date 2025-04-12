import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class MyButton extends StatefulWidget {
  final String text;
  final Function() onPressed;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);

    // ✅ Button height adjust according to orientation
    double buttonHeight = orientation == Orientation.portrait
        ? size.height * 0.065
        : size.height * 0.08;

    // ✅ Font size adjust according to orientation
    double fontSize = orientation == Orientation.portrait
        ? size.height * 0.02  // Smaller in portrait
        : size.height * 0.03;   // Bigger in landscape

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight,
        child:
         ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: bgColor,
              fontSize: fontSize, // 🔥 Adaptive Font Size
              // fontFamily: 'HelveticaNeueLight',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
