// File: lib/UI/screens/school/university/university_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/school/university.dart';
import '../../../../providers/school/university_provider.dart';
import '../../../../providers/general/auth_provider.dart';
import 'university_chat_screen.dart';

class UniversityDetailScreen extends StatelessWidget {
  final University university;

  const UniversityDetailScreen({Key? key, required this.university}) : super(key: key);

  Future<void> _removeUniversity(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove University'),
        content: Text('Are you sure you want to remove "${university.name}" from your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final universityProvider = Provider.of<UniversityProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userPk;
      if (userId != 0) {
        final success = await universityProvider.removeUniversity(university.id);
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _addUniversity(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add University'),
        content: Text('Are you sure you want to set "${university.name}" as your profile university?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final universityProvider = Provider.of<UniversityProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userPk;
      if (userId != 0) {
        final success = await universityProvider.setUniversity(university);
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final universityProvider = Provider.of<UniversityProvider>(context);
    final isMyUniversity = universityProvider.currentUniversity?.id == university.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(university.name, style: theme.textTheme.titleLarge),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => isMyUniversity ? _removeUniversity(context) : _addUniversity(context),
            icon: Icon(isMyUniversity ? Icons.remove_circle_outline : Icons.add_circle_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.domain, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Domain: ${university.domain}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.flag, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Country: ${university.country}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.web, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Website: ${university.website ?? 'N/A'}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Students on App: ${university.studentCount ?? 0}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.book, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Courses in App: ${university.courseCount ?? 0}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isMyUniversity
                      ? UniversityChatScreen(universityId: university.id.toString())
                      : Center(
                    child: Text(
                      'Set this university as your institution to view the live chat.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}