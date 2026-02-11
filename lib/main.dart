import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 환경변수 로드
  await dotenv.load(fileName: '.env');

  // 2. Supabase 초기화
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // 3. Riverpod ProviderScope로 앱 실행
  runApp(
    const ProviderScope(
      child: InstaCloneApp(),
    ),
  );
}

class InstaCloneApp extends ConsumerStatefulWidget {
  const InstaCloneApp({super.key});

  @override
  ConsumerState<InstaCloneApp> createState() => _InstaCloneAppState();
}

class _InstaCloneAppState extends ConsumerState<InstaCloneApp> {
  // ThemeProvider는 간단한 로컬 상태이므로 그대로 유지
  final _themeProvider = ThemeProvider();

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Instagram Clone',
          debugShowCheckedModeBanner: false,

          // 테마 설정
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeProvider.themeMode,

          // GoRouter 라우팅 (Riverpod 연동)
          routerConfig: router,
        );
      },
    );
  }
}
