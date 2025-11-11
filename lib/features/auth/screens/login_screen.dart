import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifematch_frontend/features/auth/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ 로그인 로직
  Future<void> _handleLogin() async {
    // ✅ 실제 API 호출 부분 잠시 비활성화
    // final viewModel = context.read<AuthViewModel>();
    // if (viewModel.isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일과 비밀번호를 모두 입력해주세요.")),
      );
      return;
    }

    // ✅ 임시 로그인 로직 (백엔드 연결 전까지)
    if (email == "test@lifematch.com" && password == "1234") {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    // ✅ 임시로: 모든 입력에 대해 홈 이동
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

    // 🔹 나중에 실제 백엔드 연결 시 아래 주석 해제
    /*
  final success = await viewModel.login(email, password);

  if (!mounted) return;

  if (success) {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(viewModel.errorMessage ?? "로그인 실패"),
        backgroundColor: Colors.red,
      ),
    );
  }
  */
  }


  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true, // ✅ 키보드 올라올 때 화면 밀림 방지
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 & 타이틀
              Column(
                children: [
                  Image.asset(
                    'assets/images/lifematch_logo.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Life\nMatch',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 50,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7AA1),
                      height: 1.1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 이메일 입력창
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  hintText: '아이디(이메일)',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 비밀번호 입력창
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: '비밀번호',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
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
              ),

              const SizedBox(height: 20),

              // ✅ 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9AA8DA),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    '로그인',
                    style: TextStyle(fontSize: 23, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9AA8DA),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(fontSize: 23, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 아이디 / 비밀번호 찾기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/find_id'),
                    child: const Text('아이디 찾기',
                        style: TextStyle(fontSize: 13, color: Colors.black)),
                  ),
                  const Text('|', style: TextStyle(color: Colors.black)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/find_pw'),
                    child: const Text('비밀번호 찾기',
                        style: TextStyle(fontSize: 13, color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
