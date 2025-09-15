import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PlaceDetailsPage.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchPlace() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return;

    var collection = FirebaseFirestore.instance.collection('places');
    var snapshot = await collection.get();

    final results =
        snapshot.docs
            .where(
              (doc) =>
                  doc.id.toLowerCase().contains(query) ||
                  (doc.data()['name']?.toLowerCase() ?? '').contains(query),
            )
            .map((doc) {
              var data = doc.data();
              return {
                'id': doc.id,
                'name': data['name'] ?? doc.id,
                'image': null, // No image field used
                'details': {
                  'name': data['name'] ?? doc.id,
                  'description':
                      data['description']?.toString() ??
                      'No description available.',
                  'location': data['location'] ?? 'Unknown location',
                  'rating': data['rating'] ?? 0.0,
                  'popular_places': data['popular_places'] ?? [],
                  'Temple': data['Temple'] ?? [],
                  'Gardens': data['Gardens'] ?? [],
                  'Mountains': data['Mountains'] ?? [],
                  'Beaches': data['Beaches'] ?? [],
                  'Historical Place or Monument':
                      data['Historical Place or Monument'] ?? [],
                  'River or Lake': data['River or Lake'] ?? [],
                  'Museum': data['Museum'] ?? [],
                  'Hotels': data['Hotels'] ?? [],
                },
              };
            })
            .toList();

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header with search bar
            Container(
              height: 300,
              decoration: BoxDecoration(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(.8),
                      Colors.black.withOpacity(.2),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "What would you like to find?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                hintText: "Search for cities, places ...",
                              ),
                              onSubmitted: (_) => _searchPlace(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward, color: Colors.grey),
                            onPressed: _searchPlace,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // 🔍 Search Results
            if (_searchResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Search Results",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(place['name']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PlaceDetailsPage(
                                        placeDetails: place['details'],
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            SizedBox(height: 30),

            // 🧭 Best Destinations
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Best Destination",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        makeItem(
                          image: 'assets/images/Mysore.jpg',
                          title: 'Mysore',
                          context: context,
                        ),
                        makeItem(
                          image: 'assets/images/Andhra.jpg',
                          title: 'Andhra Pradesh',
                          context: context,
                        ),
                        makeItem(
                          image: 'assets/images/Ladakh.jpg',
                          title: 'Ladakh',
                          context: context,
                        ),
                        makeItem(
                          image: 'assets/images/Coorg.jpg',
                          title: 'Coorg',
                          context: context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget makeItem({
    required String image,
    required String title,
    required BuildContext context,
  }) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: GestureDetector(
        onTap: () async {
          final placeDetails = await fetchPlaceDetails(title);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PlaceDetailsPage(placeDetails: placeDetails),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(.2),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(String placeName) async {
    var collection = FirebaseFirestore.instance.collection('places');
    var docSnapshot = await collection.doc(placeName).get();

    if (docSnapshot.exists) {
      var data = docSnapshot.data() as Map<String, dynamic>;

      return {
        'name': data['name'] ?? placeName,
        'description':
            data['description']?.toString() ?? 'No description available.',
        'location': data['location'] ?? 'Unknown location',
        'rating': data['rating'] ?? 0.0,
        'popular_places': data['popular_places'] ?? [],
        'Temple': data['Temple'] ?? [],
        'Gardens': data['Gardens'] ?? [],
        'Mountains': data['Mountains'] ?? [],
        'Beaches': data['Beaches'] ?? [],
        'Historical Place or Monument':
            data['Historical Place or Monument'] ?? [],
        'River or Lake': data['River or Lake'] ?? [],
        'Museum': data['Museum'] ?? [],
        'Hotels': data['Hotels'] ?? [],
      };
    } else {
      return {
        'name': placeName,
        'description': 'No description available.',
        'location': 'Unknown location',
        'rating': 0.0,
        'popular_places': [],
        'Temple': [],
        'Gardens': [],
        'Mountains': [],
        'Beaches': [],
        'Historical Place or Monument': [],
        'River or Lake': [],
        'Museum': [],
        'Hotels': [],
      };
    }
  }
}
