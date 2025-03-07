import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gyde/core/constants/colors.dart';

class ChooseVehicle extends StatefulWidget {
  const ChooseVehicle({super.key});

  @override
  State<ChooseVehicle> createState() => _ChooseVehicleState();
}

class _ChooseVehicleState extends State<ChooseVehicle> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Preload images
    precacheImage(AssetImage('assets/images/mercedes.png'), context);
    _preloadSVGs();
  }

  // Function to preload SVGs
  void _preloadSVGs() {
    Future.wait([
      DefaultAssetBundle.of(context).load('assets/icons/leaf.svg'),
      DefaultAssetBundle.of(context).load('assets/icons/bag.svg'),
      DefaultAssetBundle.of(context).load('assets/icons/car_icon.svg'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Choose a vehicle class',
          style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: size.height * 0.1),
          Text(
            'Business Class',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'PPNeueMontreal',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Mercedes-Benz E-Class or similar',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'PPNeueMontreal',
              fontWeight: FontWeight.w500,
              color: grey,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/leaf.svg'),
                SizedBox(width: size.width * 0.03),
                Text(
                  '3 Seats',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PPNeueMontreal',
                    fontWeight: FontWeight.w500,
                    color: grey,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                SvgPicture.asset('assets/icons/bag.svg'),
                SizedBox(width: size.width * 0.03),
                Text(
                  '2 Bags',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'PPNeueMontreal',
                    fontWeight: FontWeight.w500,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/mercedes.png',
            width: size.width * 01,
            height: size.height * 0.3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/car_icon.svg'),
                SizedBox(width: size.width * 0.02),
                Text(
                  'CAR DETAILS',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: 'PPNeueMontreal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: nextbg),
          ),
        ],
      ),
    );
  }
}
