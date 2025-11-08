import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ⭐️ ViewModel 임포트 (기존 코드의 경로 사용)
import 'package:lifematch_frontend/features/auth/viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- 컨트롤러 ---
  final _idController = TextEditingController(); // (기존 UI용)
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _directQuestionController = TextEditingController(); // (기존 UI용)

  // --- ⭐️ 수정 1: ViewModel에 전달할 컨트롤러 추가 ---
  final _nicknameController = TextEditingController();
  final _emailIdController = TextEditingController(); // 이메일 ID
  final _emailDomainController = TextEditingController(); // 이메일 도메인
  // ---

  // --- 상태 변수 ---
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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isDirectQuestion = false;

  // --- 메모리 해제 ---
  @override
  void dispose() {
    // --- ⭐️ 수정 2: 모든 컨트롤러 해제 ---
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _directQuestionController.dispose();
    _nicknameController.dispose(); // 추가
    _emailIdController.dispose(); // 추가
    _emailDomainController.dispose(); // 추가
    super.dispose();
  }

  // --- ⭐️ 추가 3: ViewModel 호출 함수 (handleSubmit) ---
  Future<void> _handleSubmit() async {
    // ViewModel 인스턴스 가져오기 (이벤트 처리는 listen: false)
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);

    // 로딩 중이면 중복 클릭 방지
    if (viewModel.isLoading) return;

    // --- (기존 유효성 검사 로직은 그대로 사용) ---
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() { _confirmPasswordError = "비밀번호가 일치하지 않습니다."; });
      return;
    }
    // (비밀번호 형식 검사)
    if (_passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("비밀번호 형식을 확인해주세요.")));
      return;
    }
    // ⭐️ 닉네임 검사
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("닉네임을 입력해주세요.")));
      return;
    }
    // ⭐️ 이메일 검사
    if (_emailIdController.text.isEmpty || _emailDomainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이메일을 입력해주세요.")));
      return;
    }
    // ⭐️ 약관 동의 검사
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("약관에 동의해주세요.")));
      return;
    }
    // --- (유효성 검사 끝) ---

    // 이메일 조합
    final String email = "${_emailIdController.text}@${_emailDomainController.text}";

    // ⭐️ ViewModel의 signup 함수 호출 (user_schema.py 명세 기준)
    final bool success = await viewModel.signup(
      email: email,
      nickname: _nicknameController.text,
      password: _passwordController.text,
    );

    // ⭐️ 결과 처리 (비동기 경계에서 mounted 확인)
    if (!mounted) return;

    if (success) {
      // 성공 시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("회원가입에 성공했습니다. 로그인해주세요."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login'); // 로그인 화면으로 이동
    } else {
      // 실패 시 (ViewModel에 저장된 에러 메시지 표시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? "회원가입 실패"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // ---

  // --- 비밀번호 확인 로직 (기존과 동일) ---
  void _validateConfirmPassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _confirmPasswordError =
      (confirmPassword.isNotEmpty && password != confirmPassword)
          ? "비밀번호가 일치하지 않습니다"
          : null;
    });
  }

  // --- 입력 필드 공통 데코레이션 (기존과 동일) ---
  InputDecoration _buildInputDecoration(String hintText,
      {Widget? prefixIcon, String? errorText}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFD9D9D9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.red, height: 0.9),
    );
  }

  // --- UI 빌드 (기존과 동일) ---
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // (시스템 뒤로가기 버튼 처리)
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),

        // (상단 AppBar)
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          title: const Text(
            "회원가입",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                _buildLabel("아이디"),
                _buildIdField(), // (기존 UI 유지)
                const SizedBox(height: 16),

                _buildLabel("비밀번호"),
                _buildPasswordField(),
                const SizedBox(height: 16),

                _buildLabel("비밀번호 확인"),
                _buildPasswordConfirmField(),
                const SizedBox(height: 16),

                _buildLabel("닉네임"),
                _buildNicknameField(), // (수정됨)
                const SizedBox(height: 16),

                _buildLabel("주소"),
                _buildAddressField(), // (기존 UI 유지)
                const SizedBox(height: 16),

                _buildLabel("이메일 주소"),
                _buildEmailField(), // (수정됨)
                const SizedBox(height: 16),

                _buildLabel("생년월일"),
                _buildBirthdateField(), // (기존 UI 유지)
                const SizedBox(height: 16),

                _buildLabel("본인 확인 질문"),
                _buildSecurityQuestionField(), // (기존 UI 유지)
                const SizedBox(height: 16),

                _buildLabel("본인 확인 답변"),
                _buildSecurityAnswerField(), // (기존 UI 유지)
                const SizedBox(height: 16),

                _buildTermsAgreement(),
                const SizedBox(height: 32),

                _buildSubmitButton(), // (수정됨)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Label (기존과 동일) ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );

  // --- 아이디 (기존과 동일) ---
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
            // (기존 중복 확인 로직)
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
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("중복 확인"),
        ),
      ],
    );
  }

  // --- 비밀번호 (기존과 동일) ---
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
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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

  // --- 비밀번호 확인 (기존과 동일) ---
  Widget _buildPasswordConfirmField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      onChanged: (_) => _validateConfirmPassword(),
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
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
    );
  }

  // --- ⭐️ 수정 4: 닉네임 필드에 컨트롤러 연결 ---
  Widget _buildNicknameField() => TextField(
    controller: _nicknameController, // 컨트롤러 연결
    decoration: _buildInputDecoration(
      "닉네임을 입력해주세요",
      prefixIcon: const Icon(Icons.badge_outlined),
    ),
  );

  // --- 주소 (기존과 동일) ---
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
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("주소 검색"),
        ),
      ],
    );
  }

  // --- ⭐️ 수정 5: 이메일 필드에 컨트롤러 연결 ---
  Widget _buildEmailField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _emailIdController, // 컨트롤러 연결
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
            controller: _emailDomainController, // 컨트롤러 연결
            decoration: _buildInputDecoration("도메인"),
          ),
        ),
      ],
    );
  }

  // --- 생년월일 (기존과 동일) ---
  Widget _buildBirthdateField() {
    // ... (기존 코드)
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

  // --- 본인 확인 질문 (기존과 동일) ---
  Widget _buildSecurityQuestionField() {
    // ... (기존 코드)
    if (_isDirectQuestion) {
      return TextField(
        controller: _directQuestionController,
        decoration: _buildInputDecoration(
          "직접 질문 입력",
          prefixIcon: const Icon(Icons.edit_note_outlined),
        ).copyWith(
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_drop_down_circle_outlined,
                color: Color(0xFF6B7AA1)),
            onPressed: () {
              setState(() {
                _isDirectQuestion = false;
                _directQuestionController.clear();
              });
            },
          ),
        ),
      );
    } else {
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
            if (newValue == "직접 질문 입력") {
              _isDirectQuestion = true;
              _selectedQuestion = null;
            } else {
              _isDirectQuestion = false;
              _selectedQuestion = newValue;
            }
          });
        },
      );
    }
  }

  // --- 본인 확인 답변 (기존과 동일) ---
  Widget _buildSecurityAnswerField() {
    return TextField(
      decoration: _buildInputDecoration(
        "확인 답변을 입력해주세요",
        prefixIcon: const Icon(Icons.question_answer_outlined),
      ),
    );
  }

  // --- 약관 동의 (기존과 동일) ---
// --- 약관 동의 ---
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
                  "약관 내용 삽입\n\n" * 10, // 👈 (나중에 실제 약관 내용으로 대체)
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
                value: _agreeToTerms, // 👈 (State 변수와 연결)
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

  // --- ⭐️ 수정 6: 가입하기 버튼에 ViewModel 로직 연결 ---
  Widget _buildSubmitButton() {
    // ⭐️ context.watch로 ViewModel의 상태를 감시합니다.
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // ⭐️ 로딩 중이면 null (비활성화), 아니면 _handleSubmit 호출
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9AA8DA),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        // ⭐️ 로딩 상태에 따라 버튼 내부 UI 변경
        child: isLoading
            ? const SizedBox(
          height: 28, // Text 위젯의 높이와 유사하게
          width: 28,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        )
            : const Text(
          "가입하기",
          style: TextStyle(fontSize: 23, color: Colors.white),
        ),
      ),
    );
  }
}