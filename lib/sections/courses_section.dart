import 'package:flutter/material.dart';

class CoursesSection extends StatelessWidget {
  const CoursesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discover Our Courses',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: 36, // Fixed height for the button
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD81B60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'View More',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 600 ? 3 : 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) => CourseCard(course: courses[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, String> course;

  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(course['image']!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          course['name']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
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
    );
  }
}

final List<Map<String, String>> courses = [
  {
    'name': 'Spring Boot / Angular',
    'price': '350 DT',
    'image': 'https://cdn.discordapp.com/attachments/1082012060210188418/1321870832959750186/images_1.jpg?ex=676ecfa5&is=676d7e25&hm=009b4c38cb50905883e0a9efb7c9f06e35a770b6e2be67e56aaa7d39ebed1d8c&',
  },
  {
    'name': 'Node JS / React',
    'price': '350 DT',
    'image': 'https://cdn.discordapp.com/attachments/1082012060210188418/1321870832271753266/images.jpg?ex=676ecfa5&is=676d7e25&hm=30542e45dad0abda50dfde9d40a523cc5870680098c731c34d840c45f1e97c69&',
  },
  {
    'name': 'Flutter / Firebase',
    'price': '350 DT',
    'image': 'https://cdn.discordapp.com/attachments/1082012060210188418/1321870832636792892/images.png?ex=676ecfa5&is=676d7e25&hm=f24e4aacf22d175bb303c6dfe522fa310de036e9936368ca6c8af1ec4658fe3e&',
  },
  {
    'name': 'Business Intelligence',
    'price': '350 DT',
    'image': 'https://cdn.discordapp.com/attachments/1082012060210188418/1321871340717871195/images_2.jpg?ex=676ed01e&is=676d7e9e&hm=0ac2651e99b24fce9550709184c4d1e49ff31b083660ee26aafdfd1f9d3d1c8c&',
  },
  {
    'name': 'Artificial Intelligence',
    'price': '350 DT',
    'image': 'https://cdn.discordapp.com/attachments/1082012060210188418/1321871534851358720/images_3.jpg?ex=676ed04d&is=676d7ecd&hm=410e3d36b4a844724e33bf4df130d2ee485bc2550041a9e529b570f789502b00&',
  },
  {
    'name': 'DevOps',
    'price': '350 DT',
    'image': 'https://cdn.discordapp.com/attachments/1082012060210188418/1321871904772063384/images_1.png?ex=676ed0a5&is=676d7f25&hm=8ade749963ec083ca114b9c3d411163184e4e78b6540a3aecc3c5ca287956ad5&',
  },
];