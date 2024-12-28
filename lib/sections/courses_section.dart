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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                image: AssetImage(course['image']!),
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
    'image': 'assets/courses/spring_angular.png',
  },
  {
    'name': 'Node JS / React',
    'price': '350 DT',
    'image': 'assets/courses/node_react.png',
  },
  {
    'name': 'Flutter / Firebase',
    'price': '350 DT',
    'image': 'assets/courses/flutter_firebase.png',
  },
  {
    'name': 'Business Intelligence',
    'price': '350 DT',
    'image': 'assets/courses/business_intelligence.png',
  },
  {
    'name': 'Artificial Intelligence',
    'price': '350 DT',
    'image': 'assets/courses/artificial_intelligence.png',
  },
  {
    'name': 'DevOps',
    'price': '350 DT',
    'image': 'assets/courses/devops.png',
  },
];