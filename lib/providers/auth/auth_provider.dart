


import 'package:blood_donation_app_full/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';


/// Provides a single instance of AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Listens to authentication state changes from Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Holds the selected role (e.g., 'user', 'donor', or 'hospital')
final roleProvider = StateNotifierProvider<RoleNotifier, String?>(
  (ref) => RoleNotifier(),
);

class RoleNotifier extends StateNotifier<String?> {
  RoleNotifier() : super(null);

  /// Set selected role
  void setRole(String role) => state = role;

  /// Clear selected role (used on logout)
  void clearRole() => state = null;
}