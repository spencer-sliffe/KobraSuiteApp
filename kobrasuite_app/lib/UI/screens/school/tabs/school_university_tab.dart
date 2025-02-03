// File: lib/UI/screens/school/school_university_tab.dart
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../providers/school/university_provider.dart';
import 'package:kobrasuite_app/services/image/banner_image_service.dart';
import '../../../widgets/animation/abstract_banner_animation.dart';
import '../../../widgets/cards/university_card.dart';
import 'package:kobrasuite_app/UI/widgets/school/school_profile_banner.dart';

import '../university/university_detail_screen.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF" + hex;
  }
  return Color(int.parse(hex, radix: 16));
}

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
  Future<List<String>>? _bannerColorsFuture;

  @override
  void initState() {
    super.initState();
    // Load the current university and cache the banner colors once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UniversityProvider>(context, listen: false);
      provider.loadUserUniversity();
      if (provider.currentUniversity != null) {
        final bannerPrompt = "Modern university campus, ${provider.currentUniversity!.name} banner";
        setState(() {
          _bannerColorsFuture = BannerImageService().getBannerColors(bannerPrompt);
        });
      }
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
    final String bannerPrompt = currentUni != null
        ? "Modern university campus, ${currentUni.name} banner"
        : "Default university banner";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          if (currentUni != null)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => _openUniversityDetail(currentUni),
                child: _bannerColorsFuture != null
                    ? FutureBuilder<List<String>>(
                  future: _bannerColorsFuture,
                  builder: (context, snapshot) {
                    Widget bannerWidget;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      bannerWidget = Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      bannerWidget = Container(height: 200, color: Colors.grey.shade400);
                    } else {
                      final colors = snapshot.data!.map((hex) => hexToColor(hex)).toList();
                      bannerWidget = AbstractBannerAnimation(colors: colors);
                    }
                    return Stack(
                      children: [
                        bannerWidget,
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
                                if (currentUni.stateProvince != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "State: ${currentUni.stateProvince}",
                                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                  ),
                                if (currentUni.studentCount != null || currentUni.courseCount != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        if (currentUni.studentCount != null)
                                          Text(
                                            "Students: ${currentUni.studentCount}",
                                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                                          ),
                                        if (currentUni.studentCount != null && currentUni.courseCount != null)
                                          const SizedBox(width: 8),
                                        if (currentUni.courseCount != null)
                                          Text(
                                            "Courses: ${currentUni.courseCount}",
                                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                                          ),
                                      ],
                                    ),
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
                        ),
                      ],
                    );
                  },
                )
                    : Container(
                  height: 200,
                  color: Colors.grey.shade400,
                ),
              ),
            )
          else
            const SliverToBoxAdapter(child: SchoolProfileBanner()),
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
    );
  }
}