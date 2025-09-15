import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BestTimeToTravelPage extends StatefulWidget {
  const BestTimeToTravelPage({super.key});

  @override
  State<BestTimeToTravelPage> createState() => _BestTimeToTravelPageState();
}

class _BestTimeToTravelPageState extends State<BestTimeToTravelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Best Time to Travel')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('places').get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final places =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['name'] ?? doc.id).toString().toLowerCase();
                      return data['bestTime'] != null &&
                          (_searchQuery.isEmpty || name.contains(_searchQuery));
                    }).toList();

                if (places.isEmpty) {
                  return const Center(child: Text('No places found.'));
                }

                return ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    final data = place.data() as Map<String, dynamic>;

                    final name = data['name'] ?? place.id;
                    final bestTime = data['bestTime'] ?? 'Not specified';
                    final bestTimeReason =
                        data['bestTimeReason'] ?? 'No reason available.';
                    final imageUrl = data['imageUrl'];

                    return Card(
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('Best time: $bestTime'),
                        leading:
                            imageUrl != null
                                ? Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.location_on, size: 40),
                        onTap: () {
                          // Navigate to a new page to show the reason
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BestTimeDetailPage(
                                    placeName: name,
                                    bestTime: bestTime,
                                    bestTimeReason: bestTimeReason,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BestTimeDetailPage extends StatelessWidget {
  final String placeName;
  final String bestTime;
  final String bestTimeReason;

  const BestTimeDetailPage({
    required this.placeName,
    required this.bestTime,
    required this.bestTimeReason,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(placeName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Best Time to Travel: $bestTime',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Reason for Best Time:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(bestTimeReason, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
