import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Check if email already exists in users table
  Future<bool> isEmailRegistered(String email) async {
    try {
      final userRecord = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();
      
      return userRecord != null;
    } catch (e) {
      debugPrint('Error checking if email is registered: $e');
      // Return false on error to allow the signup flow to continue
      // The auth registration will still catch duplicates
      return false;
    }
  }

  // Improved signUpWithEmail method with additional check against users table
  Future<String?> signUpWithEmail({required String email, required String password}) async {
    try {
      // First check if the email exists in the users table
      final bool emailExists = await isEmailRegistered(email);
      if (emailExists) {
        return 'email_already_registered';
      }

      // Proceed with signup if email not found in users table
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
      );

      if (response.user != null && response.user!.emailConfirmedAt == null) {
        return 'verification_needed';
      } else if (response.user != null) {
        return 'success';
      } else {
        return 'unknown_error';
      }
    } on AuthException catch (e) {
      // Handle the error case where email already exists
      // Supabase will return a specific error message for this case
      final errorMessage = e.message.toLowerCase();
      
      if (errorMessage.contains('email already') || 
          errorMessage.contains('already registered') || 
          errorMessage.contains('already in use') ||
          errorMessage.contains('already exists')) {
        return 'email_already_registered';
      }
      
      // Return other auth errors directly
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Verify email with OTP code and create user record in database
  Future<String?> verifyOTP({required String email, required String otp}) async {
    try {
      final AuthResponse response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );
      
      if (response.user != null) {
        // Create initial user record in the users table
        try {
          await _createUserRecord(email);
          return 'success';
        } catch (e) {
          return 'User authenticated but failed to create profile: ${e.toString()}';
        }
      } else {
        return 'verification_failed';
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
  
  // Create initial user record with empty profile fields
  Future<void> _createUserRecord(String email) async {
    // First check if the user already exists to avoid duplicates
    final userExists = await _supabase
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();
    
    if (userExists == null) {
      // Create new user record with empty profile fields
      await _supabase.from('users').insert({
        'email': email,
        'f_name': '',
        'l_name': '',
        'company': '',
        'imageurl': '',
      });
    }
  }
  
  // Update user profile
  Future<String?> updateUserProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String company,
    required String imageUrl,
  }) async {
    try {
      await _supabase.from('users').update({
        'f_name': firstName,
        'l_name': lastName,
        'company': company,
        'imageurl': imageUrl, 
      }).eq('email', email);
      
      return 'success';
    } catch (e) {
      return 'Failed to update profile: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmail({required String email, required String password}) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        return 'success';
      } else {
        return 'login_failed';
      }
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _supabase.auth.currentUser != null;

  // Get user session
  Session? get currentSession => _supabase.auth.currentSession;
}