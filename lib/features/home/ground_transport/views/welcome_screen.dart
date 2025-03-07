import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset('assets/images/limo.png'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Luxury Ground Transportation',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'PP Neue Montreal',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align to the top
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                        ), // Fine-tune vertical alignment
                        child: SvgPicture.asset('assets/icons/tick.svg'),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride in style with our premium chauffeur',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'service',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'Our professional chauffeurs provide world-\nclass service, ensuring you travel in comfort\nand elegance.',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                              color: grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align to the top
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                        ), // Fine-tune vertical alignment
                        child: SvgPicture.asset('assets/icons/tick.svg'),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride in style with our premium chauffeur',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'service',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'Our professional chauffeurs provide world-\nclass service, ensuring you travel in comfort\nand elegance.',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                              color: grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align to the top
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                        ), // Fine-tune vertical alignment
                        child: SvgPicture.asset('assets/icons/tick.svg'),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ride in style with our premium chauffeur',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'service',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            'Our professional chauffeurs provide world-\nclass service, ensuring you travel in comfort\nand elegance.',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PP Neue Montreal',
                              fontWeight: FontWeight.w500,
                              color: grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
}
