import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    final success = await notifier.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
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

  /// 데스크탑: 중앙 정렬 카드 형태
  Widget _buildDesktopLayout(bool isDark, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSignUpCard(isDark, isLoading),
          const SizedBox(height: 12),
          _buildLoginCard(isDark),
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
            _buildLogo(),
            const SizedBox(height: 12),
            _buildSubtitle(),
            const SizedBox(height: 32),
            _buildSignUpForm(isLoading),
            const SizedBox(height: 16),
            _buildTermsText(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  /// 회원가입 카드 (데스크탑용)
  Widget _buildSignUpCard(bool isDark, bool isLoading) {
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
          const SizedBox(height: 12),
          _buildSubtitle(),
          const SizedBox(height: 28),
          _buildSignUpForm(isLoading),
          const SizedBox(height: 16),
          _buildTermsText(),
        ],
      ),
    );
  }

  /// 로그인 카드 (데스크탑용)
  Widget _buildLoginCard(bool isDark) {
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
      child: _buildLoginLink(),
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

  Widget _buildSubtitle() {
    return Text(
      '친구들의 사진과 동영상을 보려면\n가입하세요.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
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
          // 성명
          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: '성명',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '성명을 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          // 사용자 이름
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: '사용자 이름',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '사용자 이름을 입력해주세요.';
              }
              if (!Helpers.isValidUsername(value)) {
                return '영문, 숫자, 마침표, 밑줄만 사용 가능합니다 (3~30자).';
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
            onFieldSubmitted: (_) => _handleSignUp(),
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
          // 가입 버튼
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSignUp,
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
                      '가입',
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

  Widget _buildTermsText() {
    return Text(
      '가입하면 Instagram의 약관, 데이터 정책 및\n쿠키 정책에 동의하게 됩니다.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[500],
        fontSize: 12,
        height: 1.4,
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

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 있으신가요? ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => context.go(RouteConstants.loginPath),
          child: const Text(
            '로그인',
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
