import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Supabase 클라이언트 인스턴스
  static SupabaseClient get client => Supabase.instance.client;

  // 현재 로그인된 사용자
  static User? get currentUser => client.auth.currentUser;

  // 인증 상태 스트림
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // 로그인 여부 확인
  static bool get isLoggedIn => currentUser != null;
}
