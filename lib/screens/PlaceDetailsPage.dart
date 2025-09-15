import 'package:flutter/material.dart';

class PlaceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> placeDetails;

  PlaceDetailsPage({required this.placeDetails});

  @override
  Widget build(BuildContext context) {
    // Normalize all expected fields as List<String>
    final List<String> temples = List<String>.from(
      placeDetails['Temple'] ?? [],
    );
    final List<String> gardens = List<String>.from(
      placeDetails['Gardens'] ?? [],
    );
    final List<String> mountains = List<String>.from(
      placeDetails['Mountains'] ?? [],
    );
    final List<String> beaches = List<String>.from(
      placeDetails['Beaches'] ?? [],
    );
    final List<String> monuments = List<String>.from(
      placeDetails['Historical Place or Monument'] ?? [],
    );
    final List<String> lakes = List<String>.from(
      placeDetails['River or Lake'] ?? [],
    );
    final List<String> museums = List<String>.from(
      placeDetails['Museum'] ?? [],
    );
    final List<String> hotels = List<String>.from(placeDetails['Hotels'] ?? []);
    final List<String> images = List<String>.from(placeDetails['images'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(placeDetails['name'] ?? 'Place Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Place name
            Text(
              placeDetails['name'] ?? 'Unknown Place',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Description
            Text(
              placeDetails['description'] ?? 'No description available.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Images section
            if (images.isNotEmpty) ...[
              Text(
                "Images",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],

            buildSection("Temples Nearby", temples),
            buildSection("Gardens Nearby", gardens),
            buildSection("Mountains Nearby", mountains),
            buildSection("Beaches Nearby", beaches),
            buildSection("Historical Places / Monuments", monuments),
            buildSection("Rivers / Lakes", lakes),
            buildSection("Museums", museums),
            buildSection("Hotels", hotels),
          ],
        ),
      ),
    );
  }

  // Reusable method to build sections with clickable items
  Widget buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        items.isNotEmpty
            ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("• $item", style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
            )
            : Text("No $title found", style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
      ],
    );
  }
}
