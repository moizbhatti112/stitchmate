import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class AiWelcome extends StatelessWidget {
 
  const AiWelcome({super.key, });

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
              'Hi !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'PPNeueMontreal',
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'Please continue for AI experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'HelveticaNeueMedium',
                color: grey,
              ),
            ),
            SizedBox(height: size.height * 0.35),
            GestureDetector(
              onTap: () =>    Navigator.pushNamed(context, '/chatscreen'),
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
          
          ],
        ),
      ),
    );
  }
}
