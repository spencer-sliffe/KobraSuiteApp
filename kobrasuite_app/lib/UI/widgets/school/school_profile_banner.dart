// File: lib/UI/screens/school/school_profile_banner.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/general/school_profile_provider.dart';
import '../../../models/school/school_profile.dart';
import '../../../services/image/banner_image_service.dart';

import '../animation/abstract_banner_animation.dart';

class SchoolProfileBanner extends StatefulWidget {
  const SchoolProfileBanner({Key? key}) : super(key: key);

  @override
  State<SchoolProfileBanner> createState() => _SchoolProfileBannerState();
}

class _SchoolProfileBannerState extends State<SchoolProfileBanner> {
  late Future<List<String>> _bannerColorsFuture;

  // Helper: convert a hex string to a Color.
  Color hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF" + hex;
    return Color(int.parse(hex, radix: 16));
  }

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<SchoolProfileProvider>(context, listen: false).schoolProfile;
    final prompt = "University, ${profile?.universityDetail?.name ?? ''}";
    _bannerColorsFuture = BannerImageService().getBannerColors(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<SchoolProfileProvider>(context);
    final SchoolProfile? profile = profileProvider.schoolProfile;
    String smallText = 'No School Profile Loaded';
    if (profile != null) {
      if (profile.universityDetail != null) {
        smallText = 'University: ${profile.universityDetail!.name}';
      } else {
        smallText = 'No University Selected';
      }
    }
    return FutureBuilder<List<String>>(
      future: _bannerColorsFuture,
      builder: (context, snapshot) {
        Widget background;
        if (snapshot.connectionState == ConnectionState.waiting) {
          background = Container(
            height: 150,
            color: Colors.grey.shade300,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          background = Container(height: 150, color: Colors.grey.shade400);
        } else {
          final colors = snapshot.data!.map((hex) => hexToColor(hex)).toList();
          background = AbstractBannerAnimation(colors: colors);
        }
        return Stack(
          children: [
            background,
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.blueGrey.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      smallText,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}