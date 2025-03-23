import 'package:flutter/material.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:gyde/features/home/ground_transport/views/location_input.dart';
import 'package:provider/provider.dart';

class HourlyForm extends StatefulWidget {
  final VoidCallback onFormFieldTap;
  
  const HourlyForm({super.key, required this.onFormFieldTap});

  @override
  State<HourlyForm> createState() => _HourlyFormState();
}

class _HourlyFormState extends State<HourlyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pickupLocationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          SizedBox(height: size.height * 0.015),
          LocationInput(
            controller: _pickupLocationController,
            hintText: 'Pickup location',
            iconPath: 'assets/icons/pickup.svg',
            onTap: widget.onFormFieldTap,
            isDropoff: false,
          ),
        
          SizedBox(height: size.height * 0.03),
          Text(
            'Duration',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
              color: black,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          _buildDurationSelector(),
          SizedBox(height: size.height * 0.06),
          Divider(color: grey),
          SizedBox(height: size.height * 0.02),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return TextFormField(
      controller: _durationController,
      decoration: InputDecoration(
        hintText: 'Enter duration (hours)',
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: phonefieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter duration";
        }
        try {
          final hours = int.parse(value);
          if (hours <= 0) {
            return "Duration must be greater than 0";
          }
        } catch (e) {
          return "Please enter a valid number";
        }
        return null;
      },
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
            final bookingProvider = Provider.of<BookingProvider>(
              context,
              listen: false,
            );

            bookingProvider.setPickupLocation(_pickupLocationController.text);
            bookingProvider.setDate(_dateController.text);
            bookingProvider.setTime(_timeController.text);
            bookingProvider.setDuration(_durationController.text);

            Navigator.pushNamed(context, '/choosevehicle');
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