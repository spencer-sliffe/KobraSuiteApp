// File location: lib/UI/widgets/document/uploaders/submission_upload_widget.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/providers/school/submission_provider.dart';
import 'package:kobrasuite_app/models/school/submission.dart';

class SubmissionUploadWidget extends StatefulWidget {
  final int assignmentId;
  final int? submissionId;
  const SubmissionUploadWidget({Key? key, required this.assignmentId, this.submissionId}) : super(key: key);

  @override
  _SubmissionUploadWidgetState createState() => _SubmissionUploadWidgetState();
}

class _SubmissionUploadWidgetState extends State<SubmissionUploadWidget> {
  File? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    setState(() {
      _isUploading = true;
    });
    final submissionProvider = Provider.of<SubmissionProvider>(context, listen: false);
    int submissionId = widget.submissionId ?? 0;
    if (submissionId == 0) {
      Submission? newSubmission = await submissionProvider.createSubmission(widget.assignmentId, {});
      if (newSubmission != null) {
        submissionId = newSubmission.id;
      } else {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to create submission")));
        return;
      }
    }
    bool success = await submissionProvider.uploadAnswerFile(
      assignmentId: widget.assignmentId,
      submissionId: submissionId,
      file: _selectedFile!,
      onProgress: (sent, total) {
        setState(() {
          _uploadProgress = sent / total;
        });
      },
    );
    setState(() {
      _isUploading = false;
    });
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Upload Submission", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _selectedFile == null
              ? ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file),
            label: const Text("Select File"),
          )
              : Text("Selected: ${_selectedFile!.path.split(Platform.pathSeparator).last}"),
          const SizedBox(height: 16),
          _isUploading
              ? LinearProgressIndicator(value: _uploadProgress)
              : ElevatedButton.icon(
            onPressed: _uploadFile,
            icon: const Icon(Icons.cloud_upload),
            label: const Text("Upload"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}