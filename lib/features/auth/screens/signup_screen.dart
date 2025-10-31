import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- 컨트롤러 추가 ---
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- 오류 메시지 초기값 ---
  String? _idError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? _selectedQuestion;
  final List<String> _questions = [
    '가장 기억에 남는 추억의 장소는?',
    '자신의 보물 제1호는?',
    '가장 좋아하는 반려동물의 이름은?',
    '직접 질문 입력',
  ];

  bool _agreeToTerms = false;

  // 👁️ 비밀번호 표시 상태 변수 추가
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // --- 컨트롤러 메모리 해제 ---
  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- 비밀번호 일치 검사 로직 ---
  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      setState(() {
        _confirmPasswordError = "비밀번호가 일치하지 않습니다";
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
      });
    }
  }

  // --- 공통 InputDecoration 정의 ---
  InputDecoration _buildInputDecoration(String hintText,
      {Widget? prefixIcon,
        String? errorText,
        Color? errorBorderColor}) {
    var errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    );
    var focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    );

    if (errorBorderColor != null) {
      errorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorBorderColor, width: 2.0),
      );
      focusedErrorBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: errorBorderColor, width: 2.0),
      );
    }

    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFD9D9D9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, height: 0.9),
      errorBorder: errorBorder,
      focusedErrorBorder: focusedErrorBorder,
    );
  }

  // --- 본문 빌드 ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "회원가입",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7AA1),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                _buildLabel("아이디"),
                _buildIdField(),
                const SizedBox(height: 16),

                _buildLabel("비밀번호"),
                _buildPasswordField(),
                const SizedBox(height: 16),

                _buildLabel("비밀번호 확인"),
                _buildPasswordConfirmField(),
                const SizedBox(height: 16),

                _buildLabel("닉네임"),
                _buildNicknameField(),
                const SizedBox(height: 16),

                _buildLabel("주소"),
                _buildAddressField(),
                const SizedBox(height: 16),

                _buildLabel("이메일 주소"),
                _buildEmailField(),
                const SizedBox(height: 16),

                _buildLabel("생년월일"),
                _buildBirthdateField(),
                const SizedBox(height: 16),

                _buildLabel("본인 확인 질문"),
                _buildSecurityQuestionField(),
                const SizedBox(height: 16),

                _buildLabel("본인 확인 답변"),
                _buildSecurityAnswerField(),
                const SizedBox(height: 16),

                _buildTermsAgreement(),
                const SizedBox(height: 32),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 공통 라벨 ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- 아이디 입력 필드 ---
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
            final id = _idController.text;
            setState(() {
              if (id.isEmpty) {
                _idError = "아이디를 입력해주세요.";
              } else if (id == "admin") {
                _idError = "사용할 수 없는 아이디입니다";
              } else {
                _idError = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("사용 가능한 아이디입니다."),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB0BEC5),
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("중복 확인"),
        ),
      ],
    );
  }

  // --- 비밀번호 입력 필드 👁️ 눈 아이콘 추가 ---
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      onChanged: (password) {
        setState(() {
          if (password.isEmpty) {
            _passwordError = null;
          } else if (password.length < 8 || password.length > 20) {
            _passwordError = "비밀번호는 8~20자 사이여야 합니다.";
          } else {
            _passwordError = null;
          }
          _validateConfirmPassword();
        });
      },
      decoration: _buildInputDecoration(
        "비밀번호 입력 (문자, 숫자, 특수문자 포함 8~20자)",
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _passwordError,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: const Color(0xFF6B7AA1),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  // --- 비밀번호 확인 필드 👁️ 눈 아이콘 추가 ---
  Widget _buildPasswordConfirmField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      onChanged: (value) {
        _validateConfirmPassword();
      },
      decoration: _buildInputDecoration(
        "비밀번호 재입력",
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _confirmPasswordError,
        errorBorderColor: _confirmPasswordError != null ? Colors.blue : null,
      ).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: const Color(0xFF6B7AA1),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
    );
  }

  // --- 나머지 필드들은 그대로 유지 ---
  Widget _buildNicknameField() => TextField(
    decoration: _buildInputDecoration(
      "닉네임을 입력해주세요",
      prefixIcon: const Icon(Icons.badge_outlined),
    ),
  );

  Widget _buildAddressField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: _buildInputDecoration(
              "",
              prefixIcon: const Icon(Icons.home_outlined),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9AA8DA),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("주소 검색"),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: _buildInputDecoration(
              "이메일 주소",
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text("@", style: TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: TextField(
            decoration: _buildInputDecoration("도메인"),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdateField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration(
              "년도",
              prefixIcon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration("월"),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration("일"),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityQuestionField() {
    return DropdownButtonFormField<String>(
      value: _selectedQuestion,
      hint: const Text("질문을 선택해주세요."),
      decoration: _buildInputDecoration(
        "",
        prefixIcon: const Icon(Icons.quiz_outlined),
      ),
      items: _questions.map((String question) {
        return DropdownMenuItem<String>(
          value: question,
          child: Text(question),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedQuestion = newValue;
        });
      },
    );
  }

  Widget _buildSecurityAnswerField() {
    return TextField(
      decoration: _buildInputDecoration(
        "확인 답변을 입력해주세요",
        prefixIcon: const Icon(Icons.question_answer_outlined),
      ),
    );
  }

  Widget _buildTermsAgreement() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SingleChildScrollView(
                child: Text(
                  "약관 내용 삽입\n\n" * 20,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.black26, height: 1, indent: 16, endIndent: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (bool? value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeToTerms = !_agreeToTerms;
                  });
                },
                child: const Text(
                  "약관 전체동의",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 회원가입 로직 유지
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9AA8DA),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "가입하기",
          style: TextStyle(fontSize: 23, color: Colors.white),
        ),
      ),
    );
  }
}
