import 'package:chat_bot_gemini_ai/repositories/auth_repository.dart';
import 'package:chat_bot_gemini_ai/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatProvider = Provider(
  (ref) => ChatRepository(),
);

final authProvider = Provider(
  (ref) => AuthRepository(),
);
