
import 'package:blood_donation_app_full/providers/auth/auth_provider.dart';
import 'package:blood_donation_app_full/screens/auth/sign_up_screen.dart';
import 'package:blood_donation_app_full/screens/home/home_screen.dart';
import 'package:blood_donation_app_full/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  final AuthService _auth = AuthService();

  
Future<void> _login() async {
  if (_email.text.trim().isEmpty || _password.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email & password')));
    return;
  }

  setState(() => _loading = true);

  try {
    // 1) Attempt login via AuthService
    final ok = await _auth.loginUser(_email.text.trim(), _password.text);
    if (!ok) throw Exception('Invalid credentials or login failed');

    // 2) Wait a short moment for Firebase Auth to update currentUser
    await Future.delayed(const Duration(milliseconds: 300));

    // 3) Ensure currentUser exists
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Auth succeeded but currentUser is null');

    // 4) Verify that users/{uid} document exists in Firestore (retry a few times)
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot<Map<String, dynamic>>? doc;
    var tries = 0;
    while (tries < 6) {
      doc = await docRef.get();
      if (doc.exists) break;
      await Future.delayed(const Duration(milliseconds: 300));
      tries++;
    }
    if (doc == null || !doc.exists) {
      throw Exception('User profile not found in Firestore. Please contact support.');
    }

    // 5) Set role in provider so Home shows correct dashboard
    final roleValue = (doc.data()?['role'] as String?) ?? 'user';
    ref.read(roleProvider.notifier).setRole(roleValue);

    // 6) Navigate to Home and clear back stack
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  } catch (e, st) {
    debugPrint('Login error: $e\n$st');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // full modern dark screen
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'Welcome Back 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to your account',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                // email
                TextField(
                  controller: _email,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2E2E2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // password
                TextField(
                  controller: _password,
                  obscureText: _obscure,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2E2E2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignupScreen(
                          role: ref.read(roleProvider) ?? 'donor',
                        ),
                      ),
                    ),
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
