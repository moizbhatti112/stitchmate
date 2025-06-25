import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Privacy Policy',
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
              _buildSection('Information We Collect', [
                'Personal Information: Name, email address, phone number, and payment information.',
                'Travel Information: Trip details, preferences, and booking history.',
                'Device Information: IP address, device type, and operating system.',
                'Usage Data: How you interact with our app and services.',
              ]),
              const SizedBox(height: 24),
              _buildSection('How We Use Your Information', [
                'To provide and maintain our services',
                'To process your bookings and payments',
                'To send you important updates about your trips',
                'To improve our services and user experience',
                'To communicate with you about our services',
              ]),
              const SizedBox(height: 24),
              _buildSection('Information Sharing', [
                'We may share your information with:',
                '• Travel service providers to fulfill your bookings',
                '• Payment processors to handle transactions',
                '• Legal authorities when required by law',
                'We do not sell your personal information to third parties.',
              ]),
              const SizedBox(height: 24),
              _buildSection('Data Security', [
                'We implement appropriate security measures to protect your personal information.',
                'Your data is encrypted during transmission and storage.',
                'We regularly review and update our security practices.',
              ]),
              const SizedBox(height: 24),
              _buildSection('Your Rights', [
                'You have the right to:',
                '• Access your personal information',
                '• Correct inaccurate data',
                '• Request deletion of your data',
                '• Opt-out of marketing communications',
                '• Export your data',
              ]),
              const SizedBox(height: 24),
              _buildSection('Contact Us', [
                'If you have any questions about this Privacy Policy, please contact us at:',
                'Email: privacy@stitchmate.com',
                'Phone: +1 (555) 123-4567',
              ]),
              const SizedBox(height: 24),
              _buildSection('Last Updated', [
                'This Privacy Policy was last updated on March 15, 2024.',
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
