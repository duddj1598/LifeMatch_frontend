import 'package:flutter/material.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart'; // ⭐️ 1. StorageService 임포트
import 'package:lifematch_frontend/features/lifestyle_test/models/lifestyle_test_model.dart'; // ⭐️ 2. 모델 임포트
import 'package:lifematch_frontend/features/lifestyle_test/services/lifestyle_test_service.dart'; // ⭐️ 3. 서비스 임포트
import 'package:lifematch_frontend/features/lifestyle_test/screens/lifestyle_loading_screen.dart'; // ⭐️ 4. 로딩 팝업
import 'package:lifematch_frontend/features/lifestyle_test/screens/lifestyle_result_screen.dart'; // ⭐️ 5. 결과 팝업

class LifestyleTestScreen extends StatefulWidget {
  const LifestyleTestScreen({super.key});

  @override
  State<LifestyleTestScreen> createState() => _LifestyleTestScreenState();
}

class _LifestyleTestScreenState extends State<LifestyleTestScreen> {
  // --- 1. 서비스 및 상태 변수 ---
  final LifestyleTestService _testService = LifestyleTestService();
  final StorageService _storageService = StorageService();

  // ⭐️ API에서 받아올 질문 데이터
  QuestionParts? _questionParts;
  bool _isLoading = true;
  String? _errorMessage;

  // ⭐️ 답변 저장 방식 변경: (Key: questionId, Value: selected_optionId)
  final Map<int, int> _answers = {};

  // ⭐️ 색상 정의 (기존과 동일)
  static const Color _primaryColor = Color(0xFF4C6DAF);
  static const Color _backgroundColor = Color(0xFFEDEDED);
  static const Color _partTitleColor = Color(0x734C6DAF);
  static const Color _radioSelectedColor = Color(0xE64C6DAF);

  @override
  void initState() {
    super.initState();
    _fetchQuestions(); // ⭐️ 2. 화면 시작 시 API로 질문 로드
  }

  // --- 3. API 호출 함수 ---
  Future<void> _fetchQuestions() async {
    try {
      final questions = await _testService.getQuestions();
      setState(() {
        _questionParts = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 4. ⭐️ 파트 제목 위젯 (기존과 동일)
  Widget _buildPartTitle(String title) {
    return Container(
      // ... (스타일 동일)
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _partTitleColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 5. ⭐️ 질문 카드 위젯 (기존과 동일)
  Widget _buildQuestionCard(List<Widget> children) {
    return Container(
      // ... (스타일 동일)
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // 6. ⭐️ (수정) API에서 받은 Question 객체로 질문 UI 생성
  Widget _buildQuestionItem(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText, // (API 데이터)
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // ⭐️ 옵션 2개 (항상 2개라고 가정)
        _buildOption(question.questionId, question.options[0]),
        const SizedBox(height: 12),
        _buildOption(question.questionId, question.options[1]),
      ],
    );
  }

  // 7. ⭐️ (수정) Option 객체로 옵션 UI 생성
  Widget _buildOption(int questionId, QuestionOption option) {
    // ⭐️ 답변 저장 방식이 (questionId, optionId)로 변경됨
    final bool isSelected = (_answers[questionId] == option.optionId);

    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[questionId] = option.optionId;
        });
      },
      child: Row(
        children: [
          Container(
            // ... (라디오 버튼 스타일 동일)
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? _radioSelectedColor : Colors.white,
              border: isSelected
                  ? null
                  : Border.all(color: _primaryColor, width: 2.0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option.text, // (API 데이터)
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // 8. ⭐️ (수정) 완료 버튼 로직
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // ⭐️ 8-1. 유효성 검사 (총 8개 질문)
          final int totalQuestions = _questionParts?.allQuestions.length ?? 8;
          if (_answers.length < totalQuestions) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("모든 설문에 답 해 주세요!"),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }

          // ⭐️ 8-2. (필수) 저장된 user_id 가져오기
          final String? userId = await _storageService.getUserId();
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("로그인 정보가 없습니다. 다시 로그인해주세요.")),
            );
            return;
          }

          // ⭐️ 8-3. 닉네임 대신 userId를 팝업에 사용 (임시)
          // (나중에 닉네임도 Storage에 저장해서 사용하세요)
          final String tempNickname = userId;

          showLifestyleLoadingPopup(context, tempNickname);

          try {
            // ⭐️ 8-4. (API 호출) 선택된 optionId 리스트를 서비스로 전달
            final List<int> selectedOptionIds = _answers.values.toList();
            final LifestyleTestResultDetail result =
            await _testService.submitTest(userId, selectedOptionIds);

            // ⭐️ (나중에 3초 지연은 삭제)
            await Future.delayed(const Duration(seconds: 3));

            if (!mounted) return;
            Navigator.pop(context); // 로딩 팝업 닫기

            // ⭐️ 8-5. (API 결과 전달)
            // (lifestyle_result_screen.dart가 LifestyleTestResultDetail을 받도록 수정해야 함)
            showLifestyleResultPopup(context, tempNickname, result);

          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // 로딩 팝업 닫기
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("오류 발생: ${e.toString()}")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          // ... (버튼 스타일 동일)
          backgroundColor: const Color(0xFFEC6A6A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "완료",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  // 9. ⭐️ (수정) 메인 Build 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _buildBody(), // ⭐️ 로딩 상태에 따라 다른 UI 표시
      ),
    );
  }

  // 10. ⭐️ (수정) 메인 Body 위젯
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _fetchQuestions,
              child: const Text("재시도"),
            )
          ],
        ),
      );
    }

    if (_questionParts == null) {
      return const Center(child: Text("질문을 불러오지 못했습니다."));
    }

    // ⭐️ API에서 받은 데이터로 UI 그리기
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- PART 1 ---
            _buildPartTitle("PART 1. 소비와 경제생활"),
            _buildQuestionCard(
              _questionParts!.part1.map((q) => _buildQuestionItem(q)).toList(),
            ),

            // --- PART 2 ---
            _buildPartTitle("PART 2. 여가와 취미"),
            _buildQuestionCard(
              _questionParts!.part2.map((q) => _buildQuestionItem(q)).toList(),
            ),

            // --- PART 3 ---
            _buildPartTitle("PART 3. 건강과 자기관리"),
            _buildQuestionCard(
              _questionParts!.part3.map((q) => _buildQuestionItem(q)).toList(),
            ),

            // --- PART 4 ---
            _buildPartTitle("PART 4. 생활 습관"),
            _buildQuestionCard(
              _questionParts!.part4.map((q) => _buildQuestionItem(q)).toList(),
            ),

            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}