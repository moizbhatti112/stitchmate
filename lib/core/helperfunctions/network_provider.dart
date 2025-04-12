import 'package:flutter/material.dart';
import 'package:stitchmate/core/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

// Network provider to handle connectivity status
class NetworkProvider extends ChangeNotifier {
  bool _isConnected = true;
  bool _wasConnected = true; // Track previous connection state
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool get isConnected => _isConnected;
  bool get wasConnected => _wasConnected;

  NetworkProvider() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Initialize connectivity checking
  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  // Public method to check connectivity
  Future<void> checkConnectivity() async {
    await _initConnectivity();
  }

  // Update connection status based on connectivity results
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _wasConnected = _isConnected; // Store the previous state
    
    // If any connectivity result exists other than "none", we're connected
    _isConnected = results.any((result) => result != ConnectivityResult.none);
    
    // If the list is empty or contains only "none", we're disconnected
    if (results.isEmpty || (results.length == 1 && results.first == ConnectivityResult.none)) {
      _isConnected = false;
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

// Overlay that shows a message when disconnected but preserves the current page
class NetworkAwareOverlay extends StatelessWidget {
  final Widget child;

  const NetworkAwareOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, _) {
        if (networkProvider.isConnected) {
          return child;
        } else {
          // Return a stack with the current page in the background and the network message on top
          return Stack(
            children: [
              // Keep the current page in the background (but dimmed)
              Opacity(
                opacity: 0.5,
                child: child,
              ),
              // Show the network message as an overlay
              _buildNetworkMessage(context, networkProvider),
            ],
          );
        }
      },
    );
  }

  Widget _buildNetworkMessage(BuildContext context, NetworkProvider networkProvider) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 60,
                color: grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your network settings',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  networkProvider.checkConnectivity();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text('Try Again',style: TextStyle(color: white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}