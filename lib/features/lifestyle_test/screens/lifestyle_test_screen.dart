import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/lifestyle_test/screens/lifestyle_loading_screen.dart';
import 'lifestyle_result_screen.dart';

class LifestyleTestScreen extends StatefulWidget {
  const LifestyleTestScreen({super.key});

  @override
  State<LifestyleTestScreen> createState() => _LifestyleTestScreenState();
}

class _LifestyleTestScreenState extends State<LifestyleTestScreen> {
  // 1. ⭐️ 색상 정의
  static const Color _primaryColor = Color(0xFF4C6DAF);
  static const Color _backgroundColor = Color(0xFFEDEDED);
  static const Color _partTitleColor = Color(0x734C6DAF); // 4C6DAF 45% (0.45 * 255 = 114 -> 0x73)
  static const Color _radioSelectedColor = Color(0xE64C6DAF); // 4C6DAF 90% (0.9 * 255 = 230 -> 0xE6)

  // 2. ⭐️ 각 질문의 답변을 저장할 Map (Key: 질문 ID, Value: 1 또는 2)
  final Map<String, int> _answers = {};

  // 3. ⭐️ 질문 카드 위젯 (내부 흰색 카드)
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

  // 4. ⭐️ 파트 제목 위젯 (PART 1...)
  Widget _buildPartTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _partTitleColor, // 4C6DAF 45%
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

  // 5. ⭐️ 질문 + 2지선다 항목 위젯
  Widget _buildQuestionItem(String questionId, String questionText,
      String option1, String option2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildOption(questionId, 1, option1), // 옵션 1
        const SizedBox(height: 12),
        _buildOption(questionId, 2, option2), // 옵션 2
      ],
    );
  }

  // 6. ⭐️ (핵심) 선택 가능한 옵션 위젯 (라디오 버튼 + 텍스트)
  Widget _buildOption(String questionId, int optionIndex, String text) {
    // 현재 이 옵션이 선택되었는지 확인
    final bool isSelected = (_answers[questionId] ?? 0) == optionIndex;

    return GestureDetector(
      onTap: () {
        // ⭐️ 탭하면 setState를 호출해 맵에 답변 저장
        setState(() {
          _answers[questionId] = optionIndex;
        });
      },
      child: Row(
        children: [
          // ⭐️ 커스텀 라디오 버튼
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ⭐️ 선택 여부에 따라 색상 변경
              color: isSelected ? _radioSelectedColor : Colors.white,
              // ⭐️ 비선택 시에만 테두리 표시
              border: isSelected
                  ? null
                  : Border.all(color: _primaryColor, width: 2.0),
            ),
          ),
          const SizedBox(width: 12),
          // ⭐️ 텍스트가 화면을 넘어갈 수 있으므로 Expanded로 감싸기
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // 7. ⭐️ 완료 버튼
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          const int totalQuestions = 8;
          if (_answers.length < totalQuestions) {
            // ⭐️ 2. 미완료 시 스낵바 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("모든 설문에 답 해 주세요!"),
                backgroundColor: Colors.redAccent, // 에러 느낌 강조
              ),
            );
            return; // ⭐️ 로직 중단
          }
          // ⭐️ 완료 버튼 클릭 시, 현재까지의 답변을 콘솔에 출력
          print("--- 설문조사 결과 ---");
          print(_answers);

          const String tempNickname = "닉네임";

          showLifestyleLoadingPopup(context, tempNickname);
          await Future.delayed(const Duration(seconds: 3));

          if(!mounted) return;
          Navigator.pop(context);

          showLifestyleResultPopup(context, tempNickname);
          // (나중에 이 _answers 맵을 서버로 전송)
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEC6A6A), // 이미지의 빨간색 버튼
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor, // ⭐️ 전체 프레임 배경색: EDEDED
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- PART 1 ---
                _buildPartTitle("PART 1. 소비와 경제생활"),
                _buildQuestionCard([
                  _buildQuestionItem(
                    "q1",
                    "Q1. 내 돈 소비 스타일은?",
                    "새로운 경험은 못참지! 일단 결제하고 본다.",
                    "이걸 사는게 맞을까? 가성비를 꼼꼼히 따져본다.",
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildQuestionItem(
                    "q2",
                    "Q2. 더 끌리는 아이템은?",
                    "최신 유행하는 힙한 신상 아이템",
                    "오래 쓸 수 있는 클래식 아이템",
                  ),
                ]),

                // --- PART 2 ---
                _buildPartTitle("PART 2. 여가와 취미"),
                _buildQuestionCard([
                  _buildQuestionItem(
                    "q3",
                    "Q3. 주말에 약속이 없다면?",
                    "핫한 팝업스토어로 바로 향한다",
                    "밀린 드라마를 정주행하며 집콕한다",
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildQuestionItem(
                    "q4",
                    "Q4. 여행을 떠난다면?",
                    "SNS에 뜨는 명소! 핫플 중심으로!",
                    "나만 아는 조용한 곳으로!",
                  ),
                ]),

                // --- PART 3 ---
                _buildPartTitle("PART 3. 건강과 자기관리"),
                _buildQuestionCard([
                  _buildQuestionItem(
                    "q5",
                    "Q5. 오늘 운동 뭐 하지?",
                    "인기 많은 피트니스 클래스를 알아본다",
                    "상쾌하게 공원에서 조깅이나 할까",
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildQuestionItem(
                    "q6",
                    "Q6. 스트레스 받을 땐?",
                    "매운 음식을 먹거나 쇼핑으로 푼다.",
                    "명상을 하거나 좋아하는 음악을 듣는다.",
                  ),
                ]),

                // --- PART 4 ---
                _buildPartTitle("PART 4. 생활 습관"),
                _buildQuestionCard([
                  _buildQuestionItem(
                    "q7",
                    "Q7. 새로운 기술이 나오면?",
                    "일단 써봐야 직성이 풀린다.",
                    "안정성이 검증될 때까지 기다린다.",
                  ),
                  const Divider(height: 30, thickness: 1),
                  _buildQuestionItem(
                    "q8",
                    "Q8. 안 쓰는 물건이 생기면?",
                    "중고거래 앱에 바로 올린다.",
                    "언젠가 쓸 것 같아 일단 둔다.",
                  ),
                ]),

                const SizedBox(height: 20),

                // --- 완료 버튼 ---
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      )
    );
  }
}