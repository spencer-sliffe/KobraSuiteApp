// File location: lib/UI/widgets/course_detail/assignment_detail_popup.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/school/assignment.dart';
import 'package:kobrasuite_app/providers/school/submission_provider.dart';
import 'package:kobrasuite_app/UI/widgets/document/uploaders/submission_upload_widget.dart';

class AssignmentDetailPopup extends StatefulWidget {
  final Assignment assignment;
  const AssignmentDetailPopup({Key? key, required this.assignment}) : super(key: key);

  @override
  _AssignmentDetailPopupState createState() => _AssignmentDetailPopupState();
}

class _AssignmentDetailPopupState extends State<AssignmentDetailPopup> {
  @override
  void initState() {
    super.initState();
    Provider.of<SubmissionProvider>(context, listen: false).fetchSubmissions(widget.assignment.id);
  }

  @override
  Widget build(BuildContext context) {
    final submissionProvider = context.watch<SubmissionProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(5)))),
                const SizedBox(height: 16),
                Text(widget.assignment.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text("Due: ${dateFormat.format(widget.assignment.dueDate)}", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (widget.assignment.description != null && widget.assignment.description!.isNotEmpty)
                  Text(widget.assignment.description!, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text("Submissions", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                submissionProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : submissionProvider.submissions.isEmpty
                    ? Text(submissionProvider.errorMessage ?? "No submissions yet.", style: Theme.of(context).textTheme.bodyMedium)
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: submissionProvider.submissions.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final submission = submissionProvider.submissions[index];
                    return ListTile(
                      title: Text("Submission ${submission.id}"),
                      subtitle: Text("Submitted at: ${dateFormat.format(submission.submittedAt)}"),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SubmissionUploadWidget(assignmentId: widget.assignment.id),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Submission"),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}