import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFFD81B60),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${data['price']}/Month'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFD81B60)),
                        onPressed: () => _editCourse(document.id, data),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCourse(document.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFD81B60),
      ),
    );
  }

  Future<void> _addCourse() async {
    await _showCourseDialog();
  }

  Future<void> _editCourse(String id, Map<String, dynamic> data) async {
    await _showCourseDialog(id: id, existingData: data);
  }

  Future<void> _deleteCourse(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm) {
      await _firestore.collection('courses').doc(id).delete();
    }
  }

  Future<void> _showCourseDialog({String? id, Map<String, dynamic>? existingData}) async {
    final nameController = TextEditingController(text: existingData?['name'] ?? '');
    final priceController = TextEditingController(text: existingData?['price']?.toString() ?? '');
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Add Course' : 'Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    imageFile = File(image.path);
                  }
                },
                child: const Text('Select Image'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD81B60)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String? imageUrl = existingData?['image'];
              if (imageFile != null) {
                final ref = _storage.ref().child('courses/${DateTime.now().toString()}');
                await ref.putFile(imageFile!);
                imageUrl = await ref.getDownloadURL();
              }

              final data = {
                'name': nameController.text,
                'price': priceController.text,
                if (imageUrl != null) 'image': imageUrl,
              };

              if (id == null) {
                await _firestore.collection('courses').add(data);
              } else {
                await _firestore.collection('courses').doc(id).update(data);
              }

              Navigator.of(context).pop();
            },
            child: const Text('Save'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD81B60)),
          ),
        ],
      ),
    );
  }
}

