import 'package:flutter/material.dart';

class ControlBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const ControlBarButton({super.key, required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}