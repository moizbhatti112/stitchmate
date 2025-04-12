import 'package:flutter/material.dart';
import 'package:stitchmate/features/gyde_ai/views/ai_welcome.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class ProfileProvider extends ChangeNotifier {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController cnameController = TextEditingController();

  File? _image;
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _profileImageUrl;

  File? get image => _image;
  bool get isButtonEnabled => _isButtonEnabled && !_isLoading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get profileImageUrl => _profileImageUrl;

  final _supabase = Supabase.instance.client;

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
    // Modified to make profile image optional
    _isButtonEnabled =
        fnameController.text.isNotEmpty &&
        lnameController.text.isNotEmpty &&
        cnameController.text.isNotEmpty;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    }
  }
  
  // New method to upload profile image to Supabase storage
  Future<String?> uploadProfileImage(String userId) async {
    if (_image == null) return null;
    
    try {
      // Get file extension
      final fileExtension = path.extension(_image!.path);
      
      // Create a simpler file path structure - just the userId as filename
      final filePath = '$userId$fileExtension';
      
      // Check if user is authenticated
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }
      
      // Get mime type based on file extension
      String contentType = 'image/jpeg'; // Default
      if (fileExtension.toLowerCase() == '.png') {
        contentType = 'image/png';
      } else if (fileExtension.toLowerCase() == '.gif') {
        contentType = 'image/gif';
      } else if (fileExtension.toLowerCase() == '.webp') {
        contentType = 'image/webp';
      }
      
      // Read file as bytes for upload
      final fileBytes = await _image!.readAsBytes();
      
      // Upload to public bucket or with public permissions
      await _supabase.storage
          .from('profiles/profilepics')  // Access the subfolder directly
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );
      
      // Get public URL for the uploaded image
      final imageUrl = _supabase.storage.from('profiles').getPublicUrl('profilepics/$filePath');
      _profileImageUrl = imageUrl;
      
      debugPrint("Profile image uploaded successfully: $imageUrl");
      return imageUrl;
    } catch (e) {
      // Set detailed error message for debugging
      _errorMessage = "Failed to upload profile image: ${e.toString()}";
      debugPrint("Profile image upload error: $e");
      return null;
    }
  }
  
  Future<bool> saveUserProfile(BuildContext context) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get current user ID and email
      final userId = authProvider.user?.id;
      final email = authProvider.user?.email;
      
      if (email == null || userId == null) {
        _errorMessage = "User information not found. Please try logging in again.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Upload profile image if selected
      if (_image != null) {
        await uploadProfileImage(userId);
        // Note: We're not storing the URL in any database table,
        // just uploading to the storage bucket with the user's UUID as the filename
      }
      
      // Call the update method in AuthProvider
      final result = await authProvider.updateUserProfile(
        email: email,
        firstName: fnameController.text.trim(),
        lastName: lnameController.text.trim(),
        company: cnameController.text.trim(),
        imageUrl: _profileImageUrl ?? '', // Use the uploaded image URL if available
      );
      
      if (result == 'success') {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result ?? "Failed to update profile";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An error occurred: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
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
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: bgColor,
                                ),
                              ),
                              Text(
                                'Profile',
                                style: TextStyle(color: bgColor, fontSize: 20),
                              ),
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
                                  backgroundImage:
                                      provider.image != null
                                          ? FileImage(provider.image!)
                                          : null,
                                  child:
                                      provider.image == null
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
                                    onTap: provider.pickImage,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: bgColor,
                                      child: Icon(
                                        provider.image == null
                                            ? Icons.camera_alt
                                            : Icons.edit,
                                        color:
                                            provider.image == null
                                                ? nexttext
                                                : primaryColor,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Provide your basic details for a personalized experience.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: grey,
                            ),
                          ),
                          SizedBox(height: 30),
                          buildTextField(
                            'First Name',
                            provider.fnameController,
                            'Your first name',
                          ),
                          SizedBox(height: 10),
                          buildTextField(
                            'Last Name',
                            provider.lnameController,
                            'Your last name',
                          ),
                          SizedBox(height: 10),
                          buildTextField(
                            'Company Name',
                            provider.cnameController,
                            'Your company name',
                          ),
                          
                          // Display error message if any
                          if (provider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                provider.errorMessage!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            
                          SizedBox(height: size.height * 0.08),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: SizedBox(
                              height: size.height * 0.07,
                              width: double.infinity,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: size.height*0.01),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        provider.isButtonEnabled
                                            ? primaryColor
                                            : nextbg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: provider.isButtonEnabled
                                      ? () async {
                                          // Save user profile data
                                          final success = await provider.saveUserProfile(context);
                                          
                                          if (success && context.mounted) {
                                            // If successful, navigate to AI Welcome screen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AiWelcome(
                                                  name: provider.fnameController.text,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  child: provider.isLoading
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text(
                                          'Next',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                provider.isButtonEnabled
                                                    ? Colors.white
                                                    : nexttext,
                                          ),
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

  Widget buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
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
            counterText: "",
          ),
        ),
      ],
    );
  }
}