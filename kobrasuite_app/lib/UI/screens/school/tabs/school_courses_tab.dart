import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/school/course_provider.dart';
import '../../../../models/school/course.dart';
import '../../../widgets/cards/course_card.dart';

enum _AddCourseDialogState {
  initial,
  verifying,
  verified,
  adding,
  added,
}

class SchoolCoursesTab extends StatefulWidget {
  const SchoolCoursesTab({super.key});

  @override
  State<SchoolCoursesTab> createState() => _SchoolCoursesTabState();
}

class _SchoolCoursesTabState extends State<SchoolCoursesTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<Course> _filteredCourses = [];
  bool _isSearchVisible = false;
  Timer? _debounceTimer;
  CancelableOperation<void>? _searchOperation;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CourseProvider>(context, listen: false);
    provider.fetchCourses().then((_) {
      if (!mounted) return;
      setState(() {
        _filteredCourses
          ..clear()
          ..addAll(provider.courses);
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    _searchOperation?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      final p = Provider.of<CourseProvider>(context, listen: false);
      setState(() {
        _filteredCourses
          ..clear()
          ..addAll(p.courses);
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchOperation?.cancel();
      _searchOperation =
          CancelableOperation.fromFuture(_applyLocalFilter(query));
    });
  }

  Future<void> _applyLocalFilter(String query) async {
    final p = Provider.of<CourseProvider>(context, listen: false);
    final all = p.courses;
    final lc = query.toLowerCase();
    final result = all.where((c) {
      return c.title.toLowerCase().contains(lc) ||
          c.courseCode.toLowerCase().contains(lc);
    }).toList();
    if (!mounted) return;
    setState(() {
      _filteredCourses
        ..clear()
        ..addAll(result);
    });
  }

  void _showAddCourseDialog() {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final profCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    String semesterType = 'WINTER';
    int semesterYear = DateTime.now().year;
    final provider = context.read<CourseProvider>();
    _AddCourseDialogState dialogState = _AddCourseDialogState.initial;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> verifyAction() async {
              setStateDialog(() {
                dialogState = _AddCourseDialogState.verifying;
              });
              final result = await provider.verifyCourseData(
                courseCode: codeCtrl.text.trim(),
                title: titleCtrl.text.trim(),
                professorLastName: profCtrl.text.trim(),
                department: deptCtrl.text.trim(),
                semesterType: semesterType,
              );
              if (!context.mounted) return;
              if (result['foundExactMatch'] == true ||
                  result['correctedCourseData'] != null) {
                if (result['correctedCourseData'] != null) {
                  final corrected = result['correctedCourseData'];
                  if (corrected['course_code'] != null) {
                    codeCtrl.text = corrected['course_code'];
                  }
                  if (corrected['course_title'] != null) {
                    titleCtrl.text = corrected['course_title'];
                  }
                  if (corrected['professor_last_name'] != null) {
                    profCtrl.text = corrected['professor_last_name'];
                  }
                  if (corrected['department'] != null) {
                    deptCtrl.text = corrected['department'];
                  }
                  if (corrected['semester_type'] != null) {
                    semesterType = corrected['semester_type'];
                  }
                }
                setStateDialog(() {
                  dialogState = _AddCourseDialogState.verified;
                });
              } else {
                final errorMsg = result['error'] ??
                    'Course not exact. Check fields and verify again.';
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(errorMsg)),
                );
                setStateDialog(() {
                  dialogState = _AddCourseDialogState.initial;
                });
              }
            }

            Future<void> addAction() async {
              setStateDialog(() {
                dialogState = _AddCourseDialogState.adding;
              });
              final success = await provider.addNewCourse(
                courseCode: codeCtrl.text.trim(),
                title: titleCtrl.text.trim(),
                professorLastName: profCtrl.text.trim(),
                department: deptCtrl.text.trim(),
                semesterType: semesterType,
                semesterYear: semesterYear,
              );
              if (!ctx.mounted) return;
              if (success) {
                setStateDialog(() {
                  dialogState = _AddCourseDialogState.added;
                });
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.errorMessage ?? 'Failed to add course',
                    ),
                  ),
                );
                setStateDialog(() {
                  dialogState = _AddCourseDialogState.verified;
                });
              }
            }

            Widget contentWidget() {
              if (dialogState == _AddCourseDialogState.verifying) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Verifying...'),
                    ],
                  ),
                );
              } else if (dialogState == _AddCourseDialogState.adding) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Adding...'),
                    ],
                  ),
                );
              } else if (dialogState == _AddCourseDialogState.added) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Course added successfully.'),
                );
              } else {
                final readOnly = dialogState == _AddCourseDialogState.verified;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: codeCtrl,
                        readOnly: readOnly,
                        decoration: const InputDecoration(labelText: 'Course Code'),
                      ),
                      TextField(
                        controller: titleCtrl,
                        readOnly: readOnly,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: profCtrl,
                        readOnly: readOnly,
                        decoration: const InputDecoration(labelText: 'Professor Last Name'),
                      ),
                      TextField(
                        controller: deptCtrl,
                        readOnly: readOnly,
                        decoration: const InputDecoration(labelText: 'Department'),
                      ),
                      DropdownButtonFormField<String>(
                        value: semesterType,
                        items: const [
                          DropdownMenuItem(value: 'WINTER', child: Text('WINTER')),
                          DropdownMenuItem(value: 'SPRING', child: Text('SPRING')),
                          DropdownMenuItem(value: 'SUMMER', child: Text('SUMMER')),
                          DropdownMenuItem(value: 'FALL', child: Text('FALL')),
                        ],
                        onChanged: readOnly
                            ? null
                            : (val) {
                          if (val != null) {
                            setStateDialog(() {
                              semesterType = val;
                            });
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Semester'),
                      ),
                      DropdownButtonFormField<int>(
                        value: semesterYear,
                        items: List.generate(10, (index) {
                          final y = DateTime.now().year - 5 + index;
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }),
                        onChanged: readOnly
                            ? null
                            : (val) {
                          if (val != null) {
                            setStateDialog(() {
                              semesterYear = val;
                            });
                          }
                        },
                        decoration: const InputDecoration(labelText: 'Year'),
                      ),
                    ],
                  ),
                );
              }
            }

            List<Widget> actionButtons() {
              if (dialogState == _AddCourseDialogState.added) {
                return [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('Close'),
                  ),
                ];
              } else if (dialogState == _AddCourseDialogState.initial) {
                return [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: verifyAction,
                    child: const Text('Verify'),
                  ),
                ];
              } else if (dialogState == _AddCourseDialogState.verified) {
                return [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: addAction,
                    child: const Text('Add'),
                  ),
                ];
              } else {
                return [];
              }
            }

            return AlertDialog(
              title: const Text('Add New Course'),
              content: contentWidget(),
              actions: actionButtons(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchCtrl.clear();
                    _filteredCourses
                      ..clear()
                      ..addAll(provider.courses);
                  }
                });
              },
            ),
            if (_isSearchVisible)
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search courses...',
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddCourseDialog,
            ),
          ],
        ),
        if (provider.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: _filteredCourses.isEmpty
              ? Center(
            child: Text(
              provider.errorMessage?.isNotEmpty == true
                  ? provider.errorMessage!
                  : 'No courses found.',
            ),
          )
              : ListView.builder(
            itemCount: _filteredCourses.length,
            itemBuilder: (_, i) {
              final course = _filteredCourses[i];
              return CourseCard(
                course: course,
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}