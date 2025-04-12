import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

final SupabaseClient _supabase = Supabase.instance.client;

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key, });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  File? _imagefile;
  String? _profilePictureUrl;
  bool _isLoading = true;
  bool _isMounted = true; // Track whether the widget is mounted
  
  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when disposed
    super.dispose();
  }

  Future<void> _loadProfilePicture() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // Get user profile URL from user metadata
      final profileUrl = user.userMetadata?['profileUrl'];
      
      if (profileUrl != null && profileUrl.isNotEmpty) {
        if (_isMounted) {
          setState(() {
            _profilePictureUrl = profileUrl;
            _isLoading = false;
          });
        }
      } else {
        // Fallback to the old method if profileUrl is not found in metadata
        final files = await _supabase.storage
            .from('profiles')
            .list(path: 'profilepics');

        // Check if mounted before continuing
        if (!_isMounted) return;

        final matchingFile = files.firstWhere(
          (file) => file.name.startsWith(user.id),
          orElse: () => throw Exception('No profile picture found'),
        );

        final imageUrl = _supabase.storage
            .from('profiles')
            .getPublicUrl('profilepics/${matchingFile.name}');

        if (_isMounted) {
          setState(() {
            _profilePictureUrl = imageUrl;
            _isLoading = false;
          });
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
        // Avatar image with shimmer effect while loading
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
                const Icon(Icons.location_on, size: 25),
                const SizedBox(width: 10),
                const Text(
                  'New York, USA',
                  style: TextStyle(
                    color: black,
                    fontSize: 15,
                    fontFamily: 'HelveticaNeueMedium',
                  ),
                ),
                const Spacer(),
                _loadSvg('assets/icons/down.svg', 20, 20),
              ],
            ),
          ),
        ),
        _loadSvg('assets/icons/notif.svg', 24, 24),
      ],
    );
  }

  // Build profile image with CachedNetworkImage for caching
  Widget _buildProfileImage() {
    if (_imagefile != null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        backgroundImage: FileImage(_imagefile!),
      );
    } else if (_profilePictureUrl != null) {
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
          backgroundImage: const AssetImage('assets/icons/person.png'),
        ),
        cacheKey: _supabase.auth.currentUser?.id,
        memCacheWidth: 160, // 2x display size for high res screens
        memCacheHeight: 160,
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[300],
        backgroundImage: const AssetImage('assets/icons/person.png'),
      );
    }
  }

  // ✅ Optimized SVG Loader
  Widget _loadSvg(String asset, double width, double height) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      colorFilter: const ColorFilter.mode(black, BlendMode.srcIn),
    );
  }
}