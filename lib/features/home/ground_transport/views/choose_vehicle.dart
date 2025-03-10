import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/car_type.dart';

class ChooseVehicle extends StatefulWidget {
  const ChooseVehicle({super.key});

  @override
  State<ChooseVehicle> createState() => _ChooseVehicleState();
}

class _ChooseVehicleState extends State<ChooseVehicle> {
  // Sample car types data
  List<CarTypeModel> carTypes = [
    CarTypeModel(
      path: 'assets/images/mercedes.png',
      price: '205.46',
      title: 'Business Class',
    ),
    CarTypeModel(
      path: 'assets/images/elect1.png',
      price: '215.00',
      title: 'Electric Class',
    ),
  ];

  // Selected car type index
  int selectedCarIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Preload images
    precacheImage(const AssetImage('assets/images/mercedes.png'), context);
    _preloadSVGs();
  }

  // Function to preload SVGs
  void _preloadSVGs() {
    Future.wait([
      DefaultAssetBundle.of(context).load('assets/icons/leaf.svg'),
      DefaultAssetBundle.of(context).load('assets/icons/bag.svg'),
      DefaultAssetBundle.of(context).load('assets/icons/car_icon.svg'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          'Choose a vehicle class',
          style: TextStyle(fontSize: 20, fontFamily: 'PPNeueMontreal'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Horizontal scrollable car type list
            SizedBox(height: size.height * 0.05),

            // Selected car details
            Text(
              carTypes[selectedCarIndex].title,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'PPNeueMontreal',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              'Mercedes-Benz E-Class or similar',
              style: TextStyle(
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
            Image.asset(
              carTypes[selectedCarIndex].path,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: nextbg),
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
            Container(
              height: size.height * 0.2,
              margin: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: carTypes.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final carType = carTypes[index];
                  final isSelected = selectedCarIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCarIndex = index;
                      });
                    },
                    child: Container(
                      width: size.width * 0.5,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? secondaryColor : phonefieldColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? primaryColor : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(carType.path),
                          Text(
                            carType.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'PPNeueMontreal',
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            '${carType.price} USD',
                            style: TextStyle(
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
                Navigator.pushNamed(context, '/bookingconfirmation');
              },
            ),
          ],
        ),
      ),
    );
  }
}
