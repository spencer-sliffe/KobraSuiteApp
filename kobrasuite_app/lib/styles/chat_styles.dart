import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatStyles {
  static TextStyle messageTextStyle({bool isOwn = false}) {
    return GoogleFonts.lato(
      fontSize: 15.sp,
      color: isOwn ? Colors.white : Colors.black87,
    );
  }

  static TextStyle timestampTextStyle({bool isOwn = false}) {
    return GoogleFonts.lato(
      fontSize: 11.sp,
      color: isOwn ? Colors.white70 : Colors.black54,
    );
  }

  static BoxDecoration messageBubbleDecoration({required bool isOwn}) {
    final gradientColors = isOwn
        ? [Colors.blueAccent, Colors.lightBlue]
        : [Colors.grey.shade400, Colors.grey.shade400];
    return BoxDecoration(
      gradient: LinearGradient(colors: gradientColors),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isOwn ? 12.r : 0),
        topRight: Radius.circular(isOwn ? 0 : 12.r),
        bottomLeft: Radius.circular(12.r),
        bottomRight: Radius.circular(12.r),
      ),
      boxShadow: [
        BoxShadow(
          color: isOwn ? Colors.blueAccent.withOpacity(0.2) : Colors.black12,
          offset: const Offset(2, 3),
          blurRadius: 3.0,
        ),
      ],
    );
  }
}