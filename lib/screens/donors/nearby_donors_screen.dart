import 'package:blood_donation_app_full/screens/donors/donor_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyDonorsScreen extends StatefulWidget {
  const NearbyDonorsScreen({super.key});

  @override
  State<NearbyDonorsScreen> createState() => _NearbyDonorsScreenState();
}

class _NearbyDonorsScreenState extends State<NearbyDonorsScreen> {
  String? city;
  bool isLoading = true;
  List<Map<String, dynamic>> donors = [];

  @override
  void initState() {
    super.initState();
    fetchNearbyDonors();
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No phone number')));
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cannot make call')));
    }
  }

  
  Future<void> fetchNearbyDonors() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 1️⃣ Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        city = userDoc.data()?['city'];

        if (city != null && city!.isNotEmpty) {
          // 2️⃣ Fetch ALL donors (since Firestore queries are case-sensitive)
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'donor')
              .get();

          // 3️⃣ Filter manually in Dart (case-insensitive)
          donors = querySnapshot.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              })
              .where((donor) {
                final donorCity = (donor['city'] ?? '')
                    .toString()
                    .toLowerCase()
                    .trim();
                final userCity = city!.toLowerCase().trim();
                return donorCity == userCity;
              })
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching donors: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Donors'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donors.isEmpty
          ? Center(
              child: Text(
                city == null
                    ? 'Unable to detect your city.'
                    : 'No donors found in $city.',
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: donors.length,
              itemBuilder: (context, index) {
                final donor = donors[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DonorDetailScreen(donorId: donor['id']),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      donor['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blood Group: ${donor['bloodGroup'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'City: ${donor['city'] ?? ''}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: Colors.redAccent),
                      onPressed: () {
                        final phone = donor['phone'];
                        if (phone != null && phone.toString().isNotEmpty) {
                          // You can later implement call functionality here
                          _makePhoneCall((donor['phone'] ?? '').toString());
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
