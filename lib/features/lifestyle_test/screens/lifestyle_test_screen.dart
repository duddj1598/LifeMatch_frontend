import 'package:flutter/material.dart';
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
  final LifestyleTestService _testService = LifestyleTestService();
  final StorageService _storageService = StorageService();

  QuestionParts? _questionParts;
  bool _isLoading = true;
  String? _errorMessage;

  final Map<int, int> _answers = {};

  static const Color _primaryColor = Color(0xFF4C6DAF);
  static const Color _backgroundColor = Color(0xFFEDEDED);
  static const Color _partTitleColor = Color(0x734C6DAF);
  static const Color _radioSelectedColor = Color(0xE64C6DAF);

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

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

  Widget _buildPartTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _partTitleColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildQuestionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildQuestionItem(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.questionText,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        _buildOption(question.questionId, question.options[0]),
        const SizedBox(height: 12),
        _buildOption(question.questionId, question.options[1]),
      ],
    );
  }

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
            child: Text(option.text,
                style: const TextStyle(fontSize: 15, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final int totalQuestions = _questionParts?.allQuestions.length ?? 8;
          if (_answers.length < totalQuestions) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("모든 설문에 답 해 주세요!"),
              backgroundColor: Colors.redAccent,
            ));
            return;
          }

          final String? accessToken = await _storageService.getToken();
          final String? nickname = await _storageService.getNickname();
          final String? userId = await _storageService.getUserId();

          if (accessToken == null || userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("로그인 후 이용해주세요."),
            ));
            Navigator.pushReplacementNamed(context, '/login');
            return;
          }

          final String displayName = nickname ?? "사용자";

          showLifestyleLoadingPopup(context, displayName);

          try {
            final List<int> selectedOptionIds = _answers.values.toList();

            final LifestyleTestResultDetail result = await _testService
                .submitTest(accessToken, userId, selectedOptionIds);

            await _storageService.saveLifestyleType(result.typeName);

            await Future.delayed(const Duration(seconds: 1));

            if (!mounted) return;
            Navigator.pop(context);
            showLifestyleResultPopup(context, displayName, result);
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("오류 발생: $e")));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC6A6A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("완료",
            style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(child: _buildBody()),
    );
  }

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
                onPressed: _fetchQuestions, child: const Text("재시도"))
          ],
        ),
      );
    }

    if (_questionParts == null) {
      return const Center(child: Text("질문을 불러오지 못했습니다."));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPartTitle("PART 1. 소비와 경제생활"),
            _buildQuestionCard(
                _questionParts!.part1.map((q) => _buildQuestionItem(q)).toList()),

            _buildPartTitle("PART 2. 여가와 취미"),
            _buildQuestionCard(
                _questionParts!.part2.map((q) => _buildQuestionItem(q)).toList()),

            _buildPartTitle("PART 3. 건강과 자기관리"),
            _buildQuestionCard(
                _questionParts!.part3.map((q) => _buildQuestionItem(q)).toList()),

            _buildPartTitle("PART 4. 생활 습관"),
            _buildQuestionCard(
                _questionParts!.part4.map((q) => _buildQuestionItem(q)).toList()),

            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
