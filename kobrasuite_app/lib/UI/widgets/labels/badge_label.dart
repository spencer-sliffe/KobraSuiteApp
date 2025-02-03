import 'package:flutter/material.dart';

class BadgeLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  const BadgeLabel({
    Key? key,
    required this.text,
    this.fontSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.backgroundColor = const Color(0xFF37474F), // equivalent to Colors.blueGrey.shade700
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}