import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageInput extends StatefulWidget {
  final void Function(String message) onSend;

  const MessageInput({Key? key, required this.onSend}) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: GoogleFonts.lato(fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Semantics(
              button: true,
              label: 'Send message',
              child: CircleAvatar(
                radius: 24.r,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                  onPressed: _handleSend,
                  tooltip: 'Send',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}