import 'package:flutter/material.dart';
import '../../../widgets/school/add_topic_bottom_sheet.dart';
import '../universal_bottom_overlay.dart';

class AddTopicOverlay extends StatelessWidget {
  const AddTopicOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the add-topic bottom sheet in a universal overlay
    // so it fills the available bottom space.
    return UniversalBottomOverlay(child: const AddTopicBottomSheet());
  }
}