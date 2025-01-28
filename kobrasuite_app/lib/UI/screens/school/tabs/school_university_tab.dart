import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/school/university_provider.dart';
import '../../../widgets/cards/university_card.dart';
import '../university/university_detail_screen.dart';

class SchoolUniversityTab extends StatefulWidget {
  final int userId;
  const SchoolUniversityTab({super.key, required this.userId});

  @override
  State<SchoolUniversityTab> createState() => _SchoolUniversityTabState();
}

class _SchoolUniversityTabState extends State<SchoolUniversityTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearchVisible = false;
  Timer? _debounceTimer;
  CancelableOperation<void>? _searchOperation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UniversityProvider>(context, listen: false).loadUserUniversity();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounceTimer?.cancel();
    _searchOperation?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      Provider.of<UniversityProvider>(context, listen: false).searchUniversities('');
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchOperation?.cancel();
      _searchOperation = CancelableOperation.fromFuture(
        Provider.of<UniversityProvider>(context, listen: false).searchUniversities(query),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UniversityProvider>();
    final universities = provider.searchResults;
    final currentUni = provider.currentUniversity;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchCtrl.clear();
                    provider.searchUniversities('');
                  }
                });
              },
            ),
            if (_isSearchVisible)
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search Universities...',
                  ),
                ),
              )
            else
              Text(
                currentUni == null ? 'No University Selected' : 'Current: ${currentUni.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
        if (provider.isLoading) const LinearProgressIndicator(),
        Expanded(
          child: universities.isEmpty
              ? Center(
            child: Text(provider.errorMessage?.isNotEmpty == true
                ? provider.errorMessage!
                : 'No universities found.'),
          )
              : ListView.builder(
            itemCount: universities.length,
            itemBuilder: (context, index) {
              final uni = universities[index];
              return UniversityCard(
                university: uni,
                onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (_) => UniversityDetailScreen(university: uni)),
                 );
                },
                onSetAsCurrent: () async {
                  final success = await provider.setUniversity(uni);
                  if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.errorMessage ?? 'Error setting university')),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}