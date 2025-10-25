

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _lastDonated = TextEditingController();

  String _bloodGroup = '';
  String _accountType = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔁 Load user profile from Firestore
  Future<void> _loadProfile() async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};

    setState(() {
      _name.text = data['name'] ?? '';
      _phone.text = data['phone'] ?? '';
      _city.text = data['city'] ?? '';
      _lastDonated.text = data['lastDonated'] ?? '';
      _bloodGroup = data['bloodGroup'] ?? 'N/A';
      _accountType = data['role'] ?? 'user';
      _loading = false;
    });
  }

  // date picker for last donated date
  Future<void> _pickLastDonatedDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _lastDonated.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // 💾 Save updated profile data
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await _firestore.collection('users').doc(user.uid).update({
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'city': _city.text.trim(),
      'lastDonated': _lastDonated.text.trim(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  

  // 🔄 Manual refresh
  Future<void> _refreshProfile() async {
    await _loadProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[950],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 5,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : RefreshIndicator(
                onRefresh: _refreshProfile,
                color: Colors.red,
                backgroundColor: Colors.black,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // 🧑 Profile Header Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.redAccent, Colors.deepOrangeAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.bloodtype,
                                  size: 40, color: Colors.red),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name.text.isNotEmpty
                                        ? _name.text
                                        : 'Blood Donor',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _bloodGroup,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _city.text.isNotEmpty
                                        ? _city.text
                                        : 'Unknown City',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🧾 Profile Form Card
                      Card(
                        color: Colors.black,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField('Name', _name,
                                    icon: Icons.person),
                                const SizedBox(height: 12),
                                _buildTextField('Email',
                                    TextEditingController(text: user.email),
                                    enabled: false,
                                    icon: Icons.email),
                                const SizedBox(height: 12),
                                _buildTextField('Phone', _phone,
                                    icon: Icons.phone),
                                const SizedBox(height: 12),
                                _buildTextField('City', _city,
                                    icon: Icons.location_city),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Blood Group',
                                  TextEditingController(text: _bloodGroup),
                                  enabled: false,
                                  icon: Icons.bloodtype,
                                ),
                                const SizedBox(height: 12),
                                _buildDateField(
                                    'Last Donated', _lastDonated,
                                    icon: Icons.calendar_today),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  'Account Type',
                                  TextEditingController(text: _accountType),
                                  enabled: false,
                                  icon: Icons.verified_user,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                          shadowColor: Colors.redAccent.withOpacity(0.4),
                        ),
                        child: const Text(
                          '💾 Save Changes',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // 🧱 Reusable text field widget
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, IconData? icon}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.redAccent)
            : const Icon(Icons.text_fields, color: Colors.redAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (v) =>
          (enabled && (v == null || v.isEmpty)) ? 'Required field' : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      {IconData? icon}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.redAccent) : null,
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      onTap: _pickLastDonatedDate,
    );
  }
}