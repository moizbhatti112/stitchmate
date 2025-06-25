import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:stitchmate/core/services/notification_service.dart';
import 'package:stitchmate/features/admin_panel/views/add_car.dart';
import 'package:stitchmate/features/admin_panel/views/add_plane.dart';
import 'package:stitchmate/features/authentication/viewmodels/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isLoading = false;
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _notificationService.getNotifications().listen((notifications) {
      setState(() {
        _notifications = notifications;
        _hasUnreadNotifications = notifications.any((n) => !n['is_read']);
      });
    });
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>;
    final isRead = notification['is_read'] as bool;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: isRead ? Colors.white : Colors.blue[50],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: const Icon(Icons.notifications, color: Colors.white),
        ),
        title: Text(
          notification['title'] as String,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${data['user_email']}'),
            Text('Pickup: ${data['pickup_location']}'),
            Text('Dropoff: ${data['dropoff_location']}'),
            Text('Time: ${data['time']}'),
            Text('Date: ${data['date']}'),
          ],
        ),
        trailing:
            !isRead
                ? IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {
                    _notificationService.markNotificationAsRead(
                      notification['id'],
                    );
                  },
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  // Mark all notifications as read when opening the panel
                  for (var notification in _notifications) {
                    if (!notification['is_read']) {
                      await _notificationService.markNotificationAsRead(
                        notification['id'],
                      );
                    }
                  }

                  // Update the unread notifications state
                  setState(() {
                    _hasUnreadNotifications = false;
                  });

                  // Show notifications in a bottom sheet
                  if (context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (context) => Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child:
                                      _notifications.isEmpty
                                          ? const Center(
                                            child: Text('No notifications'),
                                          )
                                          : ListView.builder(
                                            itemCount: _notifications.length,
                                            itemBuilder:
                                                (context, index) =>
                                                    _buildNotificationItem(
                                                      _notifications[index],
                                                    ),
                                          ),
                                ),
                              ],
                            ),
                          ),
                    );
                  }
                },
              ),
              if (_hasUnreadNotifications)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: const Text(
                      '!',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _isLoading ? null : _handleLogout,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Text(
                    //   'Admin Dashboard',
                    //   style: TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 24),

                    // Admin Stats Cards
                    // _buildStatsCard('Total Users', '120', Icons.people),
                    // _buildStatsCard('New Users (Today)', '8', Icons.person_add),
                    // _buildStatsCard(
                    //   'Active Sessions',
                    //   '45',
                    //   Icons.online_prediction,
                    // ),

                    const SizedBox(height: 32),

                    // Admin Action Buttons
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // _buildActionButton(
                        //   'Manage Users',
                        //   Icons.manage_accounts,
                        //   () {
                        //     // Navigate to user management screen
                        //   },
                        // ),
                        _buildActionButton(
                          'Add Cars',
                          Icons.directions_car,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddCarScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionButton('Add Planes', Icons.flight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPlane(),
                            ),
                          );
                        }),
                      ],
                    ),

                    // const SizedBox(height: 32),

                    // // Recent Activity List
                    // const Text(
                    //   'Recent Activity',
                    //   style: TextStyle(
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 16),

                    // _buildActivityItem(
                    //   'New user registered',
                    //   'john.doe@example.com',
                    //   '10 minutes ago',
                    // ),
                    // _buildActivityItem(
                    //   'Password reset requested',
                    //   'sara.smith@example.com',
                    //   '1 hour ago',
                    // ),
                    // _buildActivityItem(
                    //   'Profile updated',
                    //   'mike.brown@example.com',
                    //   '3 hours ago',
                    // ),
                  ],
                ),
              ),
    );
  }

  // Widget _buildStatsCard(String title, String value, IconData icon) {
  //   return Card(
  //     elevation: 4,
  //     margin: const EdgeInsets.only(bottom: 16),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Row(
  //         children: [
  //           Icon(icon, size: 40, color: primaryColor),
  //           const SizedBox(width: 16),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               Text(
  //                 value,
  //                 style: const TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Widget _buildActivityItem(String action, String user, String time) {
  //   return ListTile(
  //     leading: const CircleAvatar(
  //       backgroundColor: primaryColor,
  //       child: Icon(Icons.person, color: Colors.white),
  //     ),
  //     title: Text(action),
  //     subtitle: Text(user),
  //     trailing: Text(
  //       time,
  //       style: const TextStyle(color: Colors.grey, fontSize: 12),
  //     ),
  //   );
  // }
}
