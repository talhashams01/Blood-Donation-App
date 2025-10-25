import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> tips = [
      {
        'title': 'Before Donation',
        'points': <String>[
          'Have a good meal at least 3 hours before donating.',
          'Drink plenty of water before and after donation.',
          'Avoid alcohol or smoking 24 hours before donating.',
          'Sleep well the night before donation.'
        ]
      },
      {
        'title': 'During Donation',
        'points': <String>[
          'Relax and take deep breaths during the process.',
          'Squeeze the stress ball gently as instructed.',
          'Inform staff immediately if you feel dizzy or uncomfortable.'
        ]
      },
      {
        'title': 'After Donation',
        'points': <String>[
          'Rest for 10–15 minutes and enjoy refreshments.',
          'Avoid heavy exercise or lifting for the rest of the day.',
          'Keep the bandage on for a few hours.',
          'If you feel dizzy, sit or lie down immediately.'
        ]
      },
      {
        'title': 'Benefits of Blood Donation',
        'points': <String>[
          'Helps save lives in emergencies and surgeries.',
          'Improves heart health by balancing iron levels.',
          'Promotes the production of new blood cells.',
          'Brings a sense of pride and community contribution.'
        ]
      },
      {
        'title': 'Eligibility & Restrictions',
        'points': <String>[
          'Donors must be 18–60 years old and healthy.',
          'Minimum weight should be at least 50 kg.',
          'Avoid donating if you have fever, cold, or infection.',
          'Wait at least 3 months between donations.'
        ]
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Blood Donation Tips', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tips.length,
          itemBuilder: (context, index) {
            final tip = tips[index];
            final String title = tip['title'] as String;
            final List<String> points = List<String>.from(tip['points'] as List);

            return Card(
              color: const Color(0xFF161616),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bloodtype, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      points.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• ", style: TextStyle(color: Colors.red, fontSize: 16)),
                            Expanded(
                              child: Text(
                                points[i],
                                style: const TextStyle(color: Colors.white70, fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}