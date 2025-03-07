import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';
import 'package:gyde/core/widgets/socialmedia_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: OrientationBuilder(
          builder: (context, orientation) {
            final size = MediaQuery.sizeOf(context);
            final isPortrait = orientation == Orientation.portrait;
            
         

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ Top Image (Car)
                  Image.asset(
                    'assets/images/carimage.png',
                    width: size.width,
                    height: isPortrait ? size.height * 0.4 : size.height * 0.45,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: size.height * (isPortrait ? 0.04 : 0.03)),

                  // ✅ Logo
                  Image.asset(
                    'assets/images/Gyde Logo.png',
                    width: isPortrait ? size.width * 0.3 : size.width * 0.2,
                  ),
                  SizedBox(height: size.height * (isPortrait ? 0.04 : 0.03)),

                  // ✅ Tagline (Responsive Font)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Experience comfort, Tailored to your needs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isPortrait?size.width*0.045:size.width*0.03, // Responsive Font
                    
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * (isPortrait ? 0.05 : 0.03)),

                  // ✅ Buttons
                  MyButton(
                    text: 'Continue With Phone',
                    onPressed: () {
                      Navigator.pushNamed(context, '/addphone');
                    },
                  ),
                  SizedBox(height:isPortrait? size.height * 0.01:size.height * 0.04),
                  
                  // ✅ Social Media Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SocialmediaButton(
                          path: 'assets/icons/apple.png',
                          onPressed: () {},
                        ),
                        SocialmediaButton(
                          path: 'assets/icons/google.png',
                          onPressed: () {},
                        ),
                        SocialmediaButton(
                          path: 'assets/icons/fb.png',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * (isPortrait ? 0.04 : 0.02)),

                  // ✅ Terms and Conditions (Responsive Font)
                  Column(
                    children: [
                      Text(
                        'By continuing, you have read and agree to our',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                        
                          fontSize: isPortrait?size.width*0.04:size.width*0.03, // Responsive Font
                        ),
                      ),
                      Text(
                        'terms and conditions',
                        style: TextStyle(
                          color: primaryColor,
                         
                          fontSize: isPortrait?size.width*0.04:size.width*0.03, // Responsive Font
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
