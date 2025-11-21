import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifematch_frontend/features/auth/viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- 컨트롤러 ---
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _directQuestionController = TextEditingController();

  final _nicknameController = TextEditingController();
  final _emailIdController = TextEditingController();
  final _emailDomainController = TextEditingController();
  final _securityAnswerController = TextEditingController();

  // --- 상태 변수 ---
  String? _idError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _nicknameError;
  String? _emailError;

  bool _isNicknameChecked = false;
  bool _isEmailChecked = false;
  bool _agreeToTerms = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isDirectQuestion = false;

  String? _selectedQuestion;

  final List<String> _questions = [
    '가장 기억에 남는 추억의 장소는?',
    '자신의 보물 제1호는?',
    '가장 좋아하는 반려동물의 이름은?',
    '직접 질문 입력',
  ];

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _directQuestionController.dispose();
    _nicknameController.dispose();
    _emailIdController.dispose();
    _emailDomainController.dispose();
    _securityAnswerController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // ⭐ 비밀번호 재확인 로직
  // --------------------------------------------------
  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() {
      if (confirm.isNotEmpty && password != confirm) {
        _confirmPasswordError = "비밀번호가 일치하지 않습니다.";
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  // --------------------------------------------------
  // ⭐ 닉네임 중복 확인 (현재는 로컬 시뮬레이션)
  // --------------------------------------------------
  Future<void> _checkNicknameAvailability() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      setState(() => _nicknameError = "닉네임을 입력해주세요.");
      return;
    }

    if (nickname == "admin") {
      setState(() {
        _nicknameError = "이미 사용 중인 닉네임입니다.";
        _isNicknameChecked = false;
      });
    } else {
      setState(() {
        _nicknameError = null;
        _isNicknameChecked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 닉네임입니다."), backgroundColor: Colors.green),
      );
    }
  }

  // --------------------------------------------------
  // ⭐ 이메일 중복 확인 (현재는 로컬 시뮬레이션)
  // --------------------------------------------------
  Future<void> _checkEmailAvailability() async {
    if (_emailIdController.text.isEmpty ||
        _emailDomainController.text.isEmpty) {
      setState(() {
        _emailError = "이메일을 모두 입력해주세요.";
      });
      return;
    }

    final email = "${_emailIdController.text}@${_emailDomainController.text}";

    if (email == "test@test.com") {
      setState(() {
        _emailError = "이미 사용 중인 이메일입니다.";
        _isEmailChecked = false;
      });
    } else {
      setState(() {
        _emailError = null;
        _isEmailChecked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 이메일입니다."), backgroundColor: Colors.green),
      );
    }
  }

  // --------------------------------------------------
  // ⭐ 회원가입 처리
  // --------------------------------------------------
  Future<void> _handleSubmit() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (viewModel.isLoading) return;

    // 필수 유효성 검사
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "비밀번호가 일치하지 않습니다.");
      return;
    }
    if (_passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호 형식을 확인해주세요.")),
      );
      return;
    }
    if (!_isNicknameChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임 중복 확인을 해주세요.")),
      );
      return;
    }
    if (!_isEmailChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일 중복 확인을 해주세요.")),
      );
      return;
    }
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("약관에 동의해주세요.")),
      );
      return;
    }

    final email =
    "${_emailIdController.text}@${_emailDomainController.text}".trim();

    final securityQuestion = _isDirectQuestion
        ? _directQuestionController.text.trim()
        : _selectedQuestion ?? "";

    final success = await viewModel.signup(
      userId: _idController.text.trim(),
      email: email,
      nickname: _nicknameController.text.trim(),
      password: _passwordController.text.trim(),
      securityQuestion: securityQuestion,
      securityAnswer: _securityAnswerController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("회원가입이 완료되었습니다. 로그인해주세요."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "회원가입 실패"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --------------------------------------------------
  // ⭐ 공통 InputDecoration
  // --------------------------------------------------
  InputDecoration _buildInputDecoration(String hint,
      {Widget? prefixIcon, String? errorText}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFD9D9D9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, height: 0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  // --------------------------------------------------
  // ⭐ 전체 UI 구성
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "회원가입",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),

      // ---------------------------------------------
      // Body
      // ---------------------------------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------------- 아이디 ----------------
            _buildLabel("아이디"),
            _buildIdField(),
            const SizedBox(height: 16),

            // ---------------- 비밀번호 ----------------
            _buildLabel("비밀번호"),
            _buildPasswordField(),
            const SizedBox(height: 16),

            // ---------------- 비밀번호 확인 ----------------
            _buildLabel("비밀번호 확인"),
            _buildPasswordConfirmField(),
            const SizedBox(height: 16),

            // ---------------- 닉네임 ----------------
            _buildLabel("닉네임"),
            _buildNicknameField(),
            const SizedBox(height: 16),

            // ---------------- 이메일 ----------------
            _buildLabel("이메일 주소"),
            _buildEmailField(),
            const SizedBox(height: 16),

            // ---------------- 본인확인 질문 ----------------
            _buildLabel("본인 확인 질문"),
            _buildSecurityQuestionField(),
            const SizedBox(height: 16),

            // ---------------- 본인확인 답변 ----------------
            _buildLabel("본인 확인 답변"),
            _buildSecurityAnswerField(),
            const SizedBox(height: 16),

            // ---------------- 약관 ----------------
            _buildTermsAgreement(),
            const SizedBox(height: 24),

            // ---------------- 제출 버튼 ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AA8DA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "가입하기",
                  style: TextStyle(fontSize: 23, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------
  // ✨ 아래는 오리지널 UI 구성 함수들 그대로 유지
  // ------------------------------------------------------

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildIdField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _idController,
            decoration: _buildInputDecoration(
              "아이디 입력",
              prefixIcon: const Icon(Icons.person_outline),
              errorText: _idError,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            final id = _idController.text.trim();
            setState(() {
              if (id.isEmpty) {
                _idError = "아이디를 입력해주세요.";
              } else if (id == "admin") {
                _idError = "이미 사용 중입니다.";
              } else {
                _idError = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("사용 가능한 아이디입니다."), backgroundColor: Colors.green),
                );
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB0BEC5),
            foregroundColor: Colors.black,
            elevation: 0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          child: const Text("확인"),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _buildInputDecoration(
        "비밀번호 입력",
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _passwordError,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6B7AA1),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      onChanged: (_) => _validateConfirmPassword(),
    );
  }

  Widget _buildPasswordConfirmField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: _buildInputDecoration(
        "비밀번호 재입력",
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _confirmPasswordError,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6B7AA1),
          ),
          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      onChanged: (_) => _validateConfirmPassword(),
    );
  }

  Widget _buildNicknameField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _nicknameController,
            decoration: _buildInputDecoration(
              "닉네임 입력",
              prefixIcon: const Icon(Icons.badge_outlined),
              errorText: _nicknameError,
            ),
            onChanged: (_) => setState(() {
              if (_isNicknameChecked) _isNicknameChecked = false;
            }),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _checkNicknameAvailability,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            _isNicknameChecked ? Colors.green : const Color(0xFFB0BEC5),
            foregroundColor: Colors.black,
            elevation: 0,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(_isNicknameChecked ? "완료" : "확인"),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _emailIdController,
                decoration: _buildInputDecoration(
                  "이메일 ID",
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                onChanged: (_) {
                  if (_isEmailChecked) setState(() => _isEmailChecked = false);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("@"),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _emailDomainController,
                decoration: _buildInputDecoration("도메인"),
                onChanged: (_) {
                  if (_isEmailChecked) setState(() => _isEmailChecked = false);
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _checkEmailAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _isEmailChecked ? Colors.green : const Color(0xFFB0BEC5),
                foregroundColor: Colors.black,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isEmailChecked ? "완료" : "확인"),
            ),
          ],
        ),
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              _emailError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSecurityQuestionField() {
    if (_isDirectQuestion) {
      return TextField(
        controller: _directQuestionController,
        decoration: _buildInputDecoration(
          "질문 입력",
          prefixIcon: const Icon(Icons.edit_note_outlined),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedQuestion,
      decoration: _buildInputDecoration(
        "",
        prefixIcon: const Icon(Icons.quiz_outlined),
      ),
      items: _questions
          .map((q) => DropdownMenuItem(value: q, child: Text(q)))
          .toList(),
      onChanged: (v) {
        setState(() {
          if (v == "직접 질문 입력") {
            _isDirectQuestion = true;
            _selectedQuestion = null;
          } else {
            _isDirectQuestion = false;
            _selectedQuestion = v;
          }
        });
      },
    );
  }

  Widget _buildSecurityAnswerField() {
    return TextField(
      controller: _securityAnswerController,
      decoration: _buildInputDecoration(
        "답변 입력",
        prefixIcon: const Icon(Icons.question_answer_outlined),
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
           Expanded(
            child: SingleChildScrollView(
              child: Text(
                "약관 내용\n" * 10,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
              ),
              const Text("약관 전체 동의", style: TextStyle(fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
