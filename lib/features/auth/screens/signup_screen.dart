import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ⭐️ ViewModel 임포트
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

  // ViewModel에 전달할 컨트롤러
  final _nicknameController = TextEditingController();
  final _emailIdController = TextEditingController();
  final _emailDomainController = TextEditingController();

  // --- 상태 변수 ---
  String? _idError;
  String? _passwordError;
  String? _confirmPasswordError;

  // ⭐️ 추가: 닉네임/이메일 에러 및 중복확인 여부 상태
  String? _nicknameError;
  String? _emailError;
  bool _isNicknameChecked = false;
  bool _isEmailChecked = false;

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
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _directQuestionController.dispose();
    _nicknameController.dispose();
    _emailIdController.dispose();
    _emailDomainController.dispose();
    super.dispose();
  }

  // --- ⭐️ 닉네임 중복 확인 (API 호출 시뮬레이션) ---
  Future<void> _checkNicknameAvailability() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() {
        _nicknameError = "닉네임을 입력해주세요.";
      });
      return;
    }

    // ⬇️⬇️⬇️ [API 연동 구간] ⬇️⬇️⬇️
    /*
    try {
      // 예시: 백엔드 API 호출
      final isAvailable = await AuthService.checkNickname(nickname);
      if (!isAvailable) {
        setState(() {
          _nicknameError = "이미 사용 중인 닉네임입니다.";
          _isNicknameChecked = false;
        });
        return;
      }
    } catch (e) {
      // 에러 처리
      return;
    }
    */
    // ⬆️⬆️⬆️ [API 개발 후 주석 해제 및 구현] ⬆️⬆️⬆️

    // --- [임시 테스트 로직] ---
    // "admin" 이라는 닉네임만 중복이라고 가정
    if (nickname == "admin") {
      setState(() {
        _nicknameError = "이미 있는 닉네임 입니다.";
        _isNicknameChecked = false;
      });
    } else {
      setState(() {
        _nicknameError = null;
        _isNicknameChecked = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 닉네임입니다."), backgroundColor: Colors.green),
      );
    }
    // -----------------------
  }

  // --- ⭐️ 이메일 중복 확인 (API 호출 시뮬레이션) ---
  Future<void> _checkEmailAvailability() async {
    if (_emailIdController.text.isEmpty || _emailDomainController.text.isEmpty) {
      setState(() {
        _emailError = "이메일을 모두 입력해주세요.";
      });
      return;
    }

    final email = "${_emailIdController.text.trim()}@${_emailDomainController.text.trim()}";

    // ⬇️⬇️⬇️ [API 연동 구간] ⬇️⬇️⬇️
    /*
    try {
      final isAvailable = await AuthService.checkEmail(email);
      if (!isAvailable) {
         setState(() {
          _emailError = "이미 가입된 이메일입니다.";
          _isEmailChecked = false;
        });
        return;
      }
    } catch (e) { return; }
    */
    // ⬆️⬆️⬆️ [API 개발 후 주석 해제 및 구현] ⬆️⬆️⬆️

    // --- [임시 테스트 로직] ---
    if (email == "test@test.com") {
      setState(() {
        _emailError = "이미 있는 이메일 입니다.";
        _isEmailChecked = false;
      });
    } else {
      setState(() {
        _emailError = null;
        _isEmailChecked = true;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용 가능한 이메일입니다."), backgroundColor: Colors.green),
      );
    }
    // -----------------------
  }


  // --- ViewModel 호출 함수 ---
  Future<void> _handleSubmit() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (viewModel.isLoading) return;

    // 유효성 검사
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() { _confirmPasswordError = "비밀번호가 일치하지 않습니다."; });
      return;
    }
    if (_passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("비밀번호 형식을 확인해주세요.")));
      return;
    }
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("닉네임을 입력해주세요.")));
      return;
    }
    // ⭐️ 닉네임 중복확인 여부 검사
    if (!_isNicknameChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("닉네임 중복 확인을 해주세요.")));
      return;
    }
    if (_emailIdController.text.isEmpty || _emailDomainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이메일을 입력해주세요.")));
      return;
    }
    // ⭐️ 이메일 중복확인 여부 검사
    if (!_isEmailChecked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("이메일 중복 확인을 해주세요.")));
      return;
    }
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("약관에 동의해주세요.")));
      return;
    }

    final String email = "${_emailIdController.text}@${_emailDomainController.text}";

    final bool success = await viewModel.signup(
      email: email,
      nickname: _nicknameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("회원가입에 성공했습니다. 로그인해주세요."),
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

  // --- 비밀번호 확인 로직 ---
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

  // --- 입력 필드 공통 데코레이션 ---
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // 내용 패딩 조정
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                _buildIdField(),
                const SizedBox(height: 16),

                _buildLabel("비밀번호"),
                _buildPasswordField(),
                const SizedBox(height: 16),

                _buildLabel("비밀번호 확인"),
                _buildPasswordConfirmField(),
                const SizedBox(height: 16),

                _buildLabel("닉네임"),
                _buildNicknameField(), // ⭐️ 수정됨 (중복확인 버튼 추가)
                const SizedBox(height: 16),

                // ❌ 주소 입력 필드 제거됨

                _buildLabel("이메일 주소"),
                _buildEmailField(), // ⭐️ 수정됨 (중복확인 버튼 추가)
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
            // 기존 아이디 중복 로직 유지
            final id = _idController.text;
            setState(() {
              if (id.isEmpty) {
                _idError = "아이디를 입력해주세요.";
              } else if (id == "admin") {
                _idError = "사용할 수 없는 아이디입니다";
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: const Text("중복 확인"),
        ),
      ],
    );
  }

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

  // --- ⭐️ 수정: 닉네임 필드 + 중복 확인 버튼 ---
  Widget _buildNicknameField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 에러 메시지 출력 시 정렬 유지
      children: [
        Expanded(
          child: TextField(
            controller: _nicknameController,
            onChanged: (_) {
              // 입력값이 바뀌면 중복확인을 다시 해야함
              if (_isNicknameChecked) {
                setState(() {
                  _isNicknameChecked = false;
                });
              }
            },
            decoration: _buildInputDecoration(
              "닉네임 입력",
              prefixIcon: const Icon(Icons.badge_outlined),
              errorText: _nicknameError,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 50, // TextField 높이와 비슷하게 맞춤 (에러 없을 때 기준)
          child: ElevatedButton(
            onPressed: _checkNicknameAvailability,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isNicknameChecked ? Colors.green[400] : const Color(0xFFB0BEC5),
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(_isNicknameChecked ? "확인 완료" : "중복 확인"),
          ),
        ),
      ],
    );
  }

  // --- ⭐️ 수정: 이메일 필드 + 중복 확인 버튼 ---
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _emailIdController,
                onChanged: (_) {
                  if (_isEmailChecked) setState(() => _isEmailChecked = false);
                },
                decoration: _buildInputDecoration(
                  "이메일 ID",
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 14.0),
              child: Text("@", style: TextStyle(fontSize: 16)),
            ),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _emailDomainController,
                onChanged: (_) {
                  if (_isEmailChecked) setState(() => _isEmailChecked = false);
                },
                decoration: _buildInputDecoration("도메인"),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _checkEmailAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEmailChecked ? Colors.green[400] : const Color(0xFFB0BEC5),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 8), // 텍스트가 길 경우를 대비해 패딩 축소
                ),
                child: Text(
                  _isEmailChecked ? "완료" : "확인",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        // 이메일 에러 메시지를 Row 아래에 표시
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 12.0),
            child: Text(
              _emailError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
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
                  "약관 내용 삽입\n\n" * 10,
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
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9AA8DA),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
          height: 28,
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