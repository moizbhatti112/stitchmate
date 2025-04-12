import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';
import 'package:stitchmate/features/home/home_presentation/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isButtonEnabled = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInputs);
    _passwordController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    final bool isEmailValid = _isValidEmail(_emailController.text);
    final bool isPasswordEntered = _passwordController.text.isNotEmpty;
    
    setState(() {
      _emailError = _emailController.text.isEmpty ? null : 
                   (isEmailValid ? null : 'Please enter a valid email address');
      
      _passwordError = null; // Simple validation for login - just needs to be non-empty
      
      // Button is enabled when both fields are valid
      isButtonEnabled = isEmailValid && isPasswordEntered;
    });
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleLogin() async {
    if (!isButtonEnabled || _isLoading) return;
    
    // Get values
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    // Set loading state
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });
    
    try {
      // Get auth provider
      Provider.of<AuthProvider>(context, listen: false);
      
      // Sign in with Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // If successful, navigate to home screen
      if (response.user != null) {
        // Navigate to home screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false, // Remove all previous routes
          );
        }
      }
    } on AuthException catch (e) {
      // Handle specific auth errors
      setState(() {
        if (e.message.toLowerCase().contains('email')) {
          _emailError = e.message;
        } else if (e.message.toLowerCase().contains('password')) {
          _passwordError = e.message;
        } else {
          // General error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      });
    } catch (e) {
      // Handle general errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      // Reset loading state
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
                    SizedBox(height: size.height * 0.05),
                 
                    SizedBox(height: size.height * 0.06),
                  

                  
                    SizedBox(height: size.height * 0.05),
                    
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
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: phonefieldColor,
                          hintText: 'Your email address',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: phonefieldtext,
                          ),
                          errorText: _emailError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: phonefieldtext,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    
                    // Password Field
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
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: phonefieldColor,
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: phonefieldtext,
                          ),
                          errorText: _passwordError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: phonefieldtext,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: phonefieldtext,
                            ),
                            onPressed: !_isLoading ? () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            } : null,
                          ),
                        ),
                      ),
                    ),
                    
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        child: TextButton(
                          onPressed: () {
                         
                          } ,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.04),
                    
                    // Login Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        height: isPortrait ? size.height * 0.07 : size.height * 0.1,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (isButtonEnabled && !_isLoading) ? primaryColor : nextbg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: (isButtonEnabled && !_isLoading) ? _handleLogin : null,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isButtonEnabled ? Colors.white : nexttext,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.03),
                    
                    // Don't have an account section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: lightblack,
                            ),
                          ),
                          TextButton(
                            onPressed: !_isLoading ? () {
                              Navigator.pushNamed(context, '/enteremail');
                            } : null,
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Optional: Social Login Buttons
                    SizedBox(height: size.height * 0.02),
                  
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