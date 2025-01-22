// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:kobrasuite_app/models/school/course.dart';
// import 'package:kobrasuite_app/providers/school/assignment_provider.dart';
// import 'assignment_multistep_form.dart';
// import 'assignment_detail_screen.dart';
//
// class AssignmentListScreen extends StatefulWidget {
//   final Course course;
//   const AssignmentListScreen({Key? key, required this.course}) : super(key: key);
//
//   @override
//   State<AssignmentListScreen> createState() => _AssignmentListScreenState();
// }
//
// class _AssignmentListScreenState extends State<AssignmentListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch assignments from the provider:
//     final assignmentProvider = Provider.of<AssignmentProvider>(context, listen: false);
//     assignmentProvider.fetchAssignmentsByCourse(widget.course.id);
//   }
//
//   Future<void> _createAssignment() async {
//     // Navigate to the multi-step assignment creation form
//     final created = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AssignmentMultistepForm(courseId: widget.course.id),
//       ),
//     );
//     // If creation was successful, refresh the assignment list
//     if (created == true && mounted) {
//       Provider.of<AssignmentProvider>(context, listen: false)
//           .fetchAssignmentsByCourse(widget.course.id);
//     }
//   }
//
//   String _formatDateTime(DateTime dt) {
//     return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
//         '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${widget.course.title} - Assignments'),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _createAssignment,
//         icon: const Icon(Icons.add),
//         label: const Text('New Assignment'),
//       ),
//       body: Consumer<AssignmentProvider>(
//         builder: (ctx, provider, _) {
//           if (provider.isLoading) {
//             return const LinearProgressIndicator();
//           }
//           if (provider.errorMessage != null) {
//             return Center(
//               child: Text(
//                 provider.errorMessage!,
//                 style: TextStyle(color: Theme.of(context).colorScheme.error),
//               ),
//             );
//           }
//           final assignments = provider.assignments;
//           if (assignments.isEmpty) {
//             return const Center(child: Text('No assignments yet.'));
//           }
//           return ListView.builder(
//             itemCount: assignments.length,
//             itemBuilder: (ctx, i) {
//               final a = assignments[i];
//               return InkWell(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => AssignmentDetailScreen(assignment: a),
//                     ),
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).cardTheme.color,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 20,
//                           backgroundColor: Theme.of(context).colorScheme.primary,
//                           child: const Icon(Icons.assignment, color: Colors.white),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 a.title,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 4),
//                               Text('Due: ${_formatDateTime(a.dueDate)}'),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }