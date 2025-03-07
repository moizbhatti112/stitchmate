import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';

class AiWelcome extends StatelessWidget {
  final String name;
  const AiWelcome({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.27),
            Center(child: Image.asset('assets/images/circlestar.png')),
            SizedBox(height: size.height * 0.02),
            Text(
              'Hi, $name!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'PPNeueMontreal',
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Welcome to Gyde. Please select your \n          personalized experience.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'HelveticaNeueMedium',
                color: grey,
              ),
            ),
            SizedBox(height: size.height * 0.3),
            GestureDetector(
              onTap: () =>    Navigator.pushNamed(context, '/homescreen'),
              child: Container(
                height: size.height * 0.07,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(
                  // vertical: size.height * 0.05,
                  horizontal: size.width * 0.03,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/star.png'),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      'AI Experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: secondaryColor,
                        fontFamily: 'HelveticaNeueMedium',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01), //  2nd button ////
            GestureDetector(
              onTap: () {
             
                debugPrint('AI Experience');
              },
              child: Container(
                width: double.infinity,
                height: size.height * 0.07,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                child: Center(
                  child: Text(
                    'Analog Experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      fontFamily: 'HelveticaNeueMedium',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
