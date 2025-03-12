import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/core/widgets/mybutton.dart';
import 'package:gyde/features/home/ground_transport/viewmodels/booking_provider.dart';
// import 'package:gyde/features/home/ground_transport/viewmodels/choosevehicle_provider.dart';
import 'package:provider/provider.dart';

class BookingConfirmation extends StatefulWidget {
  const BookingConfirmation({super.key});

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

class _BookingConfirmationState extends State<BookingConfirmation> {
  final TextEditingController _notescontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    // final vehicleprovider = Provider.of<ChooseVehicleProvider>(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/map.png', fit: BoxFit.cover),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.4,
            maxChildSize: 1.0,
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
                        'Booking Confirmation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "PP Neue Montreal",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: circlemenusbg,
                              border: Border.all(color: nextbg),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              " ${bookingProvider.date}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "HelveticaNeueMedium",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: circlemenusbg,
                              border: Border.all(color: nextbg),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              " ${bookingProvider.time}",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: "HelveticaNeueMedium",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.015),
                      Text(
                        "Estimated route: 2 Hours| 40 km",
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: "HelveticaNeueMedium",
                          fontWeight: FontWeight.w500,
                          color: grey,
                        ),
                      ),

                      SizedBox(height: size.height * 0.015),
                      Container(
                        height: size.height * 0.12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: phonefieldColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/point_a.svg',
                                    height:
                                        size.height *
                                        0.025, // Responsive height
                                    width: size.width * 0.05,
                                  ),
                                  SizedBox(width: size.width * 0.05),
                                  Expanded(
                                    child: Text(
                                      "${bookingProvider.pickupLocation}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "HelveticaNeueMedium",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis, // Show "..." if overflow
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Container(
                                  width: size.width * 0.006,
                                  height: size.height * 0.04,
                                  color: Colors.black, // Vertical Line
                                ),
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/pointb.svg',
                                    height:
                                        size.height *
                                        0.025, // Responsive height
                                    width: size.width * 0.05,
                                  ),
                                  SizedBox(width: size.width * 0.05),
                                  Expanded(
                                    child: Text(
                                      "${bookingProvider.dropoffLocation}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "HelveticaNeueMedium",
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Chauffeur (1/1)',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: "PPNeueMontreal",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.arrow_back_ios, size: 16),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(200),
                            child: Image.asset(
                              'assets/images/avtarc.png',
                              height: size.height * 0.05,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      Divider(),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        children: [
                          Container(
                            width: size.width * 0.12,
                            height: size.height * 0.05,
                            decoration: BoxDecoration(
                              color: circlemenusbg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: circlemenusborder),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/icons/wallet.svg',
                              ),
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Price 162",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "HelveticaNeueMedium",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Credit or Debit Card",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "HelveticaNeueMedium",
                                  fontWeight: FontWeight.w400,
                                  color: grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      TextField(
                        controller: _notescontroller,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              'assets/icons/notes.svg',
                              width: 15,
                              height: 15,
                            ),
                          ),
                          hintText: "Add notes for chauffeur (optional)",
                          hintStyle: TextStyle(color: phonefieldtext),
                          filled: true,
                          fillColor: phonefieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                        SizedBox(height: size.height * 0.02),
                      Divider(),
                        SizedBox(height: size.height * 0.02),
                      MyButton(text: "Confirm Order", onPressed: (){})
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
}
