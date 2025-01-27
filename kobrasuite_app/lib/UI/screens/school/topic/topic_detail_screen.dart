// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:kobrasuite_app/models/school/topic.dart';
// import 'package:kobrasuite_app/models/school/study_document.dart';
// import 'package:kobrasuite_app/providers/school/study_document_provider.dart';
// import 'package:kobrasuite_app/widgets/documents/viewers/document_viewer_widget.dart';
//
// class TopicDetailScreen extends StatefulWidget {
//   final Topic topic;
//   const TopicDetailScreen({Key? key, required this.topic}) : super(key: key);
//
//   @override
//   State<TopicDetailScreen> createState() => _TopicDetailScreenState();
// }
//
// class _TopicDetailScreenState extends State<TopicDetailScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Load documents via provider
//     Future.microtask(() => Provider.of<StudyDocumentProvider>(context, listen: false)
//         .fetchDocumentsByTopic(widget.topic.id));
//   }
//
//   Future<void> _uploadDocument() async {
//     final titleCtrl = TextEditingController();
//     final descCtrl = TextEditingController();
//     File? selectedFile;
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Upload Study Document'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: titleCtrl,
//                 decoration: const InputDecoration(labelText: 'Document Title'),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: descCtrl,
//                 decoration: const InputDecoration(labelText: 'Description'),
//               ),
//               const SizedBox(height: 8),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   final result =
//                   await FilePicker.platform.pickFiles(type: FileType.any);
//                   if (result != null && result.files.isNotEmpty) {
//                     final path = result.files.single.path;
//                     if (path != null) {
//                       selectedFile = File(path);
//                     }
//                   }
//                 },
//                 icon: const Icon(Icons.attach_file),
//                 label: const Text('Choose File'),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Upload'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true) {
//       final title = titleCtrl.text.trim();
//       final desc = descCtrl.text.trim();
//       if (title.isEmpty || selectedFile == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please provide a title and file.')),
//         );
//         return;
//       }
//       final studyDocProvider =
//       Provider.of<StudyDocumentProvider>(context, listen: false);
//
//       final success = await studyDocProvider.addDocument({
//         'topic_id': widget.topic.id,
//         'title': title,
//         'description': desc.isEmpty ? null : desc,
//         'file': selectedFile,
//       });
//       if (!success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               studyDocProvider.errorMessage ?? 'Failed to upload document.',
//             ),
//           ),
//         );
//       }
//     }
//   }
//
//   void _openDocumentViewer(String fileUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DocumentViewerScreen(documentUrl: fileUrl),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StudyDocumentProvider>(
//       builder: (ctx, docProvider, child) {
//         final isLoading = docProvider.isLoading;
//         final error = docProvider.errorMessage;
//         final docs = docProvider.documents;
//         final subtitle = 'Course ID: ${widget.topic.courseId}, Topic ID: ${widget.topic.id}';
//
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(widget.topic.name),
//           ),
//           body: Column(
//             children: [
//               ListTile(
//                 title: Text('Topic: ${widget.topic.name}'),
//                 subtitle: Text(subtitle),
//               ),
//               if (isLoading) const LinearProgressIndicator(),
//               if (error != null)
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Text(
//                     error,
//                     style: TextStyle(color: Theme.of(context).colorScheme.error),
//                   ),
//                 ),
//               Expanded(
//                 child: docs.isEmpty
//                     ? const Center(child: Text('No study documents yet.'))
//                     : ListView.builder(
//                   itemCount: docs.length,
//                   itemBuilder: (ctx, i) {
//                     final doc = docs[i];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: ListTile(
//                         title: Text(doc.title),
//                         subtitle: Text(doc.description ?? 'No Description'),
//                         onTap: () => _openDocumentViewer(doc.file),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//           floatingActionButton: FloatingActionButton.extended(
//             onPressed: _uploadDocument,
//             icon: const Icon(Icons.upload_file),
//             label: const Text('Upload Doc'),
//           ),
//         );
//       },
//     );
//   }
// }