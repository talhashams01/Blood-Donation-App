

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorDetailScreen extends StatefulWidget {
  final String donorId;

  const DonorDetailScreen({super.key, required this.donorId});

  @override
  State<DonorDetailScreen> createState() => _DonorDetailScreenState();
}

class _DonorDetailScreenState extends State<DonorDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? donor;
  bool loading = true;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _fetchDonor();
  }

  Future<void> _fetchDonor() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.donorId)
          .get();
      if (snapshot.exists) {
        donor = snapshot.data();
      }
    } catch (e) {
      debugPrint('Error fetching donor: $e');
    }
    setState(() => loading = false);
    _controller.forward();
  }

  bool get isAvailable {
    try {
      final lastDonated = donor?['lastDonated'];
      if (lastDonated == null || lastDonated == '') return true;

      final donatedDate = DateTime.parse(lastDonated);
      final diff = DateTime.now().difference(donatedDate).inDays;
      return diff >= 30;
    } catch (_) {
      return true;
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cannot make call')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Donor Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : donor == null
              ? const Center(
                  child: Text(
                    'Donor not found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeIn,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 🔴 Profile Header
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.redAccent, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 30, horizontal: 16),
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person,
                                    size: 55, color: Colors.red),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                donor!['name'] ?? 'Unknown Donor',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                donor!['bloodGroup'] != null
                                    ? 'Blood Group: ${donor!['bloodGroup']}'
                                    : '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // 🔴 Info Card Section
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _infoRow(Icons.phone, 'Phone', donor!['phone']),
                              _infoRow(Icons.email, 'Email', donor!['email']),
                              _infoRow(Icons.location_on, 'City', donor!['city']),
                              _infoRow(Icons.calendar_today, 'Last Donated',
                                  donor!['lastDonated'] ?? 'N/A'),
                              _infoRow(
                                Icons.favorite,
                                'Available to Donate',
                                isAvailable ? 'Yes ✅' : 'No ❌',
                                color:
                                    isAvailable ? Colors.green : Colors.orange,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔴 Call Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          onPressed: () =>
                              _makePhoneCall(donor!['phone'] ?? ''),
                          icon: const Icon(Icons.phone, color: Colors.white),
                          label: const Text(
                            'Call Donor',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }


Widget _infoRow(IconData icon, String label, String? value, {Color? color}) {
  final display = (value == null || value.trim().isEmpty) ? 'N/A' : value;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.redAccent
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              SelectableText(
                display,
                style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
