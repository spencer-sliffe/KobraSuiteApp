import 'package:flutter/material.dart';

enum AddStudyDocumentState { initial, adding, added }

class AddStudyDocumentBottomSheet extends StatefulWidget {
  const AddStudyDocumentBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddStudyDocumentBottomSheet> createState() =>
      _AddStudyDocumentBottomSheetState();
}

class _AddStudyDocumentBottomSheetState extends State<AddStudyDocumentBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();

  AddStudyDocumentState _state = AddStudyDocumentState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fileUrlController.dispose();
    super.dispose();
  }

  Future<void> _addStudyDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = AddStudyDocumentState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with your actual API/service call.

    if (success) {
      setState(() {
        _state = AddStudyDocumentState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add study document.';
        _state = AddStudyDocumentState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddStudyDocumentState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding study document...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddStudyDocumentState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Study document added successfully.',
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
            // Title Field.
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Document Title'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            // Description Field.
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // File URL Field.
            TextFormField(
              controller: _fileUrlController,
              decoration: const InputDecoration(labelText: 'File URL'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter file URL' : null,
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
    if (_state == AddStudyDocumentState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        )
      ];
    }
    if (_state == AddStudyDocumentState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addStudyDocument,
          child: const Text('Add Document'),
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
            Text('Add New Study Document',
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