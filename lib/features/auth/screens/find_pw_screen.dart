import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/auth/services/auth_service.dart';
import 'package:lifematch_frontend/core/constants/security_questions.dart';

import '../../../core/services/api_client.dart' as ApiClient;

class FindPwScreen extends StatefulWidget {
  const FindPwScreen({super.key});

  @override
  State<FindPwScreen> createState() => _FindPwScreenState();
}

class _FindPwScreenState extends State<FindPwScreen> {
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _customQuestionController = TextEditingController();
  final _newPwController = TextEditingController();
  final _newPwCheckController = TextEditingController();
  final AuthService _authService = AuthService(dio: ApiClient.dio);
  String? _selectedQuestion;
  bool _isCustomQuestion = false;

  final List<String> _questions = securityQuestions;

  @override
  void dispose() {
    _idController.dispose();
    _emailController.dispose();
    _answerController.dispose();
    _customQuestionController.dispose();
    _newPwController.dispose();
    _newPwCheckController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '비밀번호 재설정',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // 아이디 입력
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: '아이디',
                hintText: '아이디를 입력해주세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            // 이메일 입력
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일 주소',
                hintText: '이메일 주소를 입력해주세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            // 본인 확인 질문
            const Text(
              '본인 확인 질문',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedQuestion,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              hint: const Text('질문을 선택해주세요.'),
              items: _questions
                  .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuestion = value;
                  _isCustomQuestion = value == '직접 질문 입력';
                });
              },
            ),
            const SizedBox(height: 15),

            if (_isCustomQuestion)
              Column(
                children: [
                  TextField(
                    controller: _customQuestionController,
                    decoration: const InputDecoration(
                      hintText: '직접 질문을 입력해주세요',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),

            // 답변
            const Text(
              '본인 확인 답변',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                hintText: '확인 답변을 입력해주세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 25),

            // 새 비밀번호
            TextField(
              controller: _newPwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '새 비밀번호 입력',
                hintText: '문자, 숫자, 특수문자 포함 (8~20자)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),

            // 새 비밀번호 확인
            TextField(
              controller: _newPwCheckController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호 재입력',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            // 재설정하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final question = _isCustomQuestion
                      ? _customQuestionController.text.trim()
                      : _selectedQuestion;

                  if (question == null || question.isEmpty) {
                    _showSnackBar("질문을 선택해주세요.");
                    return;
                  }

                  if (_newPwController.text.trim() !=
                      _newPwCheckController.text.trim()) {
                    _showSnackBar("비밀번호가 서로 일치하지 않습니다.");
                    return;
                  }

                  try {
                    final success = await _authService.resetPassword(
                      loginId: _idController.text.trim(),
                      email: _emailController.text.trim(),
                      securityQuestion: question,
                      securityAnswer: _answerController.text.trim(),
                      newPassword: _newPwController.text.trim(),
                    );

                    if (success) {
                      _showSnackBar("비밀번호가 성공적으로 변경되었습니다.");

                      // 로그인 화면으로 이동
                      Navigator.pushReplacementNamed(context, '/login');

                    }
                  } catch (e) {
                    _showSnackBar("정보가 일치하지 않습니다.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AA8DA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '재설정하기',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
