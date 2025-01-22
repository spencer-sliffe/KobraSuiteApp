// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:kobrasuite_app/providers/school/assignment_provider.dart';
//
// class AssignmentMultistepForm extends StatefulWidget {
//   final int courseId;
//   const AssignmentMultistepForm({Key? key, required this.courseId}) : super(key: key);
//
//   @override
//   State<AssignmentMultistepForm> createState() => _AssignmentMultistepFormState();
// }
//
// class _AssignmentMultistepFormState extends State<AssignmentMultistepForm> {
//   int _currentStep = 0;
//   bool _isSubmitting = false;
//   String? _error;
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _dueCtrl = TextEditingController();
//   final _detailsFormKey = GlobalKey<FormState>();
//   final _dueFormKey = GlobalKey<FormState>();
//
//   List<Step> get _steps => [
//     Step(
//       title: const Text('Details'),
//       content: Form(
//         key: _detailsFormKey,
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _titleCtrl,
//               decoration: const InputDecoration(labelText: 'Assignment Title'),
//               validator: (val) =>
//               val == null || val.trim().isEmpty ? 'Please enter a title' : null,
//             ),
//             const SizedBox(height: 8),
//             TextFormField(
//               controller: _descCtrl,
//               decoration: const InputDecoration(labelText: 'Description'),
//               maxLines: 3,
//             ),
//           ],
//         ),
//       ),
//       isActive: _currentStep == 0,
//     ),
//     Step(
//       title: const Text('Due Date'),
//       content: Form(
//         key: _dueFormKey,
//         child: TextFormField(
//           controller: _dueCtrl,
//           decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD HH:MM)'),
//           validator: (val) {
//             if (val == null || val.trim().isEmpty) {
//               return 'Please enter a valid date/time';
//             }
//             return null;
//           },
//         ),
//       ),
//       isActive: _currentStep == 1,
//     ),
//   ];
//
//   void _nextStep() {
//     if (_currentStep == 0) {
//       if (_detailsFormKey.currentState?.validate() ?? false) {
//         setState(() => _currentStep = 1);
//       }
//     } else {
//       _submit();
//     }
//   }
//
//   void _prevStep() {
//     if (_currentStep == 0) {
//       Navigator.pop(context, false);
//     } else {
//       setState(() => _currentStep = 0);
//     }
//   }
//
//   Future<void> _submit() async {
//     if (!(_dueFormKey.currentState?.validate() ?? false)) return;
//     setState(() {
//       _isSubmitting = true;
//       _error = null;
//     });
//     final payload = {
//       'course_id': widget.courseId,
//       'title': _titleCtrl.text.trim(),
//       'description': _descCtrl.text.trim(),
//       'due_date': _dueCtrl.text.trim(),
//     };
//     final assignmentProvider = Provider.of<AssignmentProvider>(context, listen: false);
//     final success = await assignmentProvider.createAssignment(payload);
//     setState(() => _isSubmitting = false);
//     if (!mounted) return;
//     if (success) {
//       Navigator.pop(context, true);
//     } else {
//       setState(() => _error = 'Failed to create assignment.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Assignment Wizard'),
//       ),
//       body: _isSubmitting
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           if (_error != null)
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Text(
//                 _error!,
//                 style: TextStyle(color: theme.colorScheme.error),
//               ),
//             ),
//           Expanded(
//             child: Stepper(
//               steps: _steps,
//               currentStep: _currentStep,
//               onStepContinue: _nextStep,
//               onStepCancel: _prevStep,
//               controlsBuilder: (context, details) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (_currentStep > 0)
//                       ElevatedButton.icon(
//                         onPressed: details.onStepCancel,
//                         icon: const Icon(Icons.arrow_back),
//                         label: const Text('Back'),
//                       ),
//                     const SizedBox(width: 16),
//                     ElevatedButton.icon(
//                       onPressed: details.onStepContinue,
//                       icon: const Icon(Icons.arrow_forward),
//                       label: Text(_currentStep == _steps.length - 1 ? 'Submit' : 'Next'),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }