import 'package:flutter/material.dart';
// ⭐️ 1. 결과 모델 임포트
import 'package:lifematch_frontend/features/lifestyle_test/models/lifestyle_test_model.dart';

// ⭐️ 2. (수정) 팝업 함수가 닉네임과 'result' 객체를 받도록 변경
void showLifestyleResultPopup(BuildContext context, String nickname, LifestyleTestResultDetail result) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // ⭐️ 3. (수정) LifestyleResultContent로 닉네임과 'result' 전달
        child: LifestyleResultContent(nickname: nickname, result: result),
      );
    },
  );
}

// ⭐️ 4. (수정) 팝업 내용 위젯
class LifestyleResultContent extends StatelessWidget {
  final String nickname;
  final LifestyleTestResultDetail result; // ⭐️ API에서 받은 결과

  const LifestyleResultContent({
    super.key,
    required this.nickname,
    required this.result,
  });

  static const Color _textColor = Color(0xBF4C6DAF);
  static const Color _buttonColor = Color(0xFF4C6DAF);

  @override
  Widget build(BuildContext context) {
    // ⭐️ 5. (수정) 더 이상 'lifestyleType'을 " "로 비워두지 않음
    // final String lifestyleType = " ";

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),

          // ⭐️ 6. (수정) API에서 받은 'result.typeName'을 표시
          Text(
            "[$nickname]님의 라이프 스타일 유형은\n“${result.typeName}”입니다!", // ⭐️ API 결과 사용
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),

          // ⭐️ (선택) 키워드나 설명도 추가할 수 있습니다.
          // Text(
          //   result.keywords,
          //   style: const TextStyle(color: _textColor, fontSize: 14),
          // ),

          const SizedBox(height: 28),

          // "홈으로" 버튼
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
            style: OutlinedButton.styleFrom(
              // ... (버튼 스타일)
              foregroundColor: _buttonColor,
              side: const BorderSide(color: _buttonColor, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "홈으로",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}