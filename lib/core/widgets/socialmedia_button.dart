import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

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

    double buttonHeight =
        orientation == Orientation.portrait
            ? size.height * 0.067
            : size.height * 0.16;

    double iconSize =
        orientation == Orientation.portrait
            ? size.width * 0.08
            : size.width * 0.05; // ✅ Smaller icon in landscape

    return SizedBox(
      width: double.infinity,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(widget.path, width: iconSize, height: iconSize),
            Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'ppneuemontreal-thin',
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
