import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_temporary/screens/saved_plan_details_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> fetchUserPlans() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final email = user.email!;
    final doc =
        await FirebaseFirestore.instance
            .collection('savedPlans')
            .doc(email)
            .get();
    return {
      'email': email,
      'plans':
          doc.exists
              ? List<Map<String, dynamic>>.from(doc.data()?['plans'] ?? [])
              : [],
    };
  }

  Future<void> deletePlan(
    String email,
    Map<String, dynamic> planToDelete,
  ) async {
    final userDoc = FirebaseFirestore.instance
        .collection('savedPlans')
        .doc(email);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) return;

    final currentPlans = List<Map<String, dynamic>>.from(
      docSnapshot.data()?['plans'] ?? [],
    );
    currentPlans.removeWhere(
      (plan) =>
          plan['routeId'] == planToDelete['routeId'] &&
          plan['createdAt'].toString() == planToDelete['createdAt'].toString(),
    );

    await userDoc.update({'plans': currentPlans});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final email = snapshot.data!['email'];
          final plans = snapshot.data!['plans'];

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logged in as: $email',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Saved Travel Plans:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child:
                      plans.isEmpty
                          ? const Center(child: Text('No saved plans found.'))
                          : ListView.builder(
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              final createdAt =
                                  (plan['createdAt'] as Timestamp).toDate();
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text('Route: ${plan['routeId']}'),
                                  subtitle: Text(
                                    'Days: ${plan['numberOfDays']} • ${createdAt.toLocal()}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await deletePlan(email, plan);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Plan deleted'),
                                        ),
                                      );
                                      (context as Element)
                                          .reassemble(); // Force rebuild
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => SavedPlanDetailsPage(
                                              plan: plan,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
