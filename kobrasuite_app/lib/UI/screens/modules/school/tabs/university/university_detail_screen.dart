import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../models/school/university.dart';
import '../../../../../../providers/general/auth_provider.dart';
import '../../../../../../providers/school/university_provider.dart';
import '../../../../../../services/image/banner_image_service.dart';
import '../../../../../nav/control_bar/page_control_bar.dart';
import '../../../../../nav/providers/control_bar_provider.dart';
import '../../../../../nav/providers/control_bar_registrar.dart';
import '../../../../../widgets/animation/abstract_banner_animation.dart';
import '../../../../../widgets/cards/school/university_news_card.dart';

class UniversityDetailScreen extends StatefulWidget {
  final University university;
  const UniversityDetailScreen({Key? key, required this.university}) : super(key: key);

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  late Future<List<String>> _bannerColorsFuture;

  @override
  void initState() {
    super.initState();
    _bannerColorsFuture = BannerImageService().getBannerColors(
      "modern university campus, ${widget.university.name}",
    );
  }

  Future<void> _refreshNews() async {
    final provider = Provider.of<UniversityProvider>(context, listen: false);
    await provider.fetchTrendingNews(widget.university.name);
  }

  Future<void> _setUniversity() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set University'),
        content: Text('Do you want to set "${widget.university.name}" as your profile university?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed == true) {
      final provider = Provider.of<UniversityProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userPk != 0) {
        final success = await provider.setUniversity(widget.university);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('University set successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.errorMessage ?? 'Error setting university')),
          );
        }
      }
    }
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF" + hex;
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trendingNews = Provider.of<UniversityProvider>(context).trendingNews;
    return  Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        extendBodyBehindAppBar: true,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 250,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'univ-banner-${widget.university.id}',
                  child: FutureBuilder<List<String>>(
                    future: _bannerColorsFuture,
                    builder: (context, snapshot) {
                      Widget bannerWidget;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        bannerWidget = Container(
                          color: Colors.grey.shade300,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        bannerWidget = Container(color: Colors.grey.shade400);
                      } else {
                        final colors = snapshot.data!.map((hex) => hexToColor(hex)).toList();
                        bannerWidget = AbstractBannerAnimation(colors: colors);
                      }
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          bannerWidget,
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
                                    widget.university.name,
                                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.domain, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.university.domain,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.flag, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.university.country,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  if (widget.university.stateProvince != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "State/Province: ${widget.university.stateProvince}",
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ),
                                  if (widget.university.studentCount != null || widget.university.courseCount != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          if (widget.university.studentCount != null)
                                            Text(
                                              "Students: ${widget.university.studentCount}",
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          if (widget.university.studentCount != null &&
                                              widget.university.courseCount != null)
                                            const SizedBox(width: 12),
                                          if (widget.university.courseCount != null)
                                            Text(
                                              "Courses: ${widget.university.courseCount}",
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () => _launchWebsite(widget.university.website),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.web, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            widget.university.website,
                                            style: const TextStyle(
                                              color: Colors.lightBlueAccent,
                                              fontSize: 12,
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
                  ),
                ),
              ),
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Trending News', style: theme.textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshNews,
                    ),
                  ],
                ),
              ),
            ),
            trendingNews.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: Text('No trending news available.')))
                : SliverToBoxAdapter(
              child: SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trendingNews.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final news = trendingNews[index];
                    return UniversityNewsCard(news: news);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        bottomNavigationBar: const PageControlBar(),
      );

  }
}