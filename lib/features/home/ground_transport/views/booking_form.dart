import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/home/ground_transport/views/one_way_form.dart';
import 'package:stitchmate/features/home/ground_transport/views/hourly_form.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BookingForm extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onFormFieldTap;
  final Function(LatLng)? onPickupLocationSelected;
   final Function(LatLng)? onDropoffLocationSelected;
  const BookingForm({
    super.key, 
    required this.scrollController, 
    required this.onFormFieldTap,
    this.onPickupLocationSelected,
    this.onDropoffLocationSelected
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: widget.scrollController,
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
              const SizedBox(height: 16),
              _buildTabSelector(),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OneWayForm(
                      onFormFieldTap: widget.onFormFieldTap,
                      onPickupLocationSelected: widget.onPickupLocationSelected,
                      onDropoffLocationSelected: widget.onDropoffLocationSelected,
                    ),
                    HourlyForm(
                      onFormFieldTap: widget.onFormFieldTap,
                      onPickupLocationSelected: widget.onPickupLocationSelected,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return TabBar(
      controller: _tabController,
      indicatorColor: primaryColor,
      labelColor: primaryColor,
      unselectedLabelColor: lightgrey,
      indicator: const UnderlineTabIndicator(
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
}