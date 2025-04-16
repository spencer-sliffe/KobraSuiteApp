import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/school/course_provider.dart';
import '../../nav/providers/navigation_store.dart';

enum AddCourseState { initial, verifying, verified, adding, added }

class AddCourseBottomSheet extends StatefulWidget {
  const AddCourseBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddCourseBottomSheet> createState() => _AddCourseBottomSheetState();
}

class _AddCourseBottomSheetState extends State<AddCourseBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  String _semesterType = 'WINTER';
  int _semesterYear = DateTime.now().year;
  AddCourseState _state = AddCourseState.initial;
  String _verificationFeedback = "";

  @override
  void dispose() {
    _courseCodeController.dispose();
    _titleController.dispose();
    _professorController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _verifyCourse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = AddCourseState.verifying;
      _verificationFeedback = "";
    });
    final courseProvider = context.read<CourseProvider>();
    final result = await courseProvider.verifyCourseData(
      courseCode: _courseCodeController.text.trim(),
      title: _titleController.text.trim(),
      professorLastName: _professorController.text.trim(),
      department: _departmentController.text.trim(),
      semesterType: _semesterType,
    );
    _verificationFeedback = result['feedback'] ?? "";
    if (result['foundExactMatch'] == true || result['correctedCourseData'] != null) {
      final corrected = result['correctedCourseData'];
      if (corrected != null) {
        if (corrected['course_code'] != null) {
          _courseCodeController.text = corrected['course_code'];
        }
        if (corrected['course_title'] != null) {
          _titleController.text = corrected['course_title'];
        }
        if (corrected['professor_last_name'] != null) {
          _professorController.text = corrected['professor_last_name'];
        }
        if (corrected['department'] != null) {
          _departmentController.text = corrected['department'];
        }
        if (corrected['semester_type'] != null) {
          _semesterType = corrected['semester_type'];
        }
      }
      setState(() {
        _state = AddCourseState.verified;
      });
    } else {
      final errorMsg = result['error'] ?? 'Verification failed. Check your input.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
      setState(() {
        _state = AddCourseState.initial;
      });
    }
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = AddCourseState.adding;
    });
    final courseProvider = context.read<CourseProvider>();
    final success = await courseProvider.addNewCourse(
      courseCode: _courseCodeController.text.trim(),
      title: _titleController.text.trim(),
      professorLastName: _professorController.text.trim(),
      department: _departmentController.text.trim(),
      semesterType: _semesterType,
      semesterYear: _semesterYear,
    );
    if (success) {
      setState(() {
        _state = AddCourseState.added;
      });
    } else {
      final errorMsg = courseProvider.errorMessage ?? 'Failed to add course.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
      setState(() {
        _state = AddCourseState.verified;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddCourseState.verifying) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Verifying course...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddCourseState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding course...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddCourseState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Course added successfully.', style: Theme.of(context).textTheme.titleLarge),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _courseCodeController,
              readOnly: _state == AddCourseState.verified,
              decoration: const InputDecoration(labelText: 'Course Code'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter course code' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              readOnly: _state == AddCourseState.verified,
              decoration: const InputDecoration(labelText: 'Course Title'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter course title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _professorController,
              readOnly: _state == AddCourseState.verified,
              decoration: const InputDecoration(labelText: 'Professor Last Name'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter professor last name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _departmentController,
              readOnly: _state == AddCourseState.verified,
              decoration: const InputDecoration(labelText: 'Department (e.g., EECS, BUS)'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter department' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _semesterType,
              items: const [
                DropdownMenuItem(value: 'WINTER', child: Text('WINTER')),
                DropdownMenuItem(value: 'SPRING', child: Text('SPRING')),
                DropdownMenuItem(value: 'SUMMER', child: Text('SUMMER')),
                DropdownMenuItem(value: 'FALL', child: Text('FALL')),
              ],
              onChanged: _state == AddCourseState.verified ? null : (value) {
                if (value != null) {
                  setState(() {
                    _semesterType = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Semester Type'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _semesterYear,
              items: List.generate(10, (index) {
                final year = DateTime.now().year - 5 + index;
                return DropdownMenuItem(value: year, child: Text('$year'));
              }),
              onChanged: _state == AddCourseState.verified ? null : (value) {
                if (value != null) {
                  setState(() {
                    _semesterYear = value;
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Semester Year'),
            ),
            if (_verificationFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _verificationFeedback,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddCourseState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddCourseActive(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddCourseState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddCourseActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _verifyCourse,
          child: const Text('Verify'),
        )
      ];
    }
    if (_state == AddCourseState.verified) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addCourse,
          child: const Text('Add Course'),
        )
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add New Course', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildContent(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActions(),
            )
          ],
        ),
      ),
    );
  }
}