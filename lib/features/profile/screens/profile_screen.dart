import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser.when(
            data: (user) => user?.username ?? '프로필',
            loading: () => '로딩...',
            error: (_, __) => '프로필',
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _showSettingsBottomSheet(context, ref);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '프로필 화면',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('저장됨'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('다크 모드'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(authNotifierProvider.notifier).signOut();
                context.go(RouteConstants.loginPath);
              },
            ),
          ],
        ),
      ),
    );
  }
}
