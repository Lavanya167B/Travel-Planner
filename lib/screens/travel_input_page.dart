import 'package:flutter/material.dart';
import 'travel_plan_page.dart';

class TravelInputPage extends StatefulWidget {
  @override
  _TravelInputPageState createState() => _TravelInputPageState();
}

class _TravelInputPageState extends State<TravelInputPage> {
  final TextEditingController routeController = TextEditingController();
  final TextEditingController daysController = TextEditingController();

  void searchDestination() {
    String routeName = routeController.text.trim();
    int? days = int.tryParse(daysController.text.trim());

    if (routeName.isEmpty || days == null || days <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid route and number of days"),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TravelPlanPage(
                routeId: routeName, // Pass route name as routeId
                numberOfDays: days, // Pass the number of days
                userId: '',
                routeName: '', // Add logic for userId if required
              ),
        ),
      );
    }
  }

  @override
  void dispose() {
    routeController.dispose();
    daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Your Travel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: routeController,
              decoration: InputDecoration(
                labelText: 'Enter Route (e.g., Mysore-Andhra Pradesh)',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Number of Travel Days'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: searchDestination,
              child: Text('Find Places'),
            ),
          ],
        ),
      ),
    );
  }
}
