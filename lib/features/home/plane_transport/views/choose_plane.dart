// This is the fixed version of choose_plane.dart
import 'package:flutter/material.dart';
import 'package:stitchmate/features/home/plane_transport/models/plane_type.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/chooseplane_provider.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/mybutton.dart';

class ChoosePlane extends StatefulWidget {
  const ChoosePlane({super.key});

  @override
  State<ChoosePlane> createState() => _ChoosePlaneState();
}

class _ChoosePlaneState extends State<ChoosePlane> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Refresh data when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPlanes();
    });
  }

  Future<void> _refreshPlanes() async {
    // Get provider without listening and refresh planes
    final provider = Provider.of<ChoosePlaneProvider>(context, listen: false);
    await provider.refreshPlanes();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChoosePlaneProvider>(context);
    final size = MediaQuery.of(context).size;

    // Get selected plane details if available
    final selectedPlane = provider.getSelectedPlaneDetails();
    final selectedPlaneType = provider.planeTypes.isEmpty 
        ? null 
        : provider.planeTypes[provider.selectedPlaneIndex];

    // Show loading indicator while fetching data
    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text(
            'Choose a plane class',
            style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error message if any
    if (provider.errorMessage != null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text(
            'Choose a plane class',
            style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _refreshPlanes(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // If no planes available, show message
    if (provider.planeTypes.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text(
            'Choose a plane class',
            style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshPlanes,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No planes available at the moment.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshPlanes,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          'Choose a plane class',
          style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshKey.currentState?.show();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshPlanes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              Text(
                selectedPlaneType?.title ?? 'Select a Plane',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'PPNeueMontreal',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                selectedPlane != null
                    ? '${selectedPlane.name} ${selectedPlane.model} or similar'
                    : 'Cessna Citation or similar',
                style: const TextStyle(
                  fontSize: 17,
                  fontFamily: 'PPNeueMontreal',
                  fontWeight: FontWeight.w500,
                  color: grey,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, color: Colors.green),  // Replaced SVG with Icon
                    SizedBox(width: size.width * 0.03),
                    const Text(
                      '8 Seats',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                        color: grey,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Icon(Icons.luggage, color: Colors.grey),  // Replaced SVG with Icon
                    SizedBox(width: size.width * 0.03),
                    const Text(
                      '4 Bags',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                        color: grey,
                      ),
                    ),
                  ],
                ),
              ),
          
              // FIXED: Correct handling of image sources
              Container(
                width: size.width * 1,
                height: size.height * 0.3,
                padding: const EdgeInsets.all(16),
                child: _buildPlaneImage(selectedPlaneType, size),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.airplanemode_active, size: 24),  // Replaced SVG with Icon
                    SizedBox(width: size.width * 0.02),
                    const Text(
                      'PLANE DETAILS',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: nextbg),
                    // Show plane description if available
                    if (selectedPlane != null && selectedPlane.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          selectedPlane.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'PPNeueMontreal',
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    // Year and model info if available
                    if (selectedPlane != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Year: ${selectedPlane.year} | Model: ${selectedPlane.model}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'PPNeueMontreal',
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    const Text(
                      '\u2022   Comfortable seating',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                        color: grey,
                      ),
                    ),
                    const Text(
                      '\u2022   All-inclusive rates',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                        color: grey,
                      ),
                    ),
                    const Text(
                      '\u2022   Free cancellation up until 1 hour before pickup',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                        color: grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.01),
              SizedBox(
                height: size.height * 0.2,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.planeTypes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final planeType = provider.planeTypes[index];
                    final isSelected = provider.selectedPlaneIndex == index;
                    
                    return GestureDetector(
                      onTap: () => provider.selectPlane(index),
                      child: Container(
                        width: size.width * 0.5,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? secondaryColor : phonefieldColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // FIXED: Proper image loading based on source
                            _buildListItemImage(planeType),
                            Text(
                              planeType.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'PPNeueMontreal',
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            // Text(
                            //   '\$${planeType.price} USD',
                            //   style: const TextStyle(
                            //     fontSize: 18,
                            //     fontFamily: 'PPNeueMontreal',
                            //     fontWeight: FontWeight.bold,
                            //     color: grey,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: size.height * 0.015),
              MyButton(
                text: 'Select',
                onPressed: () {
                  final planeprovider = Provider.of<ChoosePlaneProvider>(
                    context,
                    listen: false,
                  );
                  planeprovider.selectedPlane =
                      provider.planeTypes[provider.selectedPlaneIndex].title;
                  Navigator.pushNamed(context, '/planebc');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ADDED: Helper method to build the correct image widget based on source
  Widget _buildPlaneImage(PlaneTypeModel? planeType, Size size) {
    if (planeType == null) {
      return Image.asset(
        'assets/images/plane.png',
        width: size.width * 0.8,
        height: size.height * 0.25,
        fit: BoxFit.contain,
      );
    }
    
    // Check if we have an image URL (from Supabase)
    if (planeType.imageUrl != null && planeType.imageUrl!.startsWith('http')) {
      return Image.network(
        planeType.imageUrl!,
        width: size.width * 0.8,
        height: size.height * 0.25,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to asset image if network image fails
          return Image.asset(
            planeType.path,
            width: size.width * 0.8,
            height: size.height * 0.25,
            fit: BoxFit.contain,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // Use asset image if no valid URL
      return Image.asset(
        planeType.path,
        width: size.width * 0.8,
        height: size.height * 0.25,
        fit: BoxFit.contain,
      );
    }
  }
  
  // ADDED: Helper method for list item images
  Widget _buildListItemImage(PlaneTypeModel planeType) {
    // Check if we have a valid image URL (from Supabase)
    if (planeType.imageUrl != null && planeType.imageUrl!.startsWith('http')) {
      return Image.network(
        planeType.imageUrl!,
        height: 60,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to asset image if network image fails
          return Image.asset(
            planeType.path,
            height: 60,
            fit: BoxFit.contain,
          );
        },
      );
    } else {
      // Use asset image if no valid URL
      return Image.asset(
        planeType.path,
        height: 60,
        fit: BoxFit.contain,
      );
    }
  }
}