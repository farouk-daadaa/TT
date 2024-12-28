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
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFD81B60),
        iconTheme: const IconThemeData(color: Colors.white),
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

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      return CourseCard(
                        course: data,
                        onEdit: () => _editCourse(document.id, data),
                        onDelete: () => _deleteCourse(document.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFFD81B60),
      ),
    );
  }

  Future<void> _showCourseDialog({String? id, Map<String, dynamic>? existingData}) async {
    final nameController = TextEditingController(text: existingData?['name'] ?? '');
    final priceController = TextEditingController(text: existingData?['price']?.toString() ?? '');
    File? imageFile;
    String? previewImageUrl = existingData?['image'];
    bool isUploading = false;
    String errorMessage = '';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(id == null ? 'Add Course' : 'Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: imageFile != null
                        ? Image.file(imageFile!, fit: BoxFit.cover)
                        : (previewImageUrl != null
                        ? Image.network(previewImageUrl, fit: BoxFit.cover)
                        : const Icon(Icons.add_photo_alternate, size: 50)),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1200,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          imageFile = File(image.path);
                          errorMessage = '';
                        });
                      }
                    } catch (e) {
                      setState(() => errorMessage = 'Failed to pick image');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD81B60),
                  ),
                  child: const Text('Choose Image'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (DT/Month)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (isUploading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                if (nameController.text.isEmpty || priceController.text.isEmpty) {
                  setState(() => errorMessage = 'Please fill all fields');
                  return;
                }

                setState(() => isUploading = true);

                try {
                  String? imageUrl = previewImageUrl;

                  if (imageFile != null) {
                    final String fileName = 'courses/${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final ref = _storage.ref().child(fileName);

                    final metadata = SettableMetadata(
                      contentType: 'image/jpeg',
                      customMetadata: {'picked-file-path': imageFile!.path},
                    );

                    final uploadTask = ref.putFile(imageFile!, metadata);

                    await uploadTask.whenComplete(() async {
                      imageUrl = await ref.getDownloadURL();
                    });
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

                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  setState(() {
                    isUploading = false;
                    errorMessage = 'Error: ${e.toString()}';
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD81B60),
              ),
              child: Text(isUploading ? 'Saving...' : 'Save'),
            ),
          ],
        ),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.collection('courses').doc(id).delete();
    }
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                if (course['image'] != null)
                  Image.network(
                    course['image'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: onEdit,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFD81B60),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: onDelete,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${course['price']}/Month',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD81B60),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}