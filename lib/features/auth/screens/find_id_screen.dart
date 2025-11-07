import 'package:flutter/material.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _customQuestionController = TextEditingController();

  String? _selectedQuestion;
  bool _isCustomQuestion = false;
  String? _foundId;

  // ✅ 질문 목록
  final List<String> _questions = [
    '내가 다닌 초등학교 이름은?',
    '내가 태어난 도시는?',
    '내가 가장 좋아하는 계절은?',
    '직접 질문 입력',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _answerController.dispose();
    _customQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          '아이디 찾기',
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
              '아이디 찾기',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),

            // 닉네임 입력
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                hintText: '닉네임을 입력해주세요',
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

            // 아이디 찾기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 실제 서버 로직 대신 예시 데이터
                  setState(() {
                    _foundId = 'lifematch_user01';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AA8DA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '아이디 찾기',
                  style: TextStyle(
                    color: Colors.white,   // ✅ 흰색 텍스트
                    fontSize: 20,          // ✅ 글씨 크기 키움
                    fontWeight: FontWeight.bold, // 선택: 강조 효과
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 찾은 아이디 표시
            if (_foundId != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDADADA)),
                ),
                child: Column(
                  children: [
                    Text(
                      '회원님의 아이디는\n"$_foundId" 입니다.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        '로그인하기',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
