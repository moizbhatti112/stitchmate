import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/features/ai_planner/views/ai_welcome.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';
import 'package:stitchmate/features/home/home_presentation/appbar.dart';
import 'package:stitchmate/features/home/home_presentation/circular_menu.dart';
import 'package:stitchmate/features/home/home_presentation/search_field.dart';
import 'package:stitchmate/features/home/my_itinerary/views/my_itinerary.dart';
import 'package:stitchmate/features/home/rewards/views/reward_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex =
      0; // Track the selected index for the bottom navigation bar

  // List of navigator keys for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  // Cache SVG assets
  final Map<String, Widget> _svgCache = {};

  @override
  void initState() {
    super.initState();
    _precacheAssets();
  }

  Future<void> _precacheAssets() async {
    // Use a local variable to reference the current context
    final BuildContext currentContext = context;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Precache SVG icons - this is synchronous so no mounted check needed here
      _cacheSvgAssets([
        'assets/icons/car.svg',
        'assets/icons/plane.svg',
        'assets/icons/glass.svg',
        'assets/icons/calendar.svg',
        'assets/icons/planning.svg',
        'assets/icons/lock.svg',
      ]);

      // For the asynchronous precaching, check if still mounted
      if (mounted) {
        await _precacheImages(currentContext);
      }
    });
  }

  // Modified to accept context as a parameter
  Future<void> _precacheImages(BuildContext currentContext) async {
    final imagesToPreload = [
      'assets/images/carimage.png',
      'assets/icons/apple.png',
      'assets/icons/google.png',
      'assets/icons/fb.png',
    ];

    for (final asset in imagesToPreload) {
      // Check if still mounted before each operation
      if (!mounted) return;
      await precacheImage(AssetImage(asset), currentContext);
    }
  }

  void _cacheSvgAssets(List<String> assets) {
    for (final asset in assets) {
      if (!_svgCache.containsKey(asset)) {
        _svgCache[asset] = SvgPicture.asset(asset, height: 32, width: 32);
      }
    }
  }

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

  // Handle logout functionality
  // In home_screen.dart, update the _handleLogout method:

  void _handleLogout() async {
    final sm = ScaffoldMessenger.of(context);
    // Close the drawer first
    Navigator.pop(context);

    // Show loading indicator
    final BuildContext dialogContext = context;
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder:
          (BuildContext context) =>
              const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Sign out
      await authProvider.signOut();

      // Make sure we dismiss the dialog before navigation
      if (context.mounted) {
        // Pop the loading dialog first
        Navigator.of(dialogContext).pop();

        // Then navigate to login screen after ensuring the dialog is closed
        Future.microtask(() {
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        });
      }
    } catch (e) {
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(dialogContext).pop();

        // Show error message
        sm.showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
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
          // Add drawer to the scaffold
          drawer: _buildDrawer(),
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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

  // Create the drawer widget

  // Updated _buildDrawer method
  Widget _buildDrawer() {
    // Get user info from AuthProvider
    Provider.of<AuthProvider>(context, listen: false);

    // Get user name from Supabase user metadata
    // final userName = user?.userMetadata?['name'] ?? user?.email?.split('@').first ?? 'User';

    return Drawer(
      backgroundColor: bgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            accountName: Text(
              '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              '',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          _buildDrawerItem(Icons.person, 'Profile',() => Navigator.pushNamed(context, '/profilescreen')),
          _buildDrawerItem(Icons.settings, 'Settings',() => Navigator.pushNamed(context, '/profile')),
          _buildDrawerItem(Icons.history, 'Trip History',() => Navigator.pushNamed(context, '/profile')),
          _buildDrawerItem(Icons.payment, 'Payment Methods',() => Navigator.pushNamed(context, '/profile')),
          _buildDrawerItem(Icons.support_agent, 'Support',() => Navigator.pushNamed(context, '/profile')),
          Divider(color: lightgrey),
          // Use _handleLogout for the Logout option
          ListTile(
            leading: Icon(Icons.logout, color: primaryColor),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 16, color: blacktext),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // Helper method to create drawer items
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTapAction,
  ) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: TextStyle(fontSize: 16, color: blacktext)),
      onTap: () {
        // Close the drawer
        Navigator.pop(context);

        onTapAction();
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
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/luxurywelcome');
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
                      onpress: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (context) => AiWelcome()),
                        );
                      },
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
    return SvgPicture.asset(asset, height: 32, width: 32);
  }
}
