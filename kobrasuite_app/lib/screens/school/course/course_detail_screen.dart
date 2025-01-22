// import 'package:flutter/material.dart';
// import 'package:kobrasuite_app/models/school/course.dart';
// import 'package:kobrasuite_app/screens/school/assignment/assignment_list_screen.dart';
// import 'package:kobrasuite_app/screens/school/topic/topic_list_screen.dart';
// import 'course_chat_screen.dart';
//
// class CourseDetailScreen extends StatelessWidget {
//   final Course course;
//   const CourseDetailScreen({Key? key, required this.course}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(course.title),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Container(
//             width: doule.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: theme.colorScheme.primary.withOpacity(0.1),
//               borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Course Code: ${course.courseCode}',
//                   style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 4),
//                 Text('Professor: ${course.professorLastName}', style: theme.textTheme.titleMedium),
//                 const SizedBox(height: 4),
//                 Text('Semester: ${course.semester}', style: theme.textTheme.titleMedium),
//                 const SizedBox(height: 4),
//                 if (course.department != null) Text('Department: ${course.department}', style: theme.textTheme.titleMedium),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(Icons.people, size: 16),
//                     const SizedBox(width: 4),
//                     Text('${course.studentCount ?? 0} Students', style: theme.textTheme.bodySmall),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => AssignmentListScreen(course: course)),
//                       );
//                     },
//                     icon: const Icon(Icons.assignment),
//                     label: const Text('Assignments'),
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => TopicListScreen(course: course)),
//                       );
//                     },
//                     icon: const Icon(Icons.topic),
//                     label: const Text('Topics'),
//                     style: ElevatedButton.styleFrom(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Divider(),
//           Expanded(
//             child: CourseChatScreen(courseId: course.id.toString()),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {},
//         icon: const Icon(Icons.create),
//         label: const Text('New Topic'),
//       ),
//     );
//   }
// }