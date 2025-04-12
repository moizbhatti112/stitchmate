import 'package:flutter/material.dart';
import 'package:stitchmate/features/authentication/auth_service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  AuthProvider() {
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _user = _authService.currentUser;
    
    _isLoading = false;
    notifyListeners();
    
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
        _user = session?.user;
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
      }
      
      notifyListeners();
    });
  }

  Future<String?> signUpWithEmail({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<String?> verifyOTP({required String email, required String otp}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _authService.verifyOTP(
        email: email,
        otp: otp,
      );
      
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // New method to update user profile
  Future<String?> updateUserProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String company,
    required String imageUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final result = await _authService.updateUserProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
        company: company,
        imageUrl: imageUrl,
      );
      
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}