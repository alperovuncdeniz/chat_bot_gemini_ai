import 'package:chat_bot_gemini_ai/providers/providers.dart';
import 'package:chat_bot_gemini_ai/screens/send_image_screen.dart';
import 'package:chat_bot_gemini_ai/widgets/messages_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _messageController;
  final apiKey = dotenv.env["API_KEY"] ?? "";

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Consumer(builder: (context, ref, child) {
            return IconButton(
              onPressed: () {
                ref.read(authProvider).singout();
              },
              icon: const Icon(Icons.logout),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          children: [
            Expanded(
              child: MessagesList(
                userId: FirebaseAuth.instance.currentUser!.uid,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Ask any question"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SendImageScreen(),
                      ));
                    },
                    icon: const Icon(Icons.image),
                  ),
                  IconButton(
                    onPressed: () async {
                      await ref.read(chatProvider).sendTextMessage(
                            textPromt: _messageController.text,
                            apiKey: apiKey,
                          );
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
