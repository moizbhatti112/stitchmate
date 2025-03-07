import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gyde/core/constants/colors.dart';
import 'package:gyde/features/home/home_presentation/appbar.dart';
import 'package:gyde/features/home/home_presentation/circular_menu.dart';
import 'package:gyde/features/home/home_presentation/search_field.dart';
import 'package:gyde/features/home/my_itinerary/views/my_itinerary.dart';
import 'package:gyde/features/home/rewards/views/reward_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Track the selected index for the bottom navigation bar

  // List of navigator keys for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Handle tap events on the bottom navigation bar
  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If already on the same tab, pop to first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _navigatorKeys[_selectedIndex].currentState?.canPop() ?? false,
   onPopInvokedWithResult: (didPop, result) {
  if (!didPop && _navigatorKeys[_selectedIndex].currentState!.canPop()) {
    _navigatorKeys[_selectedIndex].currentState!.pop();
  } else if (!didPop && _selectedIndex != 0) {
    setState(() {
      _selectedIndex = 0; // Go back to Home screen
    });
  } else if (!didPop && _selectedIndex == 0) {
    // Exit the app if the user is on the Home tab
    Future.delayed(Duration(milliseconds: 100), () {
      SystemNavigator.pop();
    });
  }
},
      child: SafeArea(
        child: Scaffold(
          backgroundColor: bgColor,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildNavigator(0, const HomeContent()),
              _buildNavigator(1, const MyItinerary()),
              _buildNavigator(2, const RewardScreen()),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: bgColor,
            selectedItemColor: primaryColor,
            unselectedItemColor: lightgrey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.ticketSimple),
                label: 'My Itinerary',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.gift),
                label: 'Rewards',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a separate navigator for each tab
  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}




// Home screen content (moved to a separate widget)
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            const CustomAppBar(),
            SizedBox(height: size.height * 0.02),
            const SearchField(),
            SizedBox(height: size.height * 0.02),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularMenu(
                      child: _loadSvg('assets/icons/car.svg'),
                      onpress: () {
                        Navigator.of(context, rootNavigator: true).pushNamed('/luxurywelcome');
                      },
                    ),
                    CircularMenu(
                      child: _loadSvg('assets/icons/plane.svg'),
                      onpress: () => debugPrint('Plane Tapped'),
                    ),
                    CircularMenu(
                      child: _loadSvg('assets/icons/glass.svg'),
                      onpress: () => debugPrint('Glass Tapped'),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Luxury Ground\nTransportation'),
                    _buildLabel('Private\nJet Services'),
                    _buildLabel('Concierge\nServices'),
                  ],
                ),
                SizedBox(height: size.height * 0.02),

                // 🔹 Second Row of Circular Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircularMenu(
                      child: _loadSvg('assets/icons/calendar.svg'),
                      onpress: () => debugPrint('Calendar Tapped'),
                    ),
                    CircularMenu(
                      child: _loadSvg('assets/icons/planning.svg'),
                      onpress: () => debugPrint('Planning Tapped'),
                    ),
                    CircularMenu(
                      child: _loadSvg('assets/icons/lock.svg'),
                      onpress: () => debugPrint('Lock Tapped'),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Event\nTransportation'),
                    _buildLabel('AI Enhanced\nTravel Planning'),
                    _buildLabel('Secure Travel\nSolutions'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper method for text labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: blacktext,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ✅ SVG Loader
  Widget _loadSvg(String asset) {
    return SvgPicture.asset(
      asset,
      height: 32,
      width: 32,
    );
  }
}