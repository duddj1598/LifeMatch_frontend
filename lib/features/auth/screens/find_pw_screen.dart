import 'package:flutter/material.dart';

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

  String? _selectedQuestion;
  bool _isCustomQuestion = false;
  bool _isResetComplete = false;

  // ✅ 질문 목록
  final List<String> _questions = [
    '내가 다닌 초등학교 이름은?',
    '내가 태어난 도시는?',
    '내가 가장 좋아하는 계절은?',
    '직접 질문 입력',
  ];

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

            // 아이디
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

            // 이메일
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
              value: _selectedQuestion,
              decoration: InputDecoration(
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

            // 직접 질문 입력
            if (_isCustomQuestion) ...[
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

            // 답변 입력
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

            // 재설정 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 실제 서버 검증 로직 자리 (현재는 예시)
                  setState(() {
                    _isResetComplete = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AA8DA),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '재설정하기',
                  style: TextStyle(
                    color: Colors.white,      // ✅ 흰색 텍스트
                    fontSize: 20,             // ✅ 글씨 크기 키움
                    fontWeight: FontWeight.bold, // ✅ 굵게 강조
                  ),
                ),

              ),
            ),
            const SizedBox(height: 25),

            // 재설정 완료 후 새 비밀번호 입력
            if (_isResetComplete) ...[
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
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.red, size: 18),
                  SizedBox(width: 5),
                  Text(
                    '비밀번호가 성공적으로 변경되었습니다.',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9AA8DA),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '로그인 하기',
                    style: TextStyle(
                      color: Colors.white,        // ✅ 흰색 텍스트
                      fontSize: 20,               // ✅ 글씨 크기 키움
                      fontWeight: FontWeight.bold, // ✅ 굵게
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
