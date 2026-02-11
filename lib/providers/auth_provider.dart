import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user_model.dart';
import '../services/auth_service.dart';

// ──────────────────────────────────────────
// AuthService 인스턴스 프로바이더
// ──────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ──────────────────────────────────────────
// 인증 상태 스트림 프로바이더
// (Supabase auth state change를 실시간 감지)
// ──────────────────────────────────────────
final authStateProvider = StreamProvider<supabase.AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.onAuthStateChange;
});

// ──────────────────────────────────────────
// 현재 유저 프로필 프로바이더
// (인증 상태가 변할 때마다 자동으로 프로필을 가져옴)
// ──────────────────────────────────────────
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) async {
      if (state.session?.user != null) {
        final authService = ref.read(authServiceProvider);
        return await authService.getCurrentUserProfile();
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// ──────────────────────────────────────────
// 인증 여부 간편 프로바이더
// ──────────────────────────────────────────
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session != null,
    loading: () {
      // 스트림 로딩 중에도 현재 세션 확인
      final authService = ref.read(authServiceProvider);
      return authService.currentUser != null;
    },
    error: (_, __) => false,
  );
});

// ──────────────────────────────────────────
// 인증 액션 상태
// ──────────────────────────────────────────

enum AuthActionStatus {
  initial,
  loading,
  success,
  error,
}

class AuthActionState {
  final AuthActionStatus status;
  final String? errorMessage;

  const AuthActionState({
    this.status = AuthActionStatus.initial,
    this.errorMessage,
  });

  AuthActionState copyWith({
    AuthActionStatus? status,
    String? errorMessage,
  }) {
    return AuthActionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

// ──────────────────────────────────────────
// AuthNotifier: 로그인/회원가입/로그아웃 액션
// ──────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthActionState> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref)
      : super(const AuthActionState());

  /// 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      state = state.copyWith(
        status: AuthActionStatus.loading,
        errorMessage: null,
      );

      final response = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );

      if (response.user != null) {
        state = state.copyWith(status: AuthActionStatus.success);
        _ref.invalidate(currentUserProvider);
        return true;
      } else {
        state = state.copyWith(
          status: AuthActionStatus.error,
          errorMessage: '회원가입에 실패했습니다.',
        );
        return false;
      }
    } on supabase.AuthException catch (e) {
      state = state.copyWith(
        status: AuthActionStatus.error,
        errorMessage: _translateAuthError(e.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthActionStatus.error,
        errorMessage: '알 수 없는 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 로그인
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(
        status: AuthActionStatus.loading,
        errorMessage: null,
      );

      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = state.copyWith(status: AuthActionStatus.success);
        _ref.invalidate(currentUserProvider);
        return true;
      } else {
        state = state.copyWith(
          status: AuthActionStatus.error,
          errorMessage: '로그인에 실패했습니다.',
        );
        return false;
      }
    } on supabase.AuthException catch (e) {
      state = state.copyWith(
        status: AuthActionStatus.error,
        errorMessage: _translateAuthError(e.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthActionStatus.error,
        errorMessage: '알 수 없는 오류가 발생했습니다.',
      );
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    state = state.copyWith(
      status: AuthActionStatus.initial,
      errorMessage: null,
    );
    _ref.invalidate(currentUserProvider);
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(
      status: AuthActionStatus.initial,
      errorMessage: null,
    );
  }

  /// Supabase 에러 메시지를 한국어로 변환
  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (message.contains('Email not confirmed')) {
      return '이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요.';
    }
    if (message.contains('User already registered')) {
      return '이미 등록된 이메일입니다.';
    }
    if (message.contains('Password should be at least')) {
      return '비밀번호는 최소 6자 이상이어야 합니다.';
    }
    if (message.contains('rate limit')) {
      return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
    }
    return message;
  }
}

// AuthNotifier 프로바이더
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthActionState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
