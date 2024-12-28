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

  Stream<QuerySnapshot> getCourses({int? limit}) {
    Query query = _firestore.collection('courses');
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  Future<void> addCourse(Map<String, dynamic> courseData) async {
    try {
      await _firestore.collection('courses').add(courseData);
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }

  Future<void> updateCourse(String id, Map<String, dynamic> courseData) async {
    try {
      await _firestore.collection('courses').doc(id).update(courseData);
    } catch (e) {
      print('Error updating course: $e');
      throw e;
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _firestore.collection('courses').doc(id).delete();
    } catch (e) {
      print('Error deleting course: $e');
      throw e;
    }
  }
}

