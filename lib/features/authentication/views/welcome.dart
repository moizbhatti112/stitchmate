import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.25),
            Center(
              child: Image.asset(
                'assets/images/welcome.png',

                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'Welcome Aboard!',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'ppneuemontreal-medium',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              '      You’ve unlocked access to exclusive,\n personalized chauffeur services with Gyde.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'HelveticaNeueMedium',
                fontWeight: FontWeight.w600,
                color: lightblack,
              ),
            ),
            SizedBox(height: size.height * 0.35),
            MyButton(
              text: "Continue",
              onPressed: () {
                Navigator.pushNamed(context, '/enteremail');
              },
            ),
          ],
        ),
      ),
    );
  }
}
