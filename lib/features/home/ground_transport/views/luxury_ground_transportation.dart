import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/booking_provider.dart';
import 'package:gyde/features/home/ground_transport/views/custom_datepicker.dart';
import 'package:gyde/features/home/ground_transport/views/time_picker.dart';
import 'package:provider/provider.dart';

class LuxuryGroundTransportation extends StatefulWidget {
  const LuxuryGroundTransportation({super.key});

  @override
  State<LuxuryGroundTransportation> createState() =>
      _LuxuryGroundTransportationState();
}

class _LuxuryGroundTransportationState extends State<LuxuryGroundTransportation>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  final TextEditingController _pickupLocationController =
      TextEditingController();
  final TextEditingController _dropoffLocationController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/map.png', fit: BoxFit.cover),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book a ride',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "PP Neue Montreal",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      _buildTabSelector(),
                      SizedBox(height: size.height * 0.02),
                      SizedBox(
                        height: size.height * 1,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildOneWayRideForm(),
                            _buildByTheHourRideForm(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return TabBar(
      controller: _tabController,
      indicatorColor: primaryColor,
      labelColor: primaryColor,
      unselectedLabelColor: lightgrey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.3, color: primaryColor),
        insets: EdgeInsets.symmetric(horizontal: 135),
      ),
      tabs: const [
        Tab(
          child: Text(
            'One Way',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
            ),
          ),
        ),
        Tab(
          child: Text(
            'By the hour',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "HelveticaNeueMedium",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOneWayRideForm() {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "HelveticaNeueMedium",
            color: black,
          ),
        ),
        SizedBox(height: size.height * 0.015),

        _buildpickupLocationInput('Pickup location'),
        SizedBox(height: size.height * 0.015),
        Text(
          'Drop-off',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: "HelveticaNeueMedium",
            color: black,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        _builddropoffLocationInput('Drop-off location'),
        SizedBox(height: size.height * 0.03),

        _buildPickupTimeSelector(),

        SizedBox(height: size.height * 0.06),
        //Divider
        Divider(color: grey),
        SizedBox(height: size.height * 0.02),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildByTheHourRideForm() {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildpickupLocationInput('Pickup location'),
        SizedBox(height: size.height * 0.015),
        _buildDurationSelector(),
        SizedBox(height: size.height * 0.015),
        SizedBox(height: size.height * 0.06),
        Divider(color: grey),
        SizedBox(height: size.height * 0.02),
        _buildContinueButtonForHour(),
      ],
    );
  }

  Widget _buildpickupLocationInput(String hintText) {
    return TextField(
      controller: _pickupLocationController,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/icons/pickup.svg',
            width: 20,
            height: 20,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: phonefieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _builddropoffLocationInput(String hintText) {
    return TextField(
      controller: _dropoffLocationController,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SvgPicture.asset(
            'assets/icons/drop_off.svg',
            width: 20,
            height: 20,
          ),
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: phonefieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPickupTimeSelector() {
    final size = MediaQuery.sizeOf(context);
    return Row(
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
        Spacer(),
        Expanded(flex: 7, child: _builddate('Date', _dateController, context)),
        SizedBox(width: size.width * 0.02),
        Expanded(flex: 4, child: _buildtime('Time', _timeController, context)),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return TextFormField(
      key: _formKey,
      controller: _durationController,
      decoration: InputDecoration(
        hintText: 'Enter duration (hours)',
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
          return "Please select duration";
        }
        return null;
      },
    );
  }

  Widget _buildContinueButton() {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          if (_pickupLocationController.text.trim().isNotEmpty &&
              _dropoffLocationController.text.trim().isNotEmpty &&
              _dateController.text.trim().isNotEmpty &&
              _timeController.text.trim().isNotEmpty) {
            final bookingProvider = Provider.of<BookingProvider>(
              context,
              listen: false,
            );

            bookingProvider.setPickupLocation(_pickupLocationController.text);
            bookingProvider.setDropoffLocation(_dropoffLocationController.text);
            bookingProvider.setDate(_dateController.text);
            bookingProvider.setTime(_timeController.text);
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

  Widget _buildContinueButtonForHour() {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          if (_pickupLocationController.text.trim().isNotEmpty &&
              _durationController.text.trim().isNotEmpty) {
            final bookingProvider = Provider.of<BookingProvider>(
              context,
              listen: false,
            );

            bookingProvider.setPickupLocation(_pickupLocationController.text);
            bookingProvider.setDropoffLocation(_dropoffLocationController.text);
            bookingProvider.setDate(_dateController.text);
            bookingProvider.setTime(_timeController.text);

            Navigator.pushNamed(context, '/choosevehicle');
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

  Widget _builddate(
    String hint,
    TextEditingController controller,
    BuildContext context,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () {
        showCustomDatePicker(context, controller);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: circlemenusbg,
        // suffixIcon: Icon(Icons.calendar_today, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2.5),
        ),
      ),
    );
  }

  Widget _buildtime(
    String hint,
    TextEditingController controller,
    BuildContext context,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () {
        showCustomTimePicker(context, controller);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: phonefieldtext),
        filled: true,
        fillColor: circlemenusbg,
        // suffixIcon: Icon(Icons.access_time, color: primaryColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: circlemenusborder, width: 2.5),
        ),
      ),
    );
  }
}
