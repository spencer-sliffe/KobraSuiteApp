// import 'package:flutter/material.dart';
// import 'package:kobrasuite_app/models/school/assignment.dart';
// import '../submission/assignment_submissions_screen.dart';
// import 'assignment_chat_screen.dart';
//
// class AssignmentDetailScreen extends StatelessWidget {
//   final Assignment assignment;
//   const AssignmentDetailScreen({Key? key, required this.assignment}) : super(key: key);
//
//   String _formatDateTime(DateTime dt) {
//     return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
//         '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final dueDateString = _formatDateTime(assignment.dueDate);
//     final remaining = assignment.dueDate.difference(DateTime.now());
//     final daysLeft = remaining.inDays;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(assignment.title),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).cardTheme.color,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         assignment.title,
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       const SizedBox(height: 8),
//                       Text('Due Date: $dueDateString'),
//                       const SizedBox(height: 8),
//                       if (daysLeft >= 0) Text('Days Left: $daysLeft'),
//                       if (assignment.description != null && assignment.description!.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(assignment.description!),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => AssignmentSubmissionsScreen(assignment: assignment),
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.library_books),
//                   label: const Text('View Submissions'),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Divider(color: Theme.of(context).dividerColor),
//               ),
//               Container(
//                 height: 500,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: AssignmentChatScreen(assignmentId: assignment.id.toString()),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }