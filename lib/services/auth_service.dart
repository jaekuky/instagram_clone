import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 인증 메서드
  // ──────────────────────────────────────────

  /// 이메일 & 비밀번호로 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'display_name': fullName,
      },
    );
    return response;
  }

  /// 이메일 & 비밀번호로 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 비밀번호 재설정 이메일 발송
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// 현재 세션 가져오기
  Session? get currentSession => _client.auth.currentSession;

  /// 현재 Supabase Auth 사용자
  User? get currentUser => _client.auth.currentUser;

  /// 인증 상태 변경 스트림
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // ──────────────────────────────────────────
  // 프로필 메서드 (profiles 테이블)
  // ──────────────────────────────────────────

  /// 현재 로그인된 사용자의 프로필 가져오기
  Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 특정 사용자 프로필 가져오기 (by ID)
  Future<UserModel?> getProfileById(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 특정 사용자 프로필 가져오기 (by username)
  Future<UserModel?> getProfileByUsername(String username) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('username', username)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 프로필 업데이트
  Future<UserModel?> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? website,
  }) async {
    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (fullName != null) updates['full_name'] = fullName;
    if (bio != null) updates['bio'] = bio;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (website != null) updates['website'] = website;

    if (updates.isEmpty) return null;

    try {
      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// username 중복 확인
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final data = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      return data == null;
    } catch (e) {
      return false;
    }
  }
}
