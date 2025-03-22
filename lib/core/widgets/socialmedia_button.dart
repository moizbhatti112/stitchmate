import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';

class SocialmediaButton extends StatefulWidget {
  final String path;
  final Function() onPressed;

  const SocialmediaButton({
    super.key,
    required this.path,
    required this.onPressed,
  });

  @override
  State<SocialmediaButton> createState() => _SocialmediaButtonState();
}

class _SocialmediaButtonState extends State<SocialmediaButton> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);

    // ✅ Button size adjust hoga according to orientation
    double buttonWidth = orientation == Orientation.portrait
        ? size.width * 0.3
        : size.width * 0.29;

    double buttonHeight = orientation == Orientation.portrait
        ? size.height * 0.067
        : size.height * 0.16;

    double iconSize = orientation == Orientation.portrait
        ? size.width * 0.08
        : size.width * 0.05; // ✅ Smaller icon in landscape

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: primaryColor, width: 1),
          ),
        ),
        child: Image.asset(
          widget.path,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
