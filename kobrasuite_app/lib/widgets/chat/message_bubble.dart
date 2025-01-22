import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../styles/chat_styles.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final String timestamp;
  final bool isOwnMessage;

  const MessageBubble({
    Key? key,
    required this.content,
    required this.timestamp,
    required this.isOwnMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
      'Message from ${isOwnMessage ? "you" : "other"}, sent at $timestamp. Message: $content',
      child: Align(
        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: ChatStyles.messageBubbleDecoration(isOwn: isOwnMessage),
          child: Column(
            crossAxisAlignment:
            isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: ChatStyles.messageTextStyle(isOwn: isOwnMessage),
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              ),
              SizedBox(height: 6.h),
              Text(
                timestamp,
                style: ChatStyles.timestampTextStyle(isOwn: isOwnMessage),
                textScaleFactor: MediaQuery.of(context).textScaleFactor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}