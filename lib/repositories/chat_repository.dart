import 'package:chat_bot_gemini_ai/models/message.dart';
import 'package:chat_bot_gemini_ai/repositories/storage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

@immutable
class ChatRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future sendMessage({
    required String apiKey,
    required XFile? image,
    required String promptText,
  }) async {
    final textModel = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
    final imageModel =
        GenerativeModel(model: "gemini-pro-vision", apiKey: apiKey);
    final userId = _auth.currentUser!.uid;
    final sentMessageId = const Uuid().v4();

    Message message = Message(
      id: sentMessageId,
      message: promptText,
      createdAt: DateTime.now(),
      isMine: true,
    );

    if (image != null) {
      final downloadUrl = await StorageRepository().saveImageToStorage(
        image: image,
        messageId: sentMessageId,
      );

      message = message.copyWith(
        imageUrl: downloadUrl,
      );
    }
  }
}
