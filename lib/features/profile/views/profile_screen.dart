import 'package:flutter/material.dart';
import 'package:gyde/features/gyde_ai/views/ai_welcome.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gyde/core/constants/colors.dart';
import 'package:provider/provider.dart';

class ProfileProvider extends ChangeNotifier {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController cnameController = TextEditingController();
  
  File? _image;
  bool _isButtonEnabled = false;

  File? get image => _image;
  bool get isButtonEnabled => _isButtonEnabled;

  ProfileProvider() {
    fnameController.addListener(checkFields);
    lnameController.addListener(checkFields);
    cnameController.addListener(checkFields);
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    cnameController.dispose();
    super.dispose();
  }

  void checkFields() {
    _isButtonEnabled =
        fnameController.text.isNotEmpty &&
        lnameController.text.isNotEmpty &&
        cnameController.text.isNotEmpty &&
        _image != null;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      checkFields();
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: bgColor,
          body: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              final Size size = MediaQuery.sizeOf(context);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Image.asset('assets/images/profilebg.png', fit: BoxFit.cover, width: double.infinity),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.arrow_back_ios, color: bgColor),
                              ),
                              Text('Profile', style: TextStyle(color: bgColor, fontSize: 20)),
                              Spacer(),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.edit, color: bgColor),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 100),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: bgColor,
                                  backgroundImage: provider.image != null ? FileImage(provider.image!) : null,
                                  child: provider.image == null ? Image.asset('assets/icons/person.png', color: black) : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: provider.pickImage,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: bgColor,
                                      child: Icon(
                                        provider.image == null ? Icons.camera_alt : Icons.edit,
                                        color: provider.image == null ? nexttext : primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                          Text('Provide your basic details for a personalized experience.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: grey)),
                          SizedBox(height: 30),
                          buildTextField('First Name', provider.fnameController, 'Your first name'),
                          SizedBox(height: 10),
                          buildTextField('Last Name', provider.lnameController, 'Your last name'),
                          SizedBox(height: 10),
                          buildTextField('Company Name', provider.cnameController, 'Your company name'),
                          SizedBox(height: size.height * 0.08),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              height: size.height * 0.07,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: provider.isButtonEnabled ? primaryColor : nextbg,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: provider.isButtonEnabled
                                    ? () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AiWelcome(name: provider.fnameController.text),
                                          ),
                                        )
                                    : null,
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: provider.isButtonEnabled ? Colors.white : nexttext,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: black)),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          maxLength: 15,
          decoration: InputDecoration(
            filled: true,
            fillColor: phonefieldColor,
            hintText: hint,
            hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: phonefieldtext),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            counterText: "",
          ),
        ),
      ],
    );
  }
}
