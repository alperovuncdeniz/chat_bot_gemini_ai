import 'dart:async';

import 'package:chat_bot_gemini_ai/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getAllMessagesProvider =
    StreamProvider.autoDispose.family<Iterable<Message>, String>(
  (ref, userId) {
    final controller = StreamController<Iterable<Message>>();

    final sub = FirebaseFirestore.instance
        .collection("conversations")
        .doc(userId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs.map((messageData) => Message.fromMap(
            messageData.data(),
          ));
      controller.sink.add(messages);
    });

    ref.onDispose(() {
      sub.cancel();
      controller.close();
    });

    return controller.stream;
  },
);

Future<void> deleteAllMessages(String userId) async {
  final batch = FirebaseFirestore.instance.batch();
  final messagesRef = FirebaseFirestore.instance
      .collection("conversations")
      .doc(userId)
      .collection("messages");

  final snapshot = await messagesRef.get();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }

  await batch.commit();
  print("All messages deleted successfully.");
}
