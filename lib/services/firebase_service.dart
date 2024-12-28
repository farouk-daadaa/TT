import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitContactForm(Map<String, dynamic> formData) async {
    try {
      await _firestore.collection('contact_forms').add({
        ...formData,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting form: $e');
      throw e;
    }
  }

  Stream<QuerySnapshot> getCourses() {
    return _firestore.collection('courses').snapshots();
  }
}