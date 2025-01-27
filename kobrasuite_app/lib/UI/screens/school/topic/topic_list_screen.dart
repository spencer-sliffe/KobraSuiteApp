// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:kobrasuite_app/models/school/course.dart';
// import 'package:kobrasuite_app/models/school/topic.dart';
// import 'package:kobrasuite_app/providers/school/topic_provider.dart';
// import 'package:kobrasuite_app/screens/school/topic/topic_detail_screen.dart';
//
// class TopicListScreen extends StatefulWidget {
//   final Course course;
//   const TopicListScreen({Key? key, required this.course}) : super(key: key);
//
//   @override
//   State<TopicListScreen> createState() => _TopicListScreenState();
// }
//
// class _TopicListScreenState extends State<TopicListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch topics when screen is created
//     Future.microtask(() =>
//         Provider.of<TopicProvider>(context, listen: false)
//             .fetchTopicsByCourse(widget.course.id));
//   }
//
//   Future<void> _createNewTopic() async {
//     final nameCtrl = TextEditingController();
//     final created = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('New Topic'),
//         content: TextField(
//           controller: nameCtrl,
//           decoration: const InputDecoration(labelText: 'Topic Name'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Create'),
//           ),
//         ],
//       ),
//     );
//
//     if (created == true) {
//       final name = nameCtrl.text.trim();
//       if (name.isNotEmpty) {
//         final topicProvider = Provider.of<TopicProvider>(context, listen: false);
//         final success = await topicProvider.createTopic(widget.course.id, name);
//         if (!success && mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(topicProvider.errorMessage ?? 'Failed to create topic'),
//             ),
//           );
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TopicProvider>(
//       builder: (ctx, topicProvider, child) {
//         final isLoading = topicProvider.isLoading;
//         final errorMessage = topicProvider.errorMessage;
//         final topics = topicProvider.topics;
//
//         return Scaffold(
//           appBar: AppBar(
//             title: Text('${widget.course.title} - Topics'),
//           ),
//           body: Column(
//             children: [
//               if (isLoading) const LinearProgressIndicator(),
//               if (errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Text(
//                     errorMessage,
//                     style: TextStyle(color: Theme.of(context).colorScheme.error),
//                   ),
//                 ),
//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () =>
//                       topicProvider.fetchTopicsByCourse(widget.course.id),
//                   child: topics.isEmpty
//                       ? ListView(
//                     children: const [
//                       SizedBox(height: 80),
//                       Center(child: Text('No topics found. Pull to refresh.')),
//                     ],
//                   )
//                       : ListView.builder(
//                     itemCount: topics.length,
//                     itemBuilder: (ctx, i) {
//                       final t = topics[i];
//                       return InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => TopicDetailScreen(topic: t),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).cardTheme.color,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 t.name,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 4),
//                               Text('Topic ID: ${t.id}'),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           floatingActionButton: FloatingActionButton.extended(
//             onPressed: _createNewTopic,
//             icon: const Icon(Icons.add),
//             label: const Text('New Topic'),
//           ),
//         );
//       },
//     );
//   }
// }