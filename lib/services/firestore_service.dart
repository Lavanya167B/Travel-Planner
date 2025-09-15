import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Example method to fetch documents from a Firestore collection
  Future<List<Map<String, dynamic>>> getItems() async {
    try {
      QuerySnapshot snapshot = await _db.collection('items').get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  // Example method to add a document to Firestore
  Future<void> addItem(Map<String, dynamic> data) async {
    try {
      await _db.collection('items').add(data);
    } catch (e) {
      throw Exception("Error adding item: $e");
    }
  }

  // Add more methods as needed to interact with Firestore (e.g., update, delete)
}
