import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyde/core/constants/colors.dart';

class EnterCode extends StatefulWidget {
  final String number;
  const EnterCode({super.key, required this.number});

  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  final TextEditingController _codeController = TextEditingController();
  bool isButtonEnabled = false;

  void _checkPhoneNumber(String value) {
    if (value.length == 6) {
      if (!isButtonEnabled) {
        // Ensure state only updates once
        setState(() {
          isButtonEnabled = true;
        });
      }
    } else {
      if (isButtonEnabled) {
        setState(() {
          isButtonEnabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,

        body: OrientationBuilder(
          builder: (context, orientation) {
            final Size size = MediaQuery.sizeOf(context);
            final isPortrait = orientation == Orientation.portrait;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, color: black),
                    ),
                    SizedBox(height: size.height * 0.038),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SvgPicture.asset(
                        'assets/icons/mobile.svg',
                        height: size.height * 0.035,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        'Enter Code',
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'ppneuemontreal-medium',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        'We sent verification code to your phone number',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'HelveticaNeueMedium',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        '+${widget.number}',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'HelveticaNeueMedium',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),

                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        onChanged: _checkPhoneNumber,
                        maxLength: 6, // OTP ke liye 6 digits
                        textAlign:
                            TextAlign.center, // Cursor ko start per set karega
                        textDirection:
                            TextDirection
                                .ltr, // Left-to-right direction enforce karega
                        style: TextStyle(letterSpacing: 40),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: phonefieldColor,
                          hintText: "―  ―  ―  ―  ―  ― ", // Using Horizontal Bar
                          hintStyle: TextStyle(
                            fontSize:
                                22, // Font size thoda bada taake bar prominent ho
                            fontWeight: FontWeight.w500,
                            color: phonefieldtext,
                            letterSpacing: 10, // Aur bhi spacing add ki gayi
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          counterText: "", // Hide default counter
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.09),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        height:
                            isPortrait ? size.height * 0.07 : size.height * 0.1,
                        width: isPortrait ? double.infinity : size.width * 01,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isButtonEnabled ? primaryColor : nextbg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isButtonEnabled ? () {
                            Navigator.pushReplacementNamed(context, '/welcome');
                              _codeController.clear();
                          } : null,
                          child: Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isButtonEnabled ? Colors.white : nexttext,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
