import 'package:chat_bot_gemini_ai/extensions/extensions.dart';
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

    //Save message to Firebase
    await _firestore
        .collection("conversations")
        .doc(userId)
        .collection("messages")
        .doc(sentMessageId)
        .set(message.toMap());

    GenerateContentResponse response;

    try {
      if (image == null) {
        response = await textModel.generateContent([Content.text(promptText)]);
      } else {
        final imageBytes = await image.readAsBytes();

        final promt = TextPart(promptText);

        final mimeType = image.getMimeTypeFromExtension();
        final imagePart = DataPart(mimeType, imageBytes);

        response = await imageModel.generateContent([
          Content.multi([
            promt,
            imagePart,
          ])
        ]);
      }

      final responseText = response.text;

      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      await _firestore
          .collection("conversations")
          .doc(userId)
          .collection("messages")
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future sendTextMessage({
    required String textPromt,
    required String apiKey,
  }) async {
    try {
      final textModel = GenerativeModel(model: "gemini-pro", apiKey: apiKey);

      final userId = _auth.currentUser!.uid;
      final sentMessageId = const Uuid().v4();

      Message message = Message(
        id: sentMessageId,
        message: textPromt,
        createdAt: DateTime.now(),
        isMine: true,
      );

      await _firestore
          .collection("conversations")
          .doc(userId)
          .collection("messages")
          .doc(sentMessageId)
          .set(message.toMap());

      final response =
          await textModel.generateContent([Content.text(textPromt)]);

      final responseText = response.text;

      final receivedMessageId = const Uuid().v4();

      final responseMessage = Message(
        id: receivedMessageId,
        message: responseText!,
        createdAt: DateTime.now(),
        isMine: false,
      );

      await _firestore
          .collection("conversations")
          .doc(userId)
          .collection("messages")
          .doc(receivedMessageId)
          .set(responseMessage.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
