import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:stitchmate/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/widgets/mybutton.dart';

class ChooseVehicle extends StatefulWidget {
  const ChooseVehicle({super.key});

  @override
  State<ChooseVehicle> createState() => _ChooseVehicleState();
}

class _ChooseVehicleState extends State<ChooseVehicle> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // Refresh data when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshVehicles();
    });
  }

  Future<void> _refreshVehicles() async {
    // Get provider without listening and refresh vehicles
    final provider = Provider.of<ChooseVehicleProvider>(context, listen: false);
    await provider.refreshVehicles();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChooseVehicleProvider>(context);
    final size = MediaQuery.of(context).size;

    // Get selected vehicle details if available
    final selectedVehicle = provider.getSelectedVehicleDetails();
    final selectedCarType =
        provider.carTypes.isEmpty
            ? null
            : provider.carTypes[provider.selectedCarIndex];

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
            'Choose a vehicle class',
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
            'Choose a vehicle class',
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
                onPressed: () => _refreshVehicles(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // If no vehicles available, show message
    if (provider.carTypes.isEmpty) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios),
          ),
          title: const Text(
            'Choose a vehicle class',
            style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshVehicles,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No vehicles available at the moment.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshVehicles,
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
          'Choose a vehicle class',
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
        onRefresh: _refreshVehicles,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              Text(
                selectedCarType?.title ?? 'Select a Vehicle',
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'PPNeueMontreal',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                selectedVehicle != null
                    ? '${selectedVehicle.name} ${selectedVehicle.model} or similar'
                    : 'Mercedes-Benz E-Class or similar',
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
                    SvgPicture.asset('assets/icons/leaf.svg'),
                    SizedBox(width: size.width * 0.03),
                    const Text(
                      '3 Seats',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'PPNeueMontreal',
                        fontWeight: FontWeight.w500,
                        color: grey,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    SvgPicture.asset('assets/icons/bag.svg'),
                    SizedBox(width: size.width * 0.03),
                    const Text(
                      '2 Bags',
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

              // Display vehicle image from Supabase if available, otherwise use asset
              selectedCarType?.imageUrl != null
                  ? Container(
                    width: size.width * 1,
                    height: size.height * 0.3,
                    padding: const EdgeInsets.all(16),
                    child: Image.network(
                      selectedCarType!.imageUrl!,
                      width: size.width * 0.8,
                      height: size.height * 0.25,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          selectedCarType.path,
                          width: size.width * 0.8,
                          height: size.height * 0.25,
                          fit: BoxFit.contain,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                    ),
                  )
                  : Image.asset(
                    selectedCarType?.path ?? 'assets/images/mercedes.png',
                    width: size.width * 1,
                    height: size.height * 0.3,
                  ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SvgPicture.asset('assets/icons/car_icon.svg'),
                    SizedBox(width: size.width * 0.02),
                    const Text(
                      'CAR DETAILS',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: nextbg),
                    // Show vehicle description if available
                    if (selectedVehicle != null &&
                        selectedVehicle.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          selectedVehicle.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'PPNeueMontreal',
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    // Year and model info if available
                    if (selectedVehicle != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Year: ${selectedVehicle.year} | Model: ${selectedVehicle.model}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'PPNeueMontreal',
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    const Text(
                      '\u2022   Make as many stops as you need',
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
                  itemCount: provider.carTypes.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final carType = provider.carTypes[index];
                    final isSelected = provider.selectedCarIndex == index;

                    return GestureDetector(
                      onTap: () => provider.selectCar(index),
                      child: Container(
                        width: size.width * 0.5,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? secondaryColor : phonefieldColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Display car image from Supabase or asset
                            carType.imageUrl != null
                                ? Image.network(
                                  carType.imageUrl!,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      carType.path,
                                      height: 60,
                                      fit: BoxFit.contain,
                                    );
                                  },
                                )
                                : Image.asset(
                                  carType.path,
                                  height: 60,
                                  fit: BoxFit.contain,
                                ),
                            Text(
                              carType.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'PPNeueMontreal',
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: size.height * 0.01),
                            if (carType.price !=
                                null) // Only show price if it exists
                              Text(
                                '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'PPNeueMontreal',
                                  fontWeight: FontWeight.bold,
                                  color: grey,
                                ),
                              ),
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
                  final vehicleprovider = Provider.of<ChooseVehicleProvider>(
                    context,
                    listen: false,
                  );
                  vehicleprovider.selectedCar =
                      provider.carTypes[provider.selectedCarIndex].title;
                  Navigator.pushNamed(context, '/bookingconfirmation');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
