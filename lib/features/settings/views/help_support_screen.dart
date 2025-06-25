import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Help & Support',
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
              _buildContactCard(context),
              const SizedBox(height: 24),
              _buildSection('Frequently Asked Questions', [
                _buildFAQItem(
                  'How do I book a trip?',
                  'To book a trip, navigate to the home screen and select your desired service (Luxury Ground Transportation, Private Jet Services, or AI Enhanced Travel Planning). Follow the prompts to complete your booking.',
                ),
                _buildFAQItem(
                  'What payment methods do you accept?',
                  'We accept all major credit cards, including Visa, MasterCard, American Express, and Discover. We also support Apple Pay and Google Pay.',
                ),
                _buildFAQItem(
                  'How can I modify or cancel my booking?',
                  'You can modify or cancel your booking through the "My Itinerary" section. Please note that cancellation policies may vary depending on the service provider.',
                ),
                _buildFAQItem(
                  'Is my payment information secure?',
                  'Yes, we use industry-standard encryption and security measures to protect your payment information. All transactions are processed through secure payment gateways.',
                ),
                _buildFAQItem(
                  'How do I contact customer support?',
                  'You can reach our customer support team through the contact options above, or by using the chat feature in the app.',
                ),
              ]),
              const SizedBox(height: 24),
              _buildSection('Quick Links', [
                _buildLinkItem(
                  context,
                  'Privacy Policy',
                  Icons.privacy_tip_outlined,
                  () {
                    Navigator.pushNamed(context, '/privacy-policy');
                  },
                ),
                _buildLinkItem(
                  context,
                  'Terms of Service',
                  Icons.description_outlined,
                  () {
                    Navigator.pushNamed(context, '/terms-of-service');
                  },
                ),
                _buildLinkItem(
                  context,
                  'Report an Issue',
                  Icons.bug_report_outlined,
                  () {
                    // Navigate to issue reporting
                  },
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.phone_outlined,
              'Phone Support',
              '+1 (555) 123-4567',
              () {
                // Handle phone call
              },
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.email_outlined,
              'Email Support',
              'support@stitchmate.com',
              () {
                // Handle email
              },
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.chat_outlined,
              'Live Chat',
              'Available 24/7',
              () {
                // Open chat
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: blacktext,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: lightgrey, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: lightgrey),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          color: blacktext,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: lightgrey, fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          color: blacktext,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: lightgrey),
      onTap: onTap,
    );
  }
}
