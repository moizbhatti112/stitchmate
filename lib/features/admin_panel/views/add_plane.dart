import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AddPlane extends StatefulWidget {
  const AddPlane({super.key});

  @override
  State<AddPlane> createState() => _AddPlaneState();
}

class _AddPlaneState extends State<AddPlane> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  File? _imageFile;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _imageFile = File(pickedImage.path);
          _uploadedImageUrl =
              null; // Reset uploaded URL when new image is picked
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  // In your _uploadImageToStorage method:
  Future<String?> _uploadImageToStorage() async {
    if (_imageFile == null) {
      return null;
    }

    try {
      // Generate a unique file name
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_imageFile!.path)}';
      final String fileExtension = path.extension(_imageFile!.path);
      final String storagePath = '$fileName$fileExtension';

      // Upload to Supabase Storage - use the correct bucket name
      await Supabase.instance.client.storage
          .from(
            'planeimages',
          ) // Changed from 'vehicle_images' to 'vehicleimages'
          .upload(
            storagePath,
            _imageFile!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get the public URL - use the correct bucket name
      final String publicUrl = Supabase.instance.client.storage
          .from(
            'planeimages',
          ) // Changed from 'vehicle_images' to 'vehicleimages'
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to upload image: ${e.toString()}';
      });
      return null;
    }
  }

  Future<void> _savePlane() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFile == null && _uploadedImageUrl == null) {
      setState(() {
        _errorMessage = 'Please select an image for the plane';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Upload image if not already uploaded
      String? imageUrl = _uploadedImageUrl;
      if (_imageFile != null && _uploadedImageUrl == null) {
        imageUrl = await _uploadImageToStorage();
        if (imageUrl == null) {
          throw Exception('Failed to upload image');
        }
        _uploadedImageUrl = imageUrl; // Save the URL for reference
      }

      final plane = {
        'name': _nameController.text.trim(),
        'model': _modelController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'image_url': imageUrl,
        'description': _descriptionController.text.trim(),
        'vehicle_type': 'plane',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save to Supabase
      await Supabase.instance.client.from('planes').insert(plane);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plane added successfully')),
        );

        // Clear form
        _nameController.clear();
        _modelController.clear();
        _yearController.clear();
        _descriptionController.clear();
        setState(() {
          _imageFile = null;
          _uploadedImageUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add plane: ${e.toString()}';
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
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Add New Plane'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),

                      // Image Picker
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child:
                                _imageFile != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : _uploadedImageUrl != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _uploadedImageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                    : Center(
                                      child: Icon(
                                        Icons.add_photo_alternate,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: Text(
                              _imageFile != null || _uploadedImageUrl != null
                                  ? 'Change Image'
                                  : 'Select Image',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Plane Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter plane name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Model Field
                      TextFormField(
                        controller: _modelController,
                        decoration: InputDecoration(
                          labelText: 'Model',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter model';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Year Field
                      TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter year';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _savePlane,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Plane',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
