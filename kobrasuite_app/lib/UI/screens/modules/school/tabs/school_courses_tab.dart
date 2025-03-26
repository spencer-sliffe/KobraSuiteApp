import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/school/course.dart';
import 'package:kobrasuite_app/providers/school/course_provider.dart';
import 'package:kobrasuite_app/UI/widgets/cards/school/course_card.dart';
import 'package:kobrasuite_app/UI/widgets/school/add_course_bottom_sheet.dart';

import 'course/course_detail_screen.dart';

class SchoolCoursesTab extends StatefulWidget {
  const SchoolCoursesTab({Key? key}) : super(key: key);

  @override
  State<SchoolCoursesTab> createState() => _SchoolCoursesTabState();
}

class _SchoolCoursesTabState extends State<SchoolCoursesTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Course> _filteredCourses = [];
  bool _isSearching = false;
  Timer? _debounce;
  CancelableOperation<void>? _searchOperation;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CourseProvider>(context, listen: false);
    provider.fetchCourses().then((_) {
      if (!mounted) return;
      setState(() {
        _filteredCourses = List.from(provider.courses);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _searchOperation?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      final provider = Provider.of<CourseProvider>(context, listen: false);
      setState(() {
        _filteredCourses = List.from(provider.courses);
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchOperation?.cancel();
      _searchOperation = CancelableOperation.fromFuture(_filterCourses(query));
    });
  }

  Future<void> _filterCourses(String query) async {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    final lowerQuery = query.toLowerCase();
    final result = provider.courses.where((course) {
      return course.title.toLowerCase().contains(lowerQuery) ||
          course.courseCode.toLowerCase().contains(lowerQuery);
    }).toList();
    if (!mounted) return;
    setState(() {
      _filteredCourses = result;
    });
  }

  void _openAddCourseBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const AddCourseBottomSheet(),
    );
  }

  void _openCourseDetail(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    return Scaffold(
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search courses',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _filteredCourses = List.from(courseProvider.courses);
                      });
                    },
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          if (courseProvider.isLoading)
            const LinearProgressIndicator()
          else
            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                child: Text(
                  courseProvider.errorMessage?.isNotEmpty == true
                      ? courseProvider.errorMessage!
                      : 'No courses available.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
                  : RefreshIndicator(
                onRefresh: () => courseProvider.fetchCourses(),
                child: ListView.builder(
                  itemCount: _filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = _filteredCourses[index];
                    return GestureDetector(
                      onTap: () => _openCourseDetail(course),
                      child: CourseCard(course: course),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}