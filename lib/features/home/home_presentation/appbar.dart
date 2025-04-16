import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stitchmate/features/profile/viewmodels/profile_image_notifier.dart';

final SupabaseClient _supabase = Supabase.instance.client;

class CustomAppBar extends StatefulWidget {
  final bool forceRefresh;
  
  const CustomAppBar({
    super.key,
    this.forceRefresh = false,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  File? _imagefile;
  String? _profilePictureUrl;
  bool _isLoading = true;
  bool _isMounted = true;
  String? _currentUserId; // Store the current user ID
  DateTime _lastRefresh = DateTime.now();
  
  // Get the global image change notifier
  final _imageChangeNotifier = ProfileImageChangeNotifier();
  
  @override
  void initState() {
    super.initState();
    
    // Use a post-frame callback to ensure we're not in the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfilePicture(forceRefresh: true);
    });
    
    // Listen for changes to the profile image
    _imageChangeNotifier.lastUpdated.addListener(_onProfileImageChanged);
  }
  
  @override
  void didUpdateWidget(CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Force refresh when the widget updates or when forceRefresh flag changes
    if (widget.forceRefresh || oldWidget.forceRefresh != widget.forceRefresh) {
      _loadProfilePicture(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    // Remove listener when disposing
    _imageChangeNotifier.lastUpdated.removeListener(_onProfileImageChanged);
    _isMounted = false;
    super.dispose();
  }
  
  // Called when the profile image changes
  void _onProfileImageChanged() {
    if (_isMounted) {
      // Only reload if we haven't just refreshed (debounce)
      if (DateTime.now().difference(_lastRefresh).inSeconds > 1) {
        _loadProfilePicture(forceRefresh: true);
      }
    }
  }

  Future<void> _loadProfilePicture({bool forceRefresh = false}) async {
    if (!_isMounted) return;
    
    // Update last refresh time
    _lastRefresh = DateTime.now();
    
    setState(() {
      _isLoading = true;
    });
    
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (_isMounted) {
        setState(() {
          _isLoading = false;
          _profilePictureUrl = null;
        });
      }
      return;
    }
    
    // Store current user ID
    _currentUserId = user.id;

    try {
      // Check if the global notifier already has a URL for this user
      final notifierUrl = _imageChangeNotifier.getImageUrl(user.id);
      
      // If we have a URL and not forcing refresh, use it
      if (!forceRefresh && notifierUrl != null && notifierUrl.isNotEmpty) {
        if (_isMounted) {
          setState(() {
            _profilePictureUrl = notifierUrl;
            _isLoading = false;
          });
        }
        return;
      }
      
      // First try to get from user metadata (fastest method)
      final profileUrl = user.userMetadata?['profileUrl'];
      
      if (profileUrl != null && profileUrl.isNotEmpty) {
        if (_isMounted) {
          setState(() {
            _profilePictureUrl = '$profileUrl?t=${DateTime.now().millisecondsSinceEpoch}';
            _isLoading = false;
          });
          
          // Update the global notifier with user ID
          _imageChangeNotifier.updateImageUrl(user.id, _profilePictureUrl);
        }
        return;
      }
      
      // Then try to get from users table
      if (user.email != null) {
        try {
          final userData = await _supabase
              .from('users')
              .select('imageurl')
              .eq('email', user.email!)
              .single();
              
          final dbImageUrl = userData['imageurl'];
          if (dbImageUrl != null && dbImageUrl.isNotEmpty) {
            if (_isMounted) {
              // Add timestamp to URL to force refresh
              final refreshedUrl = '$dbImageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
              
              setState(() {
                _profilePictureUrl = refreshedUrl;
                _isLoading = false;
              });
              
              // Update metadata for faster access next time
              await _supabase.auth.updateUser(
                UserAttributes(
                  data: {'profileUrl': dbImageUrl},
                ),
              );
              
              // Update the global notifier with user ID
              _imageChangeNotifier.updateImageUrl(user.id, refreshedUrl);
            }
            return;
          }
        } catch (e) {
          debugPrint('Error fetching user data: $e');
        }
      }

      // Fallback to the old method if no URL found
      final files = await _supabase.storage
          .from('profiles')
          .list(path: 'profilepics');

      if (!_isMounted) return;

      final matchingFiles = files.where(
        (file) => file.name.startsWith(user.id),
      ).toList();
      
      if (matchingFiles.isNotEmpty) {
        final matchingFile = matchingFiles.first;
        final imageUrl = _supabase.storage
            .from('profiles')
            .getPublicUrl('profilepics/${matchingFile.name}');

        // Add timestamp to force refresh
        final refreshedUrl = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';

        if (_isMounted) {
          setState(() {
            _profilePictureUrl = refreshedUrl;
            _isLoading = false;
          });
          
          // Save to user metadata for faster access next time
          await _supabase.auth.updateUser(
            UserAttributes(
              data: {'profileUrl': imageUrl},
            ),
          );
          
          // Update the global notifier with user ID
          _imageChangeNotifier.updateImageUrl(user.id, refreshedUrl);
          
          // Also update users table if email exists
          if (user.email != null) {
            try {
              await _supabase
                  .from('users')
                  .update({'imageurl': imageUrl})
                  .eq('email', user.email!);
            } catch (e) {
              debugPrint('Error updating user table: $e');
            }
          }
        }
      } else {
        if (_isMounted) {
          setState(() {
            _profilePictureUrl = null;
            _isLoading = false;
          });
          
          // Update the global notifier with user ID and null
          _imageChangeNotifier.updateImageUrl(user.id, null);
        }
      }
    } catch (e) {
      debugPrint('Error loading profile picture: $e');
      if (_isMounted) {
        setState(() {
          _profilePictureUrl = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: _isLoading 
              ? ShimmerLoading(
                  width: 40,
                  height: 40,
                )
              : _buildProfileImage(),
        ),
        Container(
          height: size.height * 0.06,
          width: size.width * 0.6,
          decoration: BoxDecoration(
            color: phonefieldColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                // The location row content
              ],
            ),
          ),
        ),
        _loadSvg('assets/icons/notif.svg', 24, 24),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_imagefile != null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        backgroundImage: FileImage(_imagefile!),
      );
    } else if (_profilePictureUrl != null) {
      // Add userId to cacheKey to ensure proper caching per user
      final String userId = _currentUserId ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      return CachedNetworkImage(
        imageUrl: _profilePictureUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => ShimmerLoading(
          width: 40,
          height: 40,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: Image.asset(
            'assets/icons/person.png',
            color: black,
            width: 24,
            height: 24,
          ),
        ),
        // Include userId in cacheKey to avoid sharing cached images between users
        cacheKey: '${userId}_$timestamp',
        // Disable caching to ensure we always get fresh images
        cacheManager: null,
        memCacheWidth: 160,
        memCacheHeight: 160,
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        child: Image.asset(
          'assets/icons/person.png',
          color: black,
          width: 24,
          height: 24,
        ),
      );
    }
  }

  Widget _loadSvg(String asset, double width, double height) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      colorFilter: const ColorFilter.mode(black, BlendMode.srcIn),
    );
  }
}