import 'package:flutter/material.dart';

class SavedPlanDetailsPage extends StatelessWidget {
  final Map<String, dynamic> plan;

  const SavedPlanDetailsPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> days = plan['plan'];

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Details')),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day['day'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('City: ${day['city']}'),
                  const SizedBox(height: 6),
                  if (day.containsKey('message'))
                    Text(
                      day['message'],
                      style: const TextStyle(color: Colors.red),
                    )
                  else
                    ...['Morning', 'Afternoon', 'Evening'].map((slot) {
                      final places = List<String>.from(
                        day['schedule'][slot] ?? [],
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$slot:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...places.map((place) => Text('- $place')).toList(),
                          const SizedBox(height: 4),
                        ],
                      );
                    }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
