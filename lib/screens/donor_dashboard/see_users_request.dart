

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UsersRequestsScreen extends StatefulWidget {
  const UsersRequestsScreen({super.key});

  @override
  State<UsersRequestsScreen> createState() => _UsersRequestsScreenState();
}

class _UsersRequestsScreenState extends State<UsersRequestsScreen> {
  late final Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    _requestsStream = FirebaseFirestore.instance
        .collection('blood_requests')
        .orderBy('createdAt', descending: true)
        .snapshots(); // All users' requests
  }

    Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No phone number')));
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cannot make call')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Blood Requests'),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.red));
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No blood requests found',
                    style: TextStyle(color: Colors.white70)),
              );
            }

            final requests = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final doc = requests[index];
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'pending';
                final createdAt = data['createdAt'] != null
                    ? (data['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                final formattedDate =
                    DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

                return Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red[600],
                              child: Text(
                                (data['bloodGroup'] ?? '?'),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                data['patientName'] ?? 'Unknown Patient',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Icon(
                              status == 'done'
                                  ? Icons.check_circle
                                  : Icons.pending_actions,
                              color: status == 'done' ? Colors.green : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('🏥 Hospital: ${data['hospital'] ?? 'N/A'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        Text('📍 City: ${data['city'] ?? 'N/A'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                                 Text('📞 Phone: ${data['phone'] ?? 'N/A'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        Text('💉 Units: ${data['units'] ?? 'N/A'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        Text('🕒 Needed At: ${data['neededAt'] ?? 'N/A'}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                       
                        const SizedBox(height: 10),
                        Text('📅 Requested On: $formattedDate',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerRight,
                          child: ElevatedButton(onPressed: (){
                            _makePhoneCall(
                                          (data['phone'] ?? '').toString());
                          }, child: Text('Call',style: TextStyle(fontSize: 16,color: Colors.white),),
                           style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}