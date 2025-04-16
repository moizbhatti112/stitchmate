import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';
import 'package:stitchmate/features/profile/viewmodels/profile_image_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;



class ProfileProvider extends ChangeNotifier {
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController lnameController = TextEditingController();
  final TextEditingController cnameController = TextEditingController();

  // Access the global image change notifier
  final _imageChangeNotifier = ProfileImageChangeNotifier();

  File? _image;
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _profileImageUrl;
  bool _isDataLoaded = false;

  File? get image => _image;
  bool get isButtonEnabled => _isButtonEnabled && !_isLoading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get profileImageUrl => _profileImageUrl;
  bool get isDataLoaded => _isDataLoaded;

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

  // Load existing user profile data
  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user == null) {
        _errorMessage = "User not found. Please log in again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get user data from the users table
      if (user.email != null) {
        try {
          final userData =
              await _supabase
                  .from('users')
                  .select()
                  .eq('email', user.email!)
                  .single();

          // Set the profile data
          fnameController.text = userData['f_name'] ?? '';
          lnameController.text = userData['l_name'] ?? '';
          cnameController.text = userData['company'] ?? '';

          // Check if there's a valid image URL
          final dbImageUrl = userData['imageurl'];
          if (dbImageUrl != null && dbImageUrl.isNotEmpty) {
            _profileImageUrl = dbImageUrl;
          }
        } catch (e) {
          debugPrint('Error loading user data: $e');
        }
      }

      // Try to load existing profile image URL from storage if not found in DB
      if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
        try {
          // Check if there's an existing profile image by listing files
          final files = await _supabase.storage
              .from('profiles')
              .list(path: 'profilepics');

          final matchingFiles =
              files.where((file) => file.name.startsWith(user.id)).toList();

          if (matchingFiles.isNotEmpty) {
            final matchingFile = matchingFiles.first;
            final imageUrl = _supabase.storage
                .from('profiles')
                .getPublicUrl('profilepics/${matchingFile.name}');

            _profileImageUrl = imageUrl;

            // Also update users table with this URL if user.email is available
            if (user.email != null) {
              try {
                await _supabase
                    .from('users')
                    .update({'imageurl': imageUrl})
                    .eq('email', user.email!);
              } catch (e) {
                debugPrint('Error updating user table with image URL: $e');
              }
            }
          }
        } catch (e) {
          debugPrint("No existing profile image found: ${e.toString()}");
        }
      }

      _isDataLoaded = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to load profile: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }
// Updated method to upload profile image to Supabase storage
  Future<String?> uploadProfileImage(String userId) async {
    if (_image == null) {
      return _profileImageUrl; // Return existing URL if no new image
    }

    try {
      // Get file extension
      final fileExtension = path.extension(_image!.path);

      // Create a file path structure using the userId as filename
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

      // Upload to storage with upsert:true to replace existing file
      await _supabase.storage
          .from('profiles/profilepics')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      // Get public URL for the uploaded image
      final imageUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl('profilepics/$filePath');

      // Add a timestamp query parameter to force refresh
      final refreshUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      _profileImageUrl = refreshUrl;

      // Notify global image change with userId
      _imageChangeNotifier.updateImageUrl(currentUser.id, refreshUrl);

      debugPrint("Profile image uploaded successfully: $refreshUrl");
   
      return refreshUrl;
    } catch (e) {
      _errorMessage = "Failed to upload profile image: ${e.toString()}";
      debugPrint("Profile image upload error: $e");
      return _profileImageUrl; // Return existing URL on error
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
        _errorMessage =
            "User information not found. Please try logging in again.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Upload profile image if selected
      String? imageUrl = _profileImageUrl;
      if (_image != null) {
        imageUrl = await uploadProfileImage(userId);
      }

      // Call the update method in AuthProvider
      final result = await authProvider.updateUserProfile(
        email: email,
        firstName: fnameController.text.trim(),
        lastName: lnameController.text.trim(),
        company: cnameController.text.trim(),
        imageUrl: imageUrl ?? '', // Use the uploaded image URL if available
      );

      if (result == 'success') {
        // Save profile URL in user metadata for easy access
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _supabase.auth.updateUser(
            UserAttributes(data: {'profileUrl': imageUrl}),
          );
        }

        // Notify of image change to update the app bar with the specific userId
        if (imageUrl != null) {
          // Force a notification by updating twice with a slight delay
          // This ensures all listeners detect the change
          _imageChangeNotifier.updateImageUrl(userId, null);
          
          // Small delay to ensure the change is detected
          await Future.delayed(Duration(milliseconds: 100));
          
          // Now set the actual image URL
          _imageChangeNotifier.updateImageUrl(userId, imageUrl);
        }

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
  
  // Add a method to explicitly clear the current user's profile image cache
  void clearProfileImageCache(String userId) {
    _imageChangeNotifier.clearImageUrl(userId);
  }

}

class ProfileScreen extends StatelessWidget {
  final bool fromDrawer;

  // Add optional parameter to know if we're coming from drawer
  const ProfileScreen({super.key, this.fromDrawer = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: bgColor,
          body: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              // Load user data when screen is first displayed
              if (!provider.isDataLoaded && !provider.isLoading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  provider.loadUserProfile();
                });
              }

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
                                // Show profile image with loading state
                                provider.isLoading
                                    ? CircleAvatar(
                                      radius: 50,
                                      backgroundColor: bgColor,
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                      ),
                                    )
                                    : _buildProfileImage(provider),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: provider.pickImage,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: bgColor,
                                      child: Icon(
                                        provider.image == null &&
                                                provider.profileImageUrl == null
                                            ? Icons.camera_alt
                                            : Icons.edit,
                                        color:
                                            provider.image == null &&
                                                    provider.profileImageUrl ==
                                                        null
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
                            fromDrawer ? 'Edit Profile' : 'Your Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            fromDrawer
                                ? 'Update your profile information'
                                : 'Provide your basic details for a personalized experience.',
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
                                padding: EdgeInsets.only(
                                  bottom: size.height * 0.01,
                                ),
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
                                  onPressed:
                                      provider.isButtonEnabled
                                          ? () async {
                                            // Save user profile data
                                            final success = await provider
                                                .saveUserProfile(context);

                                            if (success && context.mounted) {
                                              // Show success message
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Profile updated successfully',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              // Navigate based on source
                                              if (fromDrawer) {
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  '/homescreen',
                                                );
                                              }
                                            }
                                          }
                                          : null,
                                  child:
                                      provider.isLoading
                                          ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : Text(
                                            fromDrawer ? 'Update' : 'Next',
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

  // Helper method to build profile image
  Widget _buildProfileImage(ProfileProvider provider) {
    // If user picked a new image, show that
    if (provider.image != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: bgColor,
        backgroundImage: FileImage(provider.image!),
      );
    }
    // If there's an existing profile image URL, show that
    else if (provider.profileImageUrl != null &&
        provider.profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: bgColor,
        backgroundImage: NetworkImage(provider.profileImageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // This is just an error handler, not supposed to return a widget
          debugPrint('Error loading profile image: $exception');
        },
        child:
            provider.profileImageUrl == null
                ? Image.asset('assets/icons/person.png', color: black)
                : null,
      );
    }
    // Otherwise show default
    else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: bgColor,
        child: Image.asset('assets/icons/person.png', color: black),
      );
    }
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
