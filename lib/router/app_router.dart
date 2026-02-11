import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/route_constants.dart';
import '../core/widgets/main_shell.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/feed/screens/feed_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/upload/screens/upload_screen.dart';
import '../services/supabase_service.dart';

// ──────────────────────────────────────────
// GoRouter 프로바이더 (Riverpod 연동)
// ──────────────────────────────────────────
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthRouterNotifier();

  ref.onDispose(() => authNotifier.dispose());

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.feedPath,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,

    // 인증 상태에 따라 리다이렉트
    redirect: (context, state) {
      final isLoggedIn = SupabaseService.isLoggedIn;
      final isAuthRoute =
          state.matchedLocation == RouteConstants.loginPath ||
              state.matchedLocation == RouteConstants.signUpPath;

      // 로그인하지 않은 상태에서 인증 화면이 아니면 로그인으로 리다이렉트
      if (!isLoggedIn && !isAuthRoute) {
        return RouteConstants.loginPath;
      }

      // 이미 로그인한 상태에서 인증 화면에 접근하면 피드로 리다이렉트
      if (isLoggedIn && isAuthRoute) {
        return RouteConstants.feedPath;
      }

      return null;
    },

    routes: [
      // ──────────────────────────────────────────
      // 인증 관련 라우트
      // ──────────────────────────────────────────
      GoRoute(
        path: RouteConstants.loginPath,
        name: RouteConstants.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteConstants.signUpPath,
        name: RouteConstants.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),

      // ──────────────────────────────────────────
      // 채팅 (전체 화면)
      // ──────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteConstants.chatPath,
        name: RouteConstants.chat,
        builder: (context, state) => const ChatScreen(),
      ),

      // ──────────────────────────────────────────
      // 메인 Shell (하단 네비게이션 바 포함)
      // ──────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // 피드 탭
          StatefulShellBranch(
            navigatorKey: _shellNavigatorFeedKey,
            routes: [
              GoRoute(
                path: RouteConstants.feedPath,
                name: RouteConstants.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),

          // 검색 탭
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: RouteConstants.searchPath,
                name: RouteConstants.search,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          // 업로드 탭
          StatefulShellBranch(
            navigatorKey: _shellNavigatorUploadKey,
            routes: [
              GoRoute(
                path: RouteConstants.uploadPath,
                name: RouteConstants.upload,
                builder: (context, state) => const UploadScreen(),
              ),
            ],
          ),

          // 알림 탭
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNotificationsKey,
            routes: [
              GoRoute(
                path: RouteConstants.notificationsPath,
                name: RouteConstants.notifications,
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),

          // 프로필 탭
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: RouteConstants.profilePath,
                name: RouteConstants.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '페이지를 찾을 수 없습니다.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.feedPath),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ──────────────────────────────────────────
// Navigator Keys
// ──────────────────────────────────────────
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorFeedKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellFeed');
final _shellNavigatorSearchKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSearch');
final _shellNavigatorUploadKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellUpload');
final _shellNavigatorNotificationsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellNotifications');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

// ──────────────────────────────────────────
// Auth Router Notifier
// Supabase 인증 상태 변경 시 GoRouter에게 리프레시 알림
// ──────────────────────────────────────────
class AuthRouterNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthRouterNotifier() {
    _subscription =
        SupabaseService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
