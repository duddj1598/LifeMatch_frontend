import 'package:flutter/material.dart';
// ⭐️ 1. 필요한 서비스, 모델, 팝업 화면들 임포트
import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:lifematch_frontend/features/lifestyle_test/models/lifestyle_test_model.dart';
import 'package:lifematch_frontend/features/lifestyle_test/services/lifestyle_test_service.dart';
import 'package:lifematch_frontend/features/lifestyle_test/screens/lifestyle_loading_screen.dart';
import 'package:lifematch_frontend/features/lifestyle_test/screens/lifestyle_result_screen.dart';

class LifestyleTestScreen extends StatefulWidget {
  const LifestyleTestScreen({super.key});

  @override
  State<LifestyleTestScreen> createState() => _LifestyleTestScreenState();
}

class _LifestyleTestScreenState extends State<LifestyleTestScreen> {
  // --- 1. 서비스 및 상태 변수 ---
  final LifestyleTestService _testService = LifestyleTestService();
  final StorageService _storageService = StorageService();

  // API에서 받아올 질문 데이터
  QuestionParts? _questionParts;
  bool _isLoading = true;
  String? _errorMessage;

  // 답변 저장: (Key: questionId, Value: selected_optionId)
  final Map<int, int> _answers = {};

  // ⭐️ 색상 정의
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

  // 4. ⭐️ 파트 제목 위젯
  Widget _buildPartTitle(String title) {
    return Container(
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

  // 5. ⭐️ 질문 카드 위젯
  Widget _buildQuestionCard(List<Widget> children) {
    return Container(
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

  // 6. ⭐️ API 데이터로 질문 UI 생성
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
        _buildOption(question.questionId, question.options[0]),
        const SizedBox(height: 12),
        _buildOption(question.questionId, question.options[1]),
        // ⭐️ 질문 사이에 Divider가 필요하다면 여기에 추가
        // const Divider(height: 30, thickness: 1),
      ],
    );
  }

  // 7. ⭐️ API 데이터로 옵션 UI 생성
  Widget _buildOption(int questionId, QuestionOption option) {
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

  // 8. ⭐️ (핵심) 완료 버튼 - 모든 호출 로직 포함
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        // --- 👇 1. 호출 로직 (onPressed) ---
        onPressed: () async {
          // 8-1. 유효성 검사 (총 8개 질문)
          final int totalQuestions = _questionParts?.allQuestions.length ?? 8;
          if (_answers.length < totalQuestions) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("모든 설문에 답 해 주세요!"),
                backgroundColor: Colors.redAccent,
              ),
            );
            return; // ⭐️ 로직 중단
          }

          // 8-2. 저장된 user_id (이메일) 및 닉네임 가져오기
          final String? userId = await _storageService.getUserId();
          final String? nickname = await _storageService.getNickname();

          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("로그인 정보가 없습니다. 다시 로그인해주세요.")),
            );
            return; // ⭐️ 로직 중단
          }

          // 8-3. 팝업에 표시할 이름 (닉네임 > ID 순)
          final String displayName = (nickname != null && nickname.isNotEmpty) ? nickname : userId;

          // 8-4. 로딩 팝업 띄우기
          showLifestyleLoadingPopup(context, displayName);

          try {
            // 8-5. (API 호출) 선택된 optionId 리스트를 서비스로 전달
            final List<int> selectedOptionIds = _answers.values.toList();
            final LifestyleTestResultDetail result =
            await _testService.submitTest(userId, selectedOptionIds);

            // 8-6. (분기 로직) 검사 결과를 Storage에도 즉시 저장
            // (다음에 로그인할 때를 대비하는 것이 아니라, *지금* 검사를 완료했음을
            //  앱이 즉시 알 수 있도록 하기 위함. 하지만 이 값은 현재 사용되진 않음.)
            await _storageService.saveLifestyleType(result.typeName);
            // (참고: 로그인 분기 로직은 login_user가 반환하는 "true"로 동작함)

            // ⭐️ (임시) 3초 대기 (나중에 삭제)
            await Future.delayed(const Duration(seconds: 3));

            if (!mounted) return;
            Navigator.pop(context); // 로딩 팝업 닫기

            // 8-7. 결과 팝업 띄우기
            showLifestyleResultPopup(context, displayName, result);

          } catch (e) {
            // 8-8. API 호출 실패 시
            if (!mounted) return;
            Navigator.pop(context); // 로딩 팝업 닫기
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("오류 발생: ${e.toString()}")),
            );
          }
        },
        // --- 👆 1. 호출 로직 (onPressed) 끝 ---

        // --- 👇 2. 버튼 스타일 ---
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC6A6A), // 🔴 버튼 색상
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 🔘 모서리 둥글기
          ),
        ),
        child: const Text(
          "완료",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  // 9. ⭐️ 메인 Build 함수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: _buildBody(), // 로딩 상태에 따라 다른 UI 표시
      ),
    );
  }

  // 10. ⭐️ 메인 Body 위젯
  Widget _buildBody() {
    // 10-1. 로딩 중
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 10-2. 질문 로드 실패
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

    // 10-3. (이론상) 질문이 없는 경우
    if (_questionParts == null) {
      return const Center(child: Text("질문을 불러오지 못했습니다."));
    }

    // 10-4. (성공) API에서 받은 데이터로 UI 그리기
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ⭐️ 'map'을 사용하여 각 파트의 질문들을 동적으로 생성
            // ⭐️ (참고: 현재 UI는 질문 카드 사이에 Divider가 없음)
            _buildPartTitle("PART 1. 소비와 경제생활"),
            _buildQuestionCard(
              _questionParts!.part1.map((q) => _buildQuestionItem(q)).toList(),
            ),

            _buildPartTitle("PART 2. 여가와 취미"),
            _buildQuestionCard(
              _questionParts!.part2.map((q) => _buildQuestionItem(q)).toList(),
            ),

            _buildPartTitle("PART 3. 건강과 자기관리"),
            _buildQuestionCard(
              _questionParts!.part3.map((q) => _buildQuestionItem(q)).toList(),
            ),

            _buildPartTitle("PART 4. 생활 습관"),
            _buildQuestionCard(
              _questionParts!.part4.map((q) => _buildQuestionItem(q)).toList(),
            ),

            const SizedBox(height: 20),

            // --- 완료 버튼 ---
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}