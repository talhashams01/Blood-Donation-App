

import 'package:blood_donation_app_full/providers/auth/auth_provider.dart';
import 'package:blood_donation_app_full/screens/auth/sign_in_screen.dart';
import 'package:blood_donation_app_full/screens/home/home_screen.dart';
import 'package:blood_donation_app_full/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final String? role;
  const SignupScreen({super.key, this.role});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final AuthService _auth = AuthService();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _city = TextEditingController();

  String _selectedBlood = 'A+';
  String _selectedRole = 'donor';
  DateTime? _lastDonated;
  bool _loading = false;
  bool _obscure = true;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];
  final List<String> _roles = ['donor', 'user'];

  @override
  void initState() {
    super.initState();
    if (widget.role != null && _roles.contains(widget.role)) {
      _selectedRole = widget.role!;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 90)),
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (dt != null) setState(() => _lastDonated = dt);
  }

  bool _isEmailValid(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isPasswordStrong(String password) =>
      password.length >= 6 && RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$').hasMatch(password);

  Future<void> _signUp() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.isEmpty ||
        _phone.text.trim().isEmpty ||
        _city.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!_isEmailValid(_email.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    if (!_isPasswordStrong(_password.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters and include letters & numbers')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final lastDonatedString = _lastDonated == null
          ? null
          : DateFormat('yyyy-MM-dd').format(_lastDonated!);

      final ok = await _auth.registerUser(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        bloodGroup: _selectedRole == 'donor' ? _selectedBlood : '',
        city: _city.text.trim(),
        role: _selectedRole,
        phone: _phone.text.trim(),
        lastDonated: lastDonatedString,
      );

      setState(() => _loading = false);

      if (ok) {
        ref.read(roleProvider.notifier).setRole(_selectedRole);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Account created')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Signup failed')));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _loading = false);
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already in use')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  

  Widget _buildTextField(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure && _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF2E2E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDonor = _selectedRole == 'donor';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 22),
                const Text(
                  'Create Account 🩸',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Fill details to create an account',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                _buildTextField(_name, 'Full name', Icons.person),
                const SizedBox(height: 12),
                _buildTextField(_email, 'Email', Icons.email),
                const SizedBox(height: 12),
                _buildTextField(_password, 'Password', Icons.lock, obscure: true),
                const SizedBox(height: 12),
                _buildTextField(_phone, 'Phone (with country code)', Icons.phone),
                const SizedBox(height: 12),

                // Role dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      dropdownColor: const Color(0xFF2E2E2E),
                      items: _roles
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedRole = v!),
                      isExpanded: true,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // City text field instead of dropdown
                _buildTextField(_city, 'Enter city or village', Icons.location_city),
                const SizedBox(height: 12),

                if (isDonor) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBlood,
                        dropdownColor: const Color(0xFF2E2E2E),
                        items: _bloodTypes
                            .map(
                              (b) => DropdownMenuItem(
                                value: b,
                                child: Text(
                                  b,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedBlood = v!),
                        isExpanded: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _lastDonated == null
                          ? 'Select last donation date'
                          : 'Last donated: ${DateFormat('yyyy-MM-dd').format(_lastDonated!)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _signUp,
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
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}