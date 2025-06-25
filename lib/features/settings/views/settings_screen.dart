import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/settings/views/privacy_policy_screen.dart';
import 'package:stitchmate/features/settings/views/terms_of_service_screen.dart';
import 'package:stitchmate/features/settings/views/help_support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  // bool _darkModeEnabled = false;
  // String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          'Settings',
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
              _buildSectionTitle('Preferences'),
              _buildSwitchTile(
                'Notifications',
                'Receive notifications about your trips and updates',
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              // _buildSwitchTile(
              //   'Dark Mode',
              //   'Enable dark mode for the app',
              //   _darkModeEnabled,
              //   (value) => setState(() => _darkModeEnabled = value),
              // ),
              // const SizedBox(height: 24),
              // _buildSectionTitle('Language'),
              // _buildLanguageSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Account'),
              _buildSettingsTile(
                'Privacy Policy',
                Icons.privacy_tip_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                'Terms of Service',
                Icons.description_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsOfServiceScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile('Help & Support', Icons.help_outline, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              }),
              const SizedBox(height: 24),
              _buildSectionTitle('About'),
              _buildSettingsTile('App Version', Icons.info_outline, () {
                // Show app version info
              }, trailing: const Text('1.0.0')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: blacktext,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: lightgrey, fontSize: 14),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            color: blacktext,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: lightgrey),
        onTap: onTap,
      ),
    );
  }

  // Widget _buildLanguageSelector() {
  //   return Card(
  //     elevation: 0,
  //     color: Colors.white,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //       child: DropdownButtonHideUnderline(
  //         child: DropdownButton<String>(
  //           value: _selectedLanguage,
  //           isExpanded: true,
  //           icon: const Icon(Icons.arrow_drop_down, color: lightgrey),
  //           style: const TextStyle(
  //             color: blacktext,
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //           items:
  //               ['English', 'Spanish', 'French', 'German'].map((String value) {
  //                 return DropdownMenuItem<String>(
  //                   value: value,
  //                   child: Text(value),
  //                 );
  //               }).toList(),
  //           onChanged: (String? newValue) {
  //             if (newValue != null) {
  //               setState(() {
  //                 _selectedLanguage = newValue;
  //               });
  //             }
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
