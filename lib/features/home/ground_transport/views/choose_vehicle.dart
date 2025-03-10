import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:gyde/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:provider/provider.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';

class ChooseVehicle extends StatelessWidget {
  const ChooseVehicle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChooseVehicleProvider>(context);
    final size = MediaQuery.of(context).size;

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
      body: Column(
        children: [
          SizedBox(height: size.height * 0.05),
          Text(
            provider.carTypes[provider.selectedCarIndex].title,
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
            provider.carTypes[provider.selectedCarIndex].path,
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
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(carType.path),
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
                        Text(
                          '${carType.price} USD',
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
    );
  }
}
