import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '메시지',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              // TODO: 새 메시지 작성
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '채팅 화면',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
