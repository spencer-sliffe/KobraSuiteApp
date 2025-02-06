import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kobrasuite_app/UI/screens/modules/school/tabs/university/university_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kobrasuite_app/providers/school/university_provider.dart';
import 'package:kobrasuite_app/services/image/banner_image_service.dart';
import 'package:kobrasuite_app/UI/widgets/cards/university_card.dart';
import 'package:kobrasuite_app/UI/widgets/cards/university_news_card.dart';
import 'package:kobrasuite_app/UI/widgets/school/school_profile_banner.dart';

import '../../../../widgets/animation/abstract_banner_animation.dart';

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) hex = "FF" + hex;
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
    // Load university data and then banner colors.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uniProvider = Provider.of<UniversityProvider>(context, listen: false);
      uniProvider.loadUserUniversity().then((_) {
        if (uniProvider.currentUniversity != null) {
          final bannerPrompt =
              "Modern university campus, ${uniProvider.currentUniversity!.name} banner";
          setState(() {
            _bannerColorsFuture = BannerImageService().getBannerColors(bannerPrompt);
          });
        }
      });
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
      setState(() {});
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

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildBanner(BuildContext context, dynamic currentUni) {
    return GestureDetector(
      onTap: () => _openUniversityDetail(currentUni),
      child: _bannerColorsFuture != null
          ? FutureBuilder<List<String>>(
        future: _bannerColorsFuture,
        builder: (context, snapshot) {
          Widget bannerWidget;
          if (snapshot.connectionState == ConnectionState.waiting) {
            bannerWidget = Container(
              height: 250,
              color: Colors.grey.shade300,
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            bannerWidget = Container(
              height: 250,
              color: Colors.grey.shade400,
            );
          } else {
            final colors = snapshot.data!.map((hex) => hexToColor(hex)).toList();
            bannerWidget = AbstractBannerAnimation(colors: colors);
          }
          return Stack(
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: bannerWidget,
              ),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUni.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.domain, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          currentUni.domain,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.flag, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          currentUni.country,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    if (currentUni.stateProvince != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "State: ${currentUni.stateProvince}",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (currentUni.studentCount != null)
                          Text(
                            "Students: ${currentUni.studentCount}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        if (currentUni.studentCount != null &&
                            currentUni.courseCount != null)
                          const SizedBox(width: 16),
                        if (currentUni.courseCount != null)
                          Text(
                            "Courses: ${currentUni.courseCount}",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        await _launchWebsite(currentUni.website);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.web, color: Colors.lightBlueAccent, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              currentUni.website,
                              style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                fontSize: 14,
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
            ],
          );
        },
      )
          : Container(
        height: 250,
        color: Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uniProvider = context.watch<UniversityProvider>();
    final currentUni = uniProvider.currentUniversity;
    final List<dynamic> searchResults = uniProvider.searchResults;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: currentUni != null
                ? FlexibleSpaceBar(
              background: _buildBanner(context, currentUni),
            )
                : const FlexibleSpaceBar(
              background: SchoolProfileBanner(),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverSearchBarDelegate(
              minExtent: 60,
              maxExtent: 60,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _isSearchVisible
                    ? TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search Universities...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending News',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _toggleSearch,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (uniProvider.isLoading)
            const SliverToBoxAdapter(child: LinearProgressIndicator())
          else if (_isSearchVisible && _searchCtrl.text.trim().isNotEmpty)
            (searchResults.isEmpty
                ? const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No universities found.')),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final uni = searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: UniversityCard(
                        onTap: () => _openUniversityDetail(uni),
                        university: uni,
                        onSetAsCurrent: () async {
                          await uniProvider.setUniversity(uni);
                          if (mounted &&
                              uniProvider.errorMessage?.isNotEmpty == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(uniProvider.errorMessage!)),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: searchResults.length,
                ),
              ),
            ))
          else
            (uniProvider.trendingNews.isEmpty
                ? const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No trending news available.')),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final news = uniProvider.trendingNews[index];
                    return GestureDetector(
                      onTap: () {
                        // Placeholder: implement news detail action if needed.
                      },
                      child: UniversityNewsCard(news: news),
                    );
                  },
                  childCount: uniProvider.trendingNews.length,
                ),
              ),
            )),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;
  final Widget child;
  _SliverSearchBarDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: maxExtent,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverSearchBarDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.child != child;
  }
}