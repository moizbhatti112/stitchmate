import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';

import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';

class EnterCode extends StatefulWidget {
  final String email;
  const EnterCode({super.key, required this.email});

  @override 
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  final TextEditingController _codeController = TextEditingController();
  bool isButtonEnabled = false;
  bool _isVerifying = false;
  String? _errorMessage;

  void _checkCode(String value) {
    if (value.length == 6) {
      if (!isButtonEnabled) {
        // Ensure state only updates once
        setState(() {
          isButtonEnabled = true;
          _errorMessage = null;
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

  Future<void> _verifyCode() async {
    if (!isButtonEnabled || _isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Using the provider to verify OTP (which will now also create the user record)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.verifyOTP(
        email: widget.email,
        otp: _codeController.text.trim(),
      );

      if (result == 'success') {
        // Navigate to profile screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/profilescreen');
        }
      } else {
        setState(() {
          _errorMessage = result ?? 'Verification failed. Please try again.';  
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
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
                        'We sent verification code to your Email',
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
                        widget.email,
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
                        onChanged: _checkCode,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(letterSpacing: 40),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: phonefieldColor,
                          hintText: "―  ―  ―  ―  ―  ― ",
                          hintStyle: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: phonefieldtext,
                            letterSpacing: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          counterText: "",
                          errorText: _errorMessage,
                        ),
                      ),
                    ),

                    // Display resend code option
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            final scfmsngr = ScaffoldMessenger.of(context);
                            try {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              await authProvider.signUpWithEmail(
                                email: widget.email,
                                password: '', // We don't need the password again
                              );
                              
                              scfmsngr.showSnackBar(
                                SnackBar(
                                  content: Text('New verification code sent'),
                                ),
                              );
                            } catch (e) {
                              scfmsngr.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to resend code: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Resend verification code',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
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
                          onPressed: isButtonEnabled ? _verifyCode : null,
                          child:
                              _isVerifying
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isButtonEnabled
                                              ? Colors.white
                                              : nexttext,
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