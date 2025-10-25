
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RequestsListScreen extends StatefulWidget {
  const RequestsListScreen({super.key});

  @override
  State<RequestsListScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsListScreen> {
  late final Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _requestsStream = FirebaseFirestore.instance
          .collection('blood_requests')
          .where('userId', isEqualTo: user.uid) // ✅ Only show logged-in user's requests
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _requestsStream = const Stream.empty();
    }
  }

  Future<void> _markAsDone(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Done'),
        content: const Text('Are you sure this blood request is fulfilled?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Done'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('blood_requests')
          .doc(docId)
          .update({'status': 'done'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Blood Requests'),
        backgroundColor: Colors.grey[900],
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _requestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No blood requests found', style: TextStyle(color: Colors.white70)),
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
                final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

                return Card(
                  color: Colors.grey[850],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              status == 'done' ? Icons.check_circle : Icons.pending_actions,
                              color: status == 'done' ? Colors.green : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('🏥 Hospital: ${data['hospital'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('📍 City: ${data['city'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                             Text('📞 Phone: ${data['phone'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('💉 Units: ${data['units'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('🕒 Needed At: ${data['neededAt'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 10),
                        Text('📅 Requested On: $formattedDate',
                            style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        const SizedBox(height: 10),
                        if (status != 'done')
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () => _markAsDone(doc.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text('Mark as Done', style: TextStyle(color: Colors.white)),
                            ),
                          ),
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