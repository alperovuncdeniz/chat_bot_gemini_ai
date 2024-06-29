import 'package:chat_bot_gemini_ai/models/message.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final bool isOutgoing;

  const MessageTile({
    super.key,
    required this.message,
    required this.isOutgoing,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutgoing ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isOutgoing ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            message.imageUrl != null
                ? Image.network(message.imageUrl!)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
