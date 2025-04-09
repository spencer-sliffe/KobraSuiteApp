import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/school/course.dart';
import 'package:kobrasuite_app/providers/school/course_provider.dart';
import 'package:kobrasuite_app/providers/school/assignment_provider.dart';
import 'package:kobrasuite_app/providers/school/topic_provider.dart';
import 'package:kobrasuite_app/services/image/banner_image_service.dart';
import 'package:kobrasuite_app/UI/widgets/animation/abstract_banner_animation.dart';
import 'package:kobrasuite_app/UI/widgets/cards/school/assignment_card.dart';
import 'package:kobrasuite_app/UI/widgets/cards/school/topic_card.dart';

// Import the bottom sheet:
import 'package:kobrasuite_app/UI/widgets/school/add_course_bottom_sheet.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late final BannerImageService _bannerService;
  late final Future<List<String>> _bannerColorsFuture;

  @override
  void initState() {
    super.initState();
    _bannerService = BannerImageService();
    // The color prompt for the abstract banner animation:
    final prompt = "${widget.course.title}, ${widget.course.courseCode}";
    _bannerColorsFuture = _bannerService.getBannerColors(prompt);

    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    courseProvider.setCurrentCourse(widget.course);

    // Pre-fetch assignments and topics relevant to this course
    Provider.of<AssignmentProvider>(context, listen: false).fetchAssignments();
    Provider.of<TopicProvider>(context, listen: false).fetchTopics();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF" + hex;
    return Color(int.parse(hex, radix: 16));
  }

  void _openAddCourseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddCourseBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                // This is the button that launches our AddCourseBottomSheet:
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add Course to University',
                    onPressed: _openAddCourseBottomSheet,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(course.title, style: const TextStyle(color: Colors.white)),
                  background: FutureBuilder<List<String>>(
                    future: _bannerColorsFuture,
                    builder: (context, snapshot) {
                      Widget bannerWidget;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        bannerWidget = Container(
                          height: 250,
                          color: Colors.grey.shade300,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        bannerWidget = Container(height: 250, color: Colors.grey.shade400);
                      } else {
                        final colors = snapshot.data!.map(_hexToColor).toList();
                        bannerWidget = AbstractBannerAnimation(colors: colors);
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          bannerWidget,
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                                borderRadius: BorderRadius.circular(12),
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
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: Theme.of(context).colorScheme.secondary,
                    tabs: const [
                      Tab(text: "Assignments"),
                      Tab(text: "Topics"),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              AssignmentTab(),
              TopicTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class AssignmentTab extends StatelessWidget {
  const AssignmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = context.watch<AssignmentProvider>();
    final assignments = assignmentProvider.assignments;

    if (assignmentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (assignments.isEmpty) {
      return Center(
        child: Text(
          // assignmentProvider.errorMessage.isNotEmpty
          //     ? assignmentProvider.errorMessage
          //     :
          "No assignments available.",
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: assignmentProvider.fetchAssignments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final assignment = assignments[index];
          return GestureDetector(
            onTap: () {
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AssignmentCard(assignment: assignment),
            ),
          );
        },
      ),
    );
  }
}

class TopicTab extends StatelessWidget {
  const TopicTab({super.key});

  @override
  Widget build(BuildContext context) {
    final topicProvider = context.watch<TopicProvider>();
    final topics = topicProvider.topics;

    if (topicProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (topics.isEmpty) {
      return Center(
        child: Text(
          // topicProvider.errorMessage.isNotEmpty
          //     ? topicProvider.errorMessage
          //     :
          "No topics available.",
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: topicProvider.fetchTopics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return GestureDetector(
            onTap: () {
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TopicCard(topic: topic),
            ),
          );
        },
      ),
    );
  }
}