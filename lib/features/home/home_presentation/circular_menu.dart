import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class CircularMenu extends StatelessWidget {
  final Widget child;
  final void Function() onpress;
  const CircularMenu({super.key,required this.child,required this.onpress});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: onpress,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: size.width * 0.15,
        height: size.height * 0.09,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: circlemenusborder, width: 2),
          color: circlemenusbg,
          boxShadow: [
            BoxShadow(
              color: circlemenusborder,
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 6), // changes position of shadow
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
