import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    final success = await notifier.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      if (success) {
        context.go(RouteConstants.feedPath);
      } else {
        final errorMsg = ref.read(authNotifierProvider).errorMessage;
        if (errorMsg != null) {
          Helpers.showSnackBar(context, errorMsg, isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthActionStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: isDesktop
              ? _buildDesktopLayout(isDark, isLoading)
              : _buildMobileLayout(isDark, isLoading),
        ),
      ),
    );
  }

  /// 데스크탑: 폰 목업 + 카드 형태
  Widget _buildDesktopLayout(bool isDark, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 왼쪽 - 폰 목업 이미지 영역
          _buildPhoneMockup(isDark),
          const SizedBox(width: 32),
          // 오른쪽 - 로그인 카드
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoginCard(isDark, isLoading),
              const SizedBox(height: 12),
              _buildSignUpCard(isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// 모바일: 전체 화면
  Widget _buildMobileLayout(bool isDark, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instagram 로고
            _buildLogo(),
            const SizedBox(height: 40),
            // 로그인 폼
            _buildLoginForm(isLoading),
            const SizedBox(height: 24),
            // 비밀번호 찾기
            _buildForgotPassword(),
            const SizedBox(height: 24),
            // 구분선
            _buildDivider(),
            const SizedBox(height: 24),
            // 회원가입 링크
            _buildSignUpLink(),
          ],
        ),
      ),
    );
  }

  /// 폰 목업 (데스크탑용)
  Widget _buildPhoneMockup(bool isDark) {
    return Container(
      width: 380,
      height: 580,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.instagramGradient[2].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 폰 프레임
          Container(
            width: 260,
            height: 480,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(33),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instagram 로고
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.instagramGradient,
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ).createShader(bounds),
                    child: Text(
                      'Instagram',
                      style: GoogleFonts.grandHotel(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 가짜 포스트 카드들
                  _buildMockPost(isDark),
                  const SizedBox(height: 12),
                  _buildMockPost(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 가짜 포스트 (목업)
  Widget _buildMockPost(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.storyRingGradient,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[700]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  Colors.grey[isDark ? 800 : 200]!,
                  Colors.grey[isDark ? 700 : 100]!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로그인 카드 (데스크탑용)
  Widget _buildLoginCard(bool isDark, bool isLoading) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          _buildLogo(),
          const SizedBox(height: 36),
          _buildLoginForm(isLoading),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildForgotPassword(),
        ],
      ),
    );
  }

  /// 회원가입 카드 (데스크탑용)
  Widget _buildSignUpCard(bool isDark) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: _buildSignUpLink(),
    );
  }

  // ──────────────────────────────────────────
  // 공통 위젯들
  // ──────────────────────────────────────────

  Widget _buildLogo() {
    return Text(
      'Instagram',
      style: GoogleFonts.grandHotel(
        fontSize: 48,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 이메일
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: '이메일 주소',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요.';
              }
              if (!Helpers.isValidEmail(value)) {
                return '올바른 이메일 형식이 아닙니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          // 비밀번호
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              hintText: '비밀번호',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.grey[500],
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요.';
              }
              if (!Helpers.isValidPassword(value)) {
                return '비밀번호는 6자 이상이어야 합니다.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        // TODO: 비밀번호 재설정
      },
      child: const Text(
        '비밀번호를 잊으셨나요?',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => context.go(RouteConstants.signUpPath),
          child: const Text(
            '가입하기',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
