import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';
import 'package:stitchmate/features/authentication/views/enter_code.dart';


class EnterEmail extends StatefulWidget {
  const EnterEmail({super.key});

  @override
  State<EnterEmail> createState() => _EnterEmailState();
}

class _EnterEmailState extends State<EnterEmail> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Password validation flags
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  bool _emailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      _validateEmail(_emailController.text);
      _validateForm();
    });
    _passwordController.addListener(() {
      _validatePassword(_passwordController.text);
      _validateForm();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isButtonEnabled = _emailValid && _isStrongPassword();
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 8;
      _hasUppercase = value.contains(RegExp(r'[A-Z]'));
      _hasLowercase = value.contains(RegExp(r'[a-z]'));
      _hasDigit = value.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isStrongPassword() {
    return _hasMinLength && _hasUppercase && _hasLowercase && _hasDigit && _hasSpecialChar;
  }

  void _validateEmail(String email) {
    // More comprehensive email validation pattern
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
    );
    
    setState(() {
      _emailValid = emailRegex.hasMatch(email) && 
                   email.isNotEmpty && 
                   email.contains('@') && 
                   email.contains('.') &&
                   !email.startsWith('@') &&
                   !email.endsWith('@') &&
                   !email.endsWith('.');
      
      // Clear any previous error message when email changes
      _errorMessage = null;
    });
  }

  Future<void> _signUp() async {
    if (!isButtonEnabled || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      // Handle different result cases
      if (result == 'email_already_registered') {
        // Show error for already registered email and DON'T navigate
        setState(() {
          _errorMessage = 'This email is already registered. Please log in instead.';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This email is already registered. Please log in instead.'),
            action: SnackBarAction(
              label: 'Login',
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          )
        );
      } else if (result == 'success' || result == 'verification_needed') {
        // For both successful signup and when verification is needed, navigate to the code screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnterCode(email: _emailController.text.trim())
          ),
        ).then((_) {
          if (mounted) {
            setState(() {
              _validateEmail(_emailController.text);
              _validatePassword(_passwordController.text);
              _validateForm();
            });
          }
        });
      } else {
        // Handle other error messages
        setState(() {
          _errorMessage = result ?? 'An error occurred during sign up';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? 'An error occurred during sign up'))
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
                   
                    SizedBox(height: size.height * 0.038),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SvgPicture.asset(
                        'assets/icons/email.svg',
                        height: size.height * 0.04,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        'Enter Email and Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'ppneuemontreal-thin',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Text(
                        'To continue please enter your email and password',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'HelveticaNeueMedium',
                          fontWeight: FontWeight.w500,
                          color: lightblack
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    
                    // Email Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: _validateEmail,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: phonefieldColor,
                          hintText: 'Your email address',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: phonefieldtext,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.email_outlined),
                          suffixIcon: _emailController.text.isNotEmpty
                              ? Icon(
                                  _emailValid ? Icons.check_circle : Icons.error,
                                  color: _emailValid ? Colors.green : Colors.red,
                                )
                              : null,
                          errorText: _errorMessage,
                        ),
                      ),
                    ),
                    
                    // Password Field
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          _validatePassword(value);
                          _validateForm();
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: phonefieldColor,
                          hintText: 'Create a strong password',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: phonefieldtext,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Password requirements - Always show these
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password requirements:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          _buildRequirement('At least 8 characters', _hasMinLength),
                          _buildRequirement('At least one uppercase letter', _hasUppercase),
                          _buildRequirement('At least one lowercase letter', _hasLowercase),
                          _buildRequirement('At least one number', _hasDigit),
                          _buildRequirement('At least one special character', _hasSpecialChar),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        height: isPortrait ? size.height * 0.07 : size.height * 0.1,
                        width: isPortrait ? double.infinity : size.width * 01,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonEnabled ? primaryColor : nextbg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isButtonEnabled ? _signUp : null,
                          child: _isLoading 
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Signup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isButtonEnabled ? Colors.white : nexttext,
                                ),
                              ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:  black ,
                                    ),
                                  ),
                                   GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                     child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color:  primaryColor ,
                                      ),
                                                                       ),
                                   ),
                      ],
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
  
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}