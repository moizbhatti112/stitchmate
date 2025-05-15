import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/plane_transport/viewmodels/booking_provider.dart';
import 'package:stitchmate/features/home/plane_transport/views/location_input.dart';
import 'package:stitchmate/features/home/plane_transport/views/date_time_selector.dart';
import 'package:provider/provider.dart';

class OneWayForm extends StatefulWidget {
  final VoidCallback onFormFieldTap;
  final Function(LatLng)? onPickupLocationSelected;
   final Function(LatLng)? onDropoffLocationSelected;
  const OneWayForm({
    super.key, 
    required this.onFormFieldTap, 
    this.onPickupLocationSelected,
    this.onDropoffLocationSelected
  });

  @override
  State<OneWayForm> createState() => _OneWayFormState();
}

class _OneWayFormState extends State<OneWayForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dropoffLocationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   final size = MediaQuery.of(context).size;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Departure',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: "HelveticaNeueMedium",
                color: black,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            LocationInput(
              controller: _pickupLocationController,
              hintText: 'Departure location',
              iconPath: 'assets/icons/depart.svg',
              onTap: widget.onFormFieldTap,
              isDropoff: false,
              onLocationSelected: widget.onPickupLocationSelected,
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              'Arrival',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: "HelveticaNeueMedium",
                color: black,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            LocationInput(
              controller: _dropoffLocationController,
              hintText: 'Arrival location',
              iconPath: 'assets/icons/arrival.svg',
              onTap: widget.onFormFieldTap,
              isDropoff: true,
              onLocationSelected: widget.onDropoffLocationSelected,
            ),
            SizedBox(height: size.height * 0.03),
            DateTimeSelector(
              dateController: _dateController,
              timeController: _timeController,
            ),
            SizedBox(height: size.height * 0.02),
            Divider(color: grey),
            SizedBox(height: size.height * 0.02),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final size = MediaQuery.of(context).size;
    
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            final bookingProvider = Provider.of<PlaneBookingProvider>(
              context,
              listen: false,
            );

            bookingProvider.setPickupLocation(_pickupLocationController.text);
            bookingProvider.setDropoffLocation(_dropoffLocationController.text);
            bookingProvider.setDate(_dateController.text);
            bookingProvider.setTime(_timeController.text);

            Navigator.pushNamed(context, '/chooseplane');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(color: bgColor, fontSize: 16),
        ),
      ),
    );
  }
}