import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    double responsiveFont(double fontSize) {
      return size.width * (fontSize / 390); // Adjusting according to iPhone 14 width
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/limo.png',height: size.height*0.3,width: double.infinity,fit: BoxFit.cover,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height*0.04,),
                  Text(
                    'Luxury Ground Transportation',
                    style: TextStyle(
                      fontSize: responsiveFont(20),
                      fontFamily: 'PP Neue Montreal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  ...List.generate(3, (index) => _buildFeatureItem(size, responsiveFont)),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
            Divider(color: grey),
            SizedBox(height: size.height * 0.01),
            MyButton(
              text: 'Continue',
              onPressed: () {
                Navigator.pushNamed(context, '/luxurytransport');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(Size size, double Function(double) responsiveFont) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset('assets/icons/tick.svg'),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ride in style with our premium chauffeur',
                  style: TextStyle(
                    fontSize: responsiveFont(16),
                    fontFamily: 'PP Neue Montreal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'service',
                  style: TextStyle(
                    fontSize: responsiveFont(16),
                    fontFamily: 'PP Neue Montreal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Our professional chauffeurs provide world-class service, ensuring you travel in comfort and elegance.',
                  style: TextStyle(
                    fontSize: responsiveFont(14),
                    fontFamily: 'PP Neue Montreal',
                    fontWeight: FontWeight.w500,
                    color: grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
