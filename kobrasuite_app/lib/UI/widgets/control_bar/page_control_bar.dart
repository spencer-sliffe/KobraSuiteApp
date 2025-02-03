import 'package:flutter/material.dart';

class PageControlBar extends StatelessWidget {
  final int selectedIndex;
  final int? schoolSubTabIndex;
  final VoidCallback onAiChatToggle;
  final VoidCallback onRefresh;
  final VoidCallback onUniversityChatToggle;
  final VoidCallback onSetUniversity;
  final VoidCallback onCourseChatToggle;
  final VoidCallback onAddCourse;
  final VoidCallback onAssignmentChatToggle;

  const PageControlBar({
    Key? key,
    required this.selectedIndex,
    this.schoolSubTabIndex,
    required this.onAiChatToggle,
    required this.onRefresh,
    required this.onUniversityChatToggle,
    required this.onSetUniversity,
    required this.onCourseChatToggle,
    required this.onAddCourse,
    required this.onAssignmentChatToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build buttons based on active module and sub–tab.
    final theme = Theme.of(context);
    List<Widget> buttons = [];

    if (selectedIndex == 0) {
      // Home Dashboard: AI Chat toggle and refresh.
      buttons.add(_buildIconButton(Icons.chat_bubble_outline, "AI Chat", onAiChatToggle));
      buttons.add(_buildIconButton(Icons.refresh, "Refresh", onRefresh));
    } else if (selectedIndex == 3) {
      // School module: check sub–tab index.
      if (schoolSubTabIndex == null || schoolSubTabIndex == 0) {
        // University sub–tab
        buttons.add(_buildIconButton(Icons.chat, "Uni Chat", onUniversityChatToggle));
        buttons.add(_buildIconButton(Icons.check_circle_outline, "Set Uni", onSetUniversity));
        buttons.add(_buildIconButton(Icons.refresh, "Refresh", onRefresh));
      } else if (schoolSubTabIndex == 1) {
        // Courses sub–tab
        buttons.add(_buildIconButton(Icons.chat, "Course Chat", onCourseChatToggle));
        buttons.add(_buildIconButton(Icons.add_circle_outline, "Add Course", onAddCourse));
        buttons.add(_buildIconButton(Icons.forum, "Assign Chat", onAssignmentChatToggle));
        buttons.add(_buildIconButton(Icons.refresh, "Refresh", onRefresh));
      }
    } else {
      // Other modules: generic refresh.
      buttons.add(_buildIconButton(Icons.refresh, "Refresh", onRefresh));
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.surface,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons,
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}