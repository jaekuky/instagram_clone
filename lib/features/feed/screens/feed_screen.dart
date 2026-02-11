import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: 좋아요 알림 화면
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // TODO: 채팅 화면으로 이동
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '피드 화면',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
