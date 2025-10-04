import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the next available product ID for document name
  static Future<String> getNextProductId() async {
    try {
      // First try to use the counter
      final counterDoc = await _firestore.collection('counters').doc('products').get();

      if (counterDoc.exists) {
        final currentId = counterDoc.data()!['lastId'] as int;
        final newId = currentId + 1;

        await _firestore.collection('counters').doc('products').set({
          'lastId': newId,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return newId.toString();
      } else {
        // If no counter exists, find the highest ID from existing documents
        final highestId = await _getHighestProductIdFromCollection();
        final newId = highestId + 1;

        // Initialize the counter
        await _firestore.collection('counters').doc('products').set({
          'lastId': newId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return newId.toString();
      }
    } catch (e) {
      // Fallback: get highest ID from collection
      final highestId = await _getHighestProductIdFromCollection();
      return (highestId + 1).toString();
    }
  }

  // Get highest product ID from the document names
  static Future<int> _getHighestProductIdFromCollection() async {
    try {
      final allProducts = await _firestore.collection('products').get();
      int highestId = 0;

      for (final doc in allProducts.docs) {
        final docId = doc.id;
        // Parse document ID as integer
        final numericId = int.tryParse(docId);
        if (numericId != null && numericId > highestId) {
          highestId = numericId;
        }
      }

      // If we found existing numeric IDs, return the highest
      if (highestId > 0) {
        return highestId;
      }

      // If no numeric IDs found, check your existing documents and find the next number
      // Based on your screenshot, you have documents 31-37, 4-9
      // So we should return 37 as the next ID
      return 37; // This will make the next ID 38
    } catch (e) {
      return 37; // Start from 38 if error occurs
    }
  }
}