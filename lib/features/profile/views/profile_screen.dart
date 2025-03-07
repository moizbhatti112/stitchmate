import 'package:flutter/material.dart';
import 'package:gyde/features/gyde_ai/views/ai_welcome.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:gyde/core/constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _cnameController = TextEditingController();
  
  bool isButtonEnabled = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _fnameController.addListener(checkFields);
    _lnameController.addListener(checkFields);
    _cnameController.addListener(checkFields);
  }

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _cnameController.dispose();
    super.dispose();
  }

  void checkFields() {
    setState(() {
      isButtonEnabled = 
        _fnameController.text.isNotEmpty &&
        _lnameController.text.isNotEmpty &&
        _cnameController.text.isNotEmpty &&
         _image != null; 
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      checkFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            final Size size = MediaQuery.sizeOf(context);
            final isPortrait = orientation == Orientation.portrait;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/profilebg.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios, color: bgColor),
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(color: bgColor, fontSize: 20),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {
                                // Add edit functionality here
                              },
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
                                backgroundImage:
                                    _image != null ? FileImage(_image!) : null,
                                child:
                                    _image == null
                                        ? Image.asset(
                                          'assets/icons/person.png',
                                          color: black,
                                        )
                                        : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: bgColor,
                                    child: Icon(
                                      _image==null? Icons.camera_alt:
                                      Icons.edit,
                                      color:_image == null ? nexttext : primaryColor,
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
                        Text(
                          'Your Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'PPNeueMontreal',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Provide your basic details for a personalized experience.',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'HelveticaNeueMedium',
                            fontWeight: FontWeight.w600,
                            color: grey,
                          ),
                        ),
                        SizedBox(height: 30),
                        buildTextField('First Name', _fnameController, 'Your first name'),
                        SizedBox(height: 10),
                        buildTextField('Last Name', _lnameController, 'Your last name'),
                        SizedBox(height: 10),
                        buildTextField('Company Name', _cnameController, 'Your company name'),
                        SizedBox(height: size.height * 0.08),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                            height: isPortrait ? size.height * 0.07 : size.height * 0.1,
                            width: isPortrait ? double.infinity : size.width * 01,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isButtonEnabled ? primaryColor: nextbg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: isButtonEnabled
                                  ? () {
                                      // Next button pressed logic
                                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  AiWelcome(name: _fnameController.text,)));
                                    }
                                  : null,
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
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'HelveticaNeueMedium',
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          maxLength: 15,
          decoration: InputDecoration(
            filled: true,
            fillColor: phonefieldColor,
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: phonefieldtext,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            counterText: "", // Hide default counter
          ),
        ),
      ],
    );
  }
}
