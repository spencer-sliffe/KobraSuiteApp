import 'package:flutter/material.dart';

enum AddTopicState { initial, adding, added }

class AddTopicBottomSheet extends StatefulWidget {
  const AddTopicBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddTopicBottomSheet> createState() => _AddTopicBottomSheetState();
}

class _AddTopicBottomSheetState extends State<AddTopicBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _topicNameController = TextEditingController();
  final TextEditingController _courseIdController = TextEditingController();

  AddTopicState _state = AddTopicState.initial;
  String _errorFeedback = "";

  @override
  void dispose() {
    _topicNameController.dispose();
    _courseIdController.dispose();
    super.dispose();
  }

  Future<void> _addTopic() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = AddTopicState.adding;
      _errorFeedback = "";
    });

    // Simulate an asynchronous service call. Replace with your actual API call.
    await Future.delayed(const Duration(seconds: 1));
    final success = true; // Replace with actual response

    if (success) {
      setState(() {
        _state = AddTopicState.added;
      });
    } else {
      setState(() {
        _errorFeedback = 'Failed to add topic.';
        _state = AddTopicState.initial;
      });
    }
  }

  Widget _buildContent() {
    if (_state == AddTopicState.adding) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Adding topic...'),
            ],
          ),
        ),
      );
    }
    if (_state == AddTopicState.added) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Topic added successfully.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }
    // Build the form.
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
            // Topic Name
            TextFormField(
              controller: _topicNameController,
              decoration: const InputDecoration(labelText: 'Topic Name'),
              validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a topic name' : null,
            ),
            const SizedBox(height: 12),
            // Course ID field
            TextFormField(
              controller: _courseIdController,
              decoration: const InputDecoration(labelText: 'Course ID'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter course ID';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
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
    if (_state == AddTopicState.added) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_state == AddTopicState.initial) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addTopic,
          child: const Text('Add Topic'),
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
            Text('Add New Topic', style: Theme.of(context).textTheme.headlineSmall),
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