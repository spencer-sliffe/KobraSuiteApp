import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nav/providers/navigation_store.dart';

enum AddSubmissionState { initial, adding, added }

class AddSubmissionBottomSheet extends StatefulWidget {
  const AddSubmissionBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddSubmissionBottomSheet> createState() =>
      _AddSubmissionBottomSheetState();
}

class _AddSubmissionBottomSheetState extends State<AddSubmissionBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _assignmentIdController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _textAnswerController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _submittedAtController = TextEditingController();

  AddSubmissionState _state = AddSubmissionState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _assignmentIdController.dispose();
    _studentIdController.dispose();
    _textAnswerController.dispose();
    _commentController.dispose();
    _submittedAtController.dispose();
    super.dispose();
  }

  Future<void> _addSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddSubmissionState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual API call result.

    if (success) {
      setState(() {
        _state = AddSubmissionState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add submission.';
        _state = AddSubmissionState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddSubmissionState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding submission...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddSubmissionState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Submission added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
            // Assignment ID
            TextFormField(
              controller: _assignmentIdController,
              decoration: const InputDecoration(labelText: 'Assignment ID'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter assignment ID';
                if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Student ID
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Enter student ID';
                if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Text Answer
            TextFormField(
              controller: _textAnswerController,
              decoration: const InputDecoration(labelText: 'Text Answer'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your answer'
                  : null,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // Optional Comment
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Comment (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            // Submission Date
            TextFormField(
              controller: _submittedAtController,
              decoration:
              const InputDecoration(labelText: 'Submission Date (YYYY-MM-DD)'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter submission date' : null,
            ),
            if (_errorFeedback.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorFeedback,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_state == AddSubmissionState.added) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddAssignmentSubmissionActive(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddSubmissionState.initial) {
      return [
        TextButton(
          onPressed: ()
          => context.read<NavigationStore>().setAddAssignmentSubmissionActive(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addSubmission,
          child: const Text('Add Submission'),
        ),
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
            Text('Add New Submission',
                style: Theme.of(context).textTheme.headlineSmall),
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