import 'package:flutter/material.dart';
import '../../../../models/school/course.dart';
import '../../../../services/image/banner_image_service.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;
  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bannerService = BannerImageService();
    final bannerUrl = bannerService.getBannerImageUrl("modern course, ${course.courseCode}");

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(bannerUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Overlay with course details
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 32,
                      color: Colors.blueGrey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.book, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('${course.courseCode}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.school, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('${course.professorLastName}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.where_to_vote, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('${course.department}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 4),
                          const Icon(Icons.date_range_sharp, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text('${course.semester}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      alignment: Alignment.bottomLeft,
                    ),
                  ),
                ],
              ),
              title: Text(course.title),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text('Course Details', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'This course provides in-depth knowledge on the subject. Explore assignments, topics, and discussions within the course.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}