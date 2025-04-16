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
import 'package:stitchmate/features/profile/viewmodels/profile_image_notifier.dart';
import 'package:stitchmate/features/profile/views/profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _refreshAppBar = false;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  
  final Map<String, Widget> _svgCache = {};
  
  // Use the global image change notifier
  final _imageChangeNotifier = ProfileImageChangeNotifier();

  @override
  void initState() {
    super.initState();
    _precacheAssets();
    
    // Listen for profile image changes
    _imageChangeNotifier.lastUpdated.addListener(_onProfileImageChanged);
  }
  
  @override
  void dispose() {
    _imageChangeNotifier.lastUpdated.removeListener(_onProfileImageChanged);
    super.dispose();
  }
  
void _onProfileImageChanged() {
  // Check if the widget is still mounted before scheduling setState
  if (mounted) {
    // Use post-frame callback to ensure we're not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Double-check that the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _refreshAppBar = !_refreshAppBar;
        });
      }
    });
  }
}
  Future<void> _precacheAssets() async {
    final BuildContext currentContext = context;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _cacheSvgAssets([
        'assets/icons/car.svg',
        'assets/icons/plane.svg',
        'assets/icons/glass.svg',
        'assets/icons/calendar.svg',
        'assets/icons/planning.svg',
        'assets/icons/lock.svg',
      ]);

      if (mounted) {
        await _precacheImages(currentContext);
      }
    });
  }

  Future<void> _precacheImages(BuildContext currentContext) async {
    final imagesToPreload = [
      'assets/images/carimage.png',
      'assets/icons/apple.png',
      'assets/icons/google.png',
      'assets/icons/fb.png',
    ];

    for (final asset in imagesToPreload) {
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

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

 void _handleLogout() async {
  if (!mounted) return;
  
  // Store scaffoldMessenger before potentially losing context
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  // Close the drawer
  Navigator.pop(context);

  if (!mounted) return;

  // Store the context for the dialog
  final BuildContext dialogContext = context;
  
  // Show loading dialog
  showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Use Provider without listening
    final authProvider = Provider.of<AuthProvider>(dialogContext, listen: false);
    await authProvider.signOut();

    // Check if context is still valid
    if (!mounted) return;
    
    // Close loading dialog
    if(context.mounted)
    {
      Navigator.of(dialogContext).pop();
    }

    // Navigate to login screen using microtask to avoid build issues
    Future.microtask(() {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  } catch (e) {
    // Handle error, making sure the widget is still mounted
    if (mounted) {
      // Try to close the dialog if it's still showing
      try {
         if(context.mounted)
    {
      Navigator.of(dialogContext).pop();
    }
      } catch (dialogError) {
        // Dialog might already be closed, ignore this error
      }
      
      // Show error message
      scaffoldMessenger.showSnackBar(
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
            _selectedIndex = 0;
          });
        } else if (!didPop && _selectedIndex == 0) {
          Future.delayed(Duration(milliseconds: 100), () {
            SystemNavigator.pop();
          });
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: bgColor,
          drawer: _buildDrawer(),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildNavigator(0, HomeContent(refreshAppBar: _refreshAppBar)),
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

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }

  Widget _buildDrawer() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userEmail = user?.email ?? '';

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
              userEmail,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            currentAccountPicture: _buildDrawerProfilePicture(),
          ),
          _buildDrawerItem(Icons.person, 'Profile', _navigateToProfile),
          _buildDrawerItem(Icons.settings, 'Settings', () => Navigator.pushNamed(context, '/settings')),
          _buildDrawerItem(Icons.history, 'Trip History', () => Navigator.pushNamed(context, '/trip-history')),
          _buildDrawerItem(Icons.payment, 'Payment Methods', () => Navigator.pushNamed(context, '/payment-methods')),
          _buildDrawerItem(Icons.support_agent, 'Support', () => Navigator.pushNamed(context, '/support')),
          Divider(color: lightgrey),
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
  
Widget _buildDrawerProfilePicture() {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? 'unknown';
    
    // Use ValueListenableBuilder to rebuild when image changes
    return ValueListenableBuilder<DateTime>(
      valueListenable: _imageChangeNotifier.lastUpdated,
      builder: (context, lastUpdated, child) {
        final profileUrl = _imageChangeNotifier.getImageUrl(userId);
        
        if (profileUrl != null && profileUrl.isNotEmpty) {
          return CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
              // Add timestamp parameter to prevent caching issues
              '$profileUrl?t=${DateTime.now().millisecondsSinceEpoch}',
            ),
            onBackgroundImageError: (exception, stackTrace) {
              debugPrint('Error loading profile image in drawer: $exception');
            },
          );
        } else {
          return CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: primaryColor,
              size: 40,
            ),
          );
        }
      },
    );
  }
  
  void _navigateToProfile() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ProfileScreen(fromDrawer: true),
      ),
    ).then((_) {
      // No need to do anything here - the notifier will handle the update
    });
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTapAction,
  ) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: TextStyle(fontSize: 16, color: blacktext)),
      onTap: () {
        Navigator.pop(context);
        onTapAction();
      },
    );
  }
}

class HomeContent extends StatelessWidget {
  final bool refreshAppBar;
  
  const HomeContent({super.key, this.refreshAppBar = false});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          children: [
            CustomAppBar(forceRefresh: refreshAppBar),
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

  Widget _loadSvg(String asset) {
    return SvgPicture.asset(asset, height: 32, width: 32);
  }
}