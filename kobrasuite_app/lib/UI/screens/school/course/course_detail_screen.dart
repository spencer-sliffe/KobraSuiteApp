// File: lib/UI/screens/school/course_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../../models/school/course.dart';
import '../../../../services/image/banner_image_service.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bannerService = BannerImageService();
    final prompt = "${course.title}, ${course.courseCode}";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 40,
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                course.title,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      blurRadius: 3,
                      color: Colors.black,
                      offset: Offset(1, 1),
                    )
                  ],
                ),
              ),
              background: FutureBuilder<String>(
                future: bannerService.getBannerImageUrl(prompt),
                builder: (context, snapshot) {
                  final imageUrl = snapshot.data ?? "";
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                      )
                          : Container(color: Colors.grey.shade300),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildInfoItem(Icons.book, course.courseCode),
                              _buildInfoItem(Icons.person, course.professorLastName),
                              _buildInfoItem(Icons.business, course.department),
                              _buildInfoItem(Icons.date_range, course.semester),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildCourseDetails(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCourseDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'This course provides in-depth knowledge on the subject. Explore assignments, topics, and discussions within the course to enhance your understanding and skills.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        // Additional course-specific details can be added here.
      ],
    );
  }
}