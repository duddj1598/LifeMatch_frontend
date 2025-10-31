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

  // --- 오류 메시지 초기값을 null로 변경 ---
  String? _idError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? _selectedQuestion;
  final List<String> _questions = [
    '가장 기억에 남는 추억의 장소는?',
    '자신의 보물 제1호는?',
    '가장 좋아하는 반려동물의 이름은?',
  ];

  bool _agreeToTerms = false;

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

  // --- 로그인 화면 스타일과 일치하는 InputDecoration 정의 ---
  InputDecoration _buildInputDecoration(String hintText, {Widget? prefixIcon, String? errorText, Color? errorBorderColor}) {
    // 기본 에러 보더 (빨간색)
    var errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    );
    // 포커스된 에러 보더
    var focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 2.0),
    );

    // 특별 케이스 (파란색 에러 보더)
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
  // --- 스타일 정의 끝 ---


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
                // 1. 회원가입 제목 (로그인 타이틀 스타일 적용)
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

                // 2. 아이디
                _buildLabel("아이디"),
                _buildIdField(),
                const SizedBox(height: 16),

                // 3. 비밀번호
                _buildLabel("비밀번호"),
                _buildPasswordField(),
                const SizedBox(height: 16),

                // 4. 비밀번호 확인
                _buildLabel("비밀번호 확인"),
                _buildPasswordConfirmField(),
                const SizedBox(height: 16),

                // 5. 닉네임
                _buildLabel("닉네임"),
                _buildNicknameField(),
                const SizedBox(height: 16),

                // 6. 주소
                _buildLabel("주소"),
                _buildAddressField(),
                const SizedBox(height: 16),

                // 7. 이메일 주소
                _buildLabel("이메일 주소"),
                _buildEmailField(),
                const SizedBox(height: 16),

                // 8. 생년월일
                _buildLabel("생년월일"),
                _buildBirthdateField(),
                const SizedBox(height: 16),

                // 9. 본인 확인 질문
                _buildLabel("본인 확인 질문"),
                _buildSecurityQuestionField(),
                const SizedBox(height: 16),

                // 10. 본인 확인 답변
                _buildLabel("본인 확인 답변"),
                _buildSecurityAnswerField(),
                const SizedBox(height: 16),

                // 11. 약관 전체동의 (변경됨)
                _buildTermsAgreement(),
                const SizedBox(height: 32),

                // 12. 가입하기 버튼
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 위젯 빌드 함수들 ---

  // 공통 라벨 위젯
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 아이디 입력 필드
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

  // 비밀번호 입력 필드
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
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
      ),
    );
  }

  // 비밀번호 확인 필드
  Widget _buildPasswordConfirmField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: true,
      onChanged: (value) {
        _validateConfirmPassword();
      },
      decoration: _buildInputDecoration(
        "비밀번호 재입력",
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: _confirmPasswordError,
        errorBorderColor: _confirmPasswordError != null ? Colors.blue : null,
      ),
    );
  }

  // 닉네임 입력 필드
  Widget _buildNicknameField() {
    return TextField(
      decoration: _buildInputDecoration(
        "닉네임을 입력해주세요",
        prefixIcon: const Icon(Icons.badge_outlined),
      ),
    );
  }

  // 주소 입력 필드
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

  // 이메일 입력 필드
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
            decoration: _buildInputDecoration(
              "도메인",
            ),
          ),
        ),
      ],
    );
  }

  // 생년월일 입력 필드
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

  // 본인 확인 질문 필드 (드롭다운)
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

  // 본인 확인 답변 필드
  Widget _buildSecurityAnswerField() {
    return TextField(
      decoration: _buildInputDecoration(
        "확인 답변을 입력해주세요",
        prefixIcon: const Icon(Icons.question_answer_outlined),
      ),
    );
  }

  // 11. 약관 전체동의 (변경됨 - 체크박스를 박스 안으로)
  Widget _buildTermsAgreement() {
    return Container(
      // 1. 전체 박스 스타일 (로그인 입력창 스타일)
      height: 200, // 박스 전체 높이 (텍스트 + 체크박스)
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 2. 약관 내용 (스크롤 가능 영역)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // 하단 패딩 0
              child: SingleChildScrollView(
                child: Text(
                  "약관 내용 삽입\n\n" * 20, // 임시 텍스트
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ),
          ),

          // 구분선 (선택 사항이지만, 시각적으로 좋습니다)
          const Divider(color: Colors.black26, height: 1, indent: 16, endIndent: 16),

          // 3. 약관 동의 체크박스 (박스 하단 고정)
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

  // 가입하기 버튼
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 회원가입 로직
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
          style: TextStyle(
            fontSize: 23,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}