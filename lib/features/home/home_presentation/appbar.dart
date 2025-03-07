import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyde/core/constants/colors.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    // Precache the PNG image
    precacheImage(const AssetImage('assets/icons/appbaravatar.png'), context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/icons/appbaravatar.png',
          height: 40,
          width: 40,
        ),
        Container(
          height: size.height * 0.06,
          width: size.width * 0.6,
          decoration: BoxDecoration(
            color: phonefieldColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 25),
                const SizedBox(width: 10),
                const Text(
                  'New York, USA',
                  style: TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: 'HelveticaNeueMedium',
                  ),
                ),
                const Spacer(),
                _loadSvg('assets/icons/down.svg', 20, 20),
              ],
            ),
          ),
        ),
        _loadSvg('assets/icons/notif.svg', 24, 24),
      ],
    );
  }

  // ✅ Optimized SVG Loader
  Widget _loadSvg(String asset, double width, double height) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      colorFilter: const ColorFilter.mode(black, BlendMode.srcIn),
    );
  }
}