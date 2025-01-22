import 'package:flutter/material.dart';

class KobraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const KobraAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: theme.colorScheme.primaryContainer,
      actions: actions,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}