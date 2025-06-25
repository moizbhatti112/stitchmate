import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isButtonEnabled = false;
  String? _emailError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    final bool isEmailValid = _isValidEmail(_emailController.text);

    setState(() {
      _emailError =
          _emailController.text.isEmpty
              ? null
              : (isEmailValid ? null : 'Please enter a valid email address');
      isButtonEnabled = isEmailValid;
    });
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleSendCode() async {
    if (!isButtonEnabled || _isLoading) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);

      if (mounted) {
        Navigator.pushNamed(context, '/verify-code', arguments: email);
      }
    } catch (e) {
      setState(() {
        _emailError = 'Failed to send reset code. Please try again.';
      });
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter your email address to receive a verification code',
                  style: TextStyle(fontSize: 16, color: lightblack),
                ),
                const SizedBox(height: 30),
                Text(
                  'Email Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                TextFormField(
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (isButtonEnabled && !_isLoading)
                              ? primaryColor
                              : nextbg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        (isButtonEnabled && !_isLoading)
                            ? _handleSendCode
                            : null,
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Send Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    isButtonEnabled ? Colors.white : nexttext,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
