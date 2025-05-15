import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/plane_transport/views/custom_datepicker.dart';
import 'package:stitchmate/features/home/plane_transport/views/time_picker.dart';

class DateTimeSelector extends StatelessWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;

  const DateTimeSelector({
    super.key,
    required this.dateController,
    required this.timeController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup time',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "HelveticaNeueMedium",
            color: black,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            Expanded(
              flex: 7, 
              child: _buildDateInput(context, 'Date', dateController),
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              flex: 4, 
              child: _buildTimeInput(context, 'Time', timeController),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInput(BuildContext context, String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => showCustomDatePicker(context, controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: circlemenusbg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please select a date";
        }
        return null;
      },
    );
  }

  Widget _buildTimeInput(BuildContext context, String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => showCustomTimePicker(context, controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: circlemenusbg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please select a time";
        }
        return null;
      },
    );
  }
}