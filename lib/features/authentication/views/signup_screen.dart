import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/mybutton.dart';
// import 'package:stitchmate/core/widgets/socialmedia_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
   @override
  void initState() {
    super.initState();
    _precacheImages();
  }

  void _precacheImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Precache frequently used images
      precacheImage(const AssetImage('assets/images/carimage.png'), context);
      precacheImage(const AssetImage('assets/images/Gyde Logo.png'), context);
      precacheImage(const AssetImage('assets/icons/apple.png'), context);
      precacheImage(const AssetImage('assets/icons/google.png'), context);
      precacheImage(const AssetImage('assets/icons/fb.png'), context);
      // Add other images here
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: const _SignupContent(),
      ),
    );
  }
}

class _SignupContent extends StatelessWidget {
  const _SignupContent();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        final isPortrait = orientation == Orientation.portrait;
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Image (Car)
              Image.asset(
                'assets/images/carimage.png',
                width: size.width,
                height: isPortrait ? size.height * 0.4 : size.height * 0.45,
                fit: BoxFit.cover,
              ),
              SizedBox(height: size.height * (isPortrait ? 0.04 : 0.03)),

          
              SizedBox(height: size.height * (isPortrait ? 0.04 : 0.03)),

              // Tagline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Experience comfort, Tailored to your needs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isPortrait ? size.width*0.045 : size.width*0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: size.height * (isPortrait ? 0.05 : 0.03)),

              // Buttons
              MyButton(
                text: 'Continue ',
                onPressed: () {
                  Navigator.pushNamed(context, '/enteremail');
                },
              ),
              SizedBox(height: isPortrait ? size.height * 0.01 : size.height * 0.04),
              
              // Social Media Buttons
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   child: SocialmediaButton(
              //     path: 'assets/icons/google.png',
              //     onPressed: () {},
              //   ),
              // ),

              SizedBox(height: size.height * (isPortrait ? 0.04 : 0.02)),

              // Terms and Conditions
              const _TermsText(),
            ],
          ),
        );
      },
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Column(
      children: [
        Text(
          'By continuing, you have read and agree to our',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isPortrait ? size.width*0.04 : size.width*0.03,
          ),
        ),
        Text(
          'terms and conditions',
          style: TextStyle(
            color: primaryColor,
            fontSize: isPortrait ? size.width*0.04 : size.width*0.03,
          ),
        ),
      ],
    );
  }
}