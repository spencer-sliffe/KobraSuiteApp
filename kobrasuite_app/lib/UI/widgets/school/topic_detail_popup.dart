// File location: lib/UI/widgets/course_detail/topic_detail_popup.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kobrasuite_app/models/school/topic.dart';
import 'package:kobrasuite_app/providers/school/study_document_provider.dart';
import 'package:kobrasuite_app/UI/widgets/document/uploaders/study_document_upload_widget.dart';

class TopicDetailPopup extends StatefulWidget {
  final Topic topic;
  const TopicDetailPopup({Key? key, required this.topic}) : super(key: key);

  @override
  _TopicDetailPopupState createState() => _TopicDetailPopupState();
}

class _TopicDetailPopupState extends State<TopicDetailPopup> {
  @override
  void initState() {
    super.initState();
    Provider.of<StudyDocumentProvider>(context, listen: false).fetchStudyDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final studyDocProvider = context.watch<StudyDocumentProvider>();
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
                Text(widget.topic.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text("Study Documents", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                studyDocProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : studyDocProvider.studyDocuments.isEmpty
                    ? Text(studyDocProvider.errorMessage ?? "No study documents available.", style: Theme.of(context).textTheme.bodyMedium)
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: studyDocProvider.studyDocuments.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final doc = studyDocProvider.studyDocuments[index];
                    return ListTile(
                      title: Text("Document ${doc.id}"),
                      subtitle: Text(doc.title),
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
                      builder: (_) => const StudyDocumentUploadWidget(),
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Study Document"),
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