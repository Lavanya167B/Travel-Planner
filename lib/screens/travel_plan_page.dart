import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPlanPage extends StatefulWidget {
  final String routeId;
  final int numberOfDays;
  final String userId;

  const TravelPlanPage({
    super.key,
    required this.routeId,
    required this.numberOfDays,
    required this.userId,
    required String routeName,
  });

  @override
  State<TravelPlanPage> createState() => _TravelPlanPageState();
}

class _TravelPlanPageState extends State<TravelPlanPage> {
  List<List<Map<String, dynamic>>> multiplePlans = [];
  bool isLoading = true;

  get travelPlan => null;

  @override
  void initState() {
    super.initState();
    fetchTravelPlans();
  }

  Future<void> fetchTravelPlans() async {
    try {
      final routeSnapshot =
          await FirebaseFirestore.instance
              .collection('routes')
              .doc(widget.routeId)
              .get();

      if (!routeSnapshot.exists) {
        throw Exception('Route not found');
      }

      List<String> cities = List<String>.from(
        routeSnapshot.data()?['cities'] ?? [],
      );
      if (widget.numberOfDays == 1 && cities.isNotEmpty) {
        cities = [cities.last];
      } else if (widget.numberOfDays == 2 && cities.length >= 2) {
        cities = [cities[cities.length - 2], cities.last];
      }

      List<Map<String, dynamic>> cityDataList = [];

      for (var city in cities) {
        final placeSnapshot =
            await FirebaseFirestore.instance
                .collection('places')
                .doc(city)
                .get();
        final placeData = placeSnapshot.data();
        if (placeData != null) {
          cityDataList.add({'name': city, 'data': placeData});
        }
      }

      List<List<Map<String, dynamic>>> generatedPlans = [];
      for (int i = 0; i < 3; i++) {
        var plan = await generateMultiplePlans(
          cityDataList,
          widget.numberOfDays,
        );
        generatedPlans.add(plan);
      }

      setState(() {
        multiplePlans = generatedPlans;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching travel plans: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> generateMultiplePlans(
    List<Map<String, dynamic>> cityDataList,
    int numberOfDays,
  ) async {
    List<Map<String, dynamic>> plan = [];
    int numberOfCities = cityDataList.length;
    int baseDaysPerCity = numberOfDays ~/ numberOfCities;
    int extraDays = numberOfDays % numberOfCities;
    int dayCounter = 1;

    for (int i = 0; i < cityDataList.length; i++) {
      int daysForCity = baseDaysPerCity + (i < extraDays ? 1 : 0);
      var city = cityDataList[i];
      var data = Map<String, dynamic>.from(city['data']);
      Set<String> usedPlaces = {};

      List<String> allPlaces = [];

      data.forEach((category, value) {
        if (value is List && category != 'Hotels') {
          allPlaces.addAll(value.map((e) => '$e ($category)'));
        }
      });

      allPlaces.shuffle();

      List<String> hotels = [];
      if (data['Hotels'] is List) {
        hotels = List<String>.from(data['Hotels']);
        hotels.shuffle();
      }

      for (int d = 0; d < daysForCity; d++) {
        List<String> availablePlaces =
            allPlaces.where((place) => !usedPlaces.contains(place)).toList();

        if (availablePlaces.isEmpty) {
          plan.add({
            'day': 'Day ${dayCounter++}',
            'city': city['name'],
            'message': 'No more places to visit in ${city['name']}.',
          });
          continue;
        }

        int takeCount =
            availablePlaces.length >= 9 ? 9 : availablePlaces.length;
        List<String> dailyPlaces = availablePlaces.take(takeCount).toList();
        usedPlaces.addAll(dailyPlaces);

        Map<String, List<String>> timeSlots = {
          'Morning': [],
          'Afternoon': [],
          'Evening': [],
        };

        int maxPerSlot = 2;
        int totalPlaces = dailyPlaces.length;

        int morningCount = totalPlaces >= maxPerSlot ? maxPerSlot : totalPlaces;
        int afternoonCount =
            (totalPlaces - morningCount) >= maxPerSlot
                ? maxPerSlot
                : (totalPlaces - morningCount) > 0
                ? (totalPlaces - morningCount)
                : 0;
        int eveningCount =
            (totalPlaces - morningCount - afternoonCount) >= maxPerSlot
                ? maxPerSlot
                : (totalPlaces - morningCount - afternoonCount) > 0
                ? (totalPlaces - morningCount - afternoonCount)
                : 0;

        int start = 0;
        timeSlots['Morning'] = dailyPlaces.sublist(start, start + morningCount);
        start += morningCount;

        if (afternoonCount > 0) {
          timeSlots['Afternoon'] = dailyPlaces.sublist(
            start,
            start + afternoonCount,
          );
          start += afternoonCount;
        }
        if (eveningCount > 0) {
          timeSlots['Evening'] = dailyPlaces.sublist(
            start,
            start + eveningCount,
          );
        }

        // Add one hotel per slot if available
        for (String slot in timeSlots.keys) {
          if (hotels.isNotEmpty) {
            timeSlots[slot]!.add('${hotels.removeLast()} (Hotel)');
          }
        }

        plan.add({
          'day': 'Day ${dayCounter++}',
          'city': city['name'],
          'schedule': timeSlots,
        });
      }
    }

    return plan;
  }

  Future<void> saveTravelPlan(List<Map<String, dynamic>> plan) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save the plan')),
      );
      return;
    }

    final email = user.email!;
    final planData = {
      'routeId': widget.routeId,
      'numberOfDays': widget.numberOfDays,
      'plan': plan,
      'createdAt': Timestamp.now(),
    };

    try {
      final docRef = FirebaseFirestore.instance
          .collection('savedPlans')
          .doc(email);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (docSnapshot.exists) {
          final existingPlans = List.from(docSnapshot.data()?['plans'] ?? []);
          existingPlans.add(planData);
          transaction.update(docRef, {'plans': existingPlans});
        } else {
          transaction.set(docRef, {
            'plans': [planData],
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Travel plan saved successfully!')),
      );
    } catch (e) {
      print('Error saving plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save travel plan. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Travel Plans')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: multiplePlans.length,
                itemBuilder: (context, planIndex) {
                  final plan = multiplePlans[planIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Plan ${String.fromCharCode(65 + planIndex)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...plan.map((dayPlan) => TravelDayCard(dayPlan)).toList(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: ElevatedButton(
                          onPressed: () => saveTravelPlan(plan),
                          child: const Text('Save this Plan'),
                        ),
                      ),
                      const Divider(thickness: 2),
                    ],
                  );
                },
              ),
    );
  }

  Widget TravelDayCard(Map<String, dynamic> dayPlan) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayPlan['day'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'City: ${dayPlan['city']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            if (dayPlan.containsKey('message'))
              Text(
                dayPlan['message'],
                style: const TextStyle(color: Colors.red),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    (dayPlan['schedule'] as Map<String, List<String>>).entries
                        .map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key}:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...entry.value
                                    .map((place) => Text('- $place'))
                                    .toList(),
                              ],
                            ),
                          );
                        })
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
