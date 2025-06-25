import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            color: blacktext,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blacktext),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('1. Acceptance of Terms', [
                'By accessing and using StitchMate, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
                'If you do not agree with any of these terms, you are prohibited from using or accessing this application.',
              ]),
              const SizedBox(height: 24),
              _buildSection('2. Use License', [
                'Permission is granted to temporarily use StitchMate for personal, non-commercial purposes.',
                'This license shall automatically terminate if you violate any of these restrictions.',
                'Upon termination, you must cease all use of the application.',
              ]),
              const SizedBox(height: 24),
              _buildSection('3. User Account', [
                'You must be at least 18 years old to use this service.',
                'You are responsible for maintaining the confidentiality of your account.',
                'You agree to provide accurate and complete information when creating your account.',
              ]),
              const SizedBox(height: 24),
              _buildSection('4. Booking and Payments', [
                'All bookings are subject to availability.',
                'Prices are subject to change without notice.',
                'Payment processing is handled through secure third-party providers.',
                'Cancellation policies vary by service provider.',
              ]),
              const SizedBox(height: 24),
              _buildSection('5. User Conduct', [
                'You agree not to:',
                '• Use the service for any illegal purpose',
                '• Attempt to gain unauthorized access',
                '• Interfere with the proper working of the application',
                '• Use automated systems or software to extract data',
              ]),
              const SizedBox(height: 24),
              _buildSection('6. Intellectual Property', [
                'The application and its original content, features, and functionality are owned by StitchMate.',
                'All trademarks, service marks, and trade names are proprietary to StitchMate.',
              ]),
              const SizedBox(height: 24),
              _buildSection('7. Limitation of Liability', [
                'StitchMate shall not be liable for any indirect, incidental, special, consequential, or punitive damages.',
                'We do not guarantee the accuracy of third-party information.',
              ]),
              const SizedBox(height: 24),
              _buildSection('8. Changes to Terms', [
                'We reserve the right to modify these terms at any time.',
                'We will notify users of any material changes.',
                'Continued use of the service constitutes acceptance of new terms.',
              ]),
              const SizedBox(height: 24),
              _buildSection('Contact Information', [
                'For questions about these Terms of Service, please contact us at:',
                'Email: legal@stitchmate.com',
                'Phone: +1 (555) 123-4567',
              ]),
              const SizedBox(height: 24),
              _buildSection('Last Updated', [
                'These Terms of Service were last updated on March 15, 2024.',
              ]),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  points.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        point,
                        style: const TextStyle(
                          color: blacktext,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
