import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/school/university_provider.dart';
import '../../../../services/image/banner_image_service.dart';
import '../../../widgets/school/school_profile_banner.dart';
import '../university/university_detail_screen.dart';
import '../../../widgets/cards/university_card.dart';

class SchoolUniversityTab extends StatefulWidget {
  final int userId;
  const SchoolUniversityTab({Key? key, required this.userId}) : super(key: key);

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
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _searchOperation?.cancel();
      Provider.of<UniversityProvider>(context, listen: false).searchUniversities(query);
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchCtrl.clear();
        Provider.of<UniversityProvider>(context, listen: false).searchUniversities('');
      }
    });
  }

  void _openUniversityDetail(university) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversityDetailScreen(university: university),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UniversityProvider>();
    final universities = provider.searchResults;
    final currentUni = provider.currentUniversity;
    final bannerService = BannerImageService();
    // Use a general query for the banner.
    final bannerUrl = bannerService.getBannerImageUrl(provider.currentUniversity.toString());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (currentUni != null)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => _openUniversityDetail(currentUni),
                child: Stack(
                  children: [
                    Image.network(bannerUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Full-width overlay with compact university details.
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade700.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.school, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUni.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.domain, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        currentUni.domain,
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.flag, color: Colors.white, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        currentUni.country,
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      final url = currentUni.website;
                                      if (await canLaunch(url)) {
                                        await launch(url, forceSafariVC: false, forceWebView: false);
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.web, color: Colors.white, size: 12),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            currentUni.website,
                                            style: const TextStyle(
                                              color: Colors.lightBlueAccent,
                                              fontSize: 10,
                                              decoration: TextDecoration.underline,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
                              onPressed: _toggleSearch,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(child: const SchoolProfileBanner()),
          if (_isSearchVisible)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Universities...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          provider.isLoading
              ? const SliverToBoxAdapter(child: LinearProgressIndicator())
              : universities.isEmpty
              ? const SliverFillRemaining(child: Center(child: Text('No universities found.')))
              : SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final uni = universities[index];
                  return GestureDetector(
                    child: UniversityCard(
                      onTap: () => _openUniversityDetail(uni),
                      university: uni,
                      onSetAsCurrent: () async {
                        await provider.setUniversity(uni);
                        if (mounted && provider.errorMessage?.isNotEmpty == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.errorMessage!)),
                          );
                        }
                      },
                    ),
                  );
                },
                childCount: universities.length,
              ),
            ),
          ),
        ],
      ),
      // Removed floating action button here because page controls are in the bottom bar.
    );
  }
}