import 'package:flutter/material.dart';

// ⭐️ 1. (새로 추가) 팝업을 띄우는 함수
void showLifestyleResultPopup(BuildContext context, String nickname) {
  showDialog(
    context: context,
    // (선택사항) 밖을 눌러도 닫히지 않게 하려면 true 대신 false 사용
    barrierDismissible: true,
    builder: (BuildContext context) {
      // ⭐️ 2. Dialog 위젯을 반환
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // 둥근 모서리
        ),
        elevation: 0,
        backgroundColor: Colors.transparent, // Dialog 자체는 투명하게

        // ⭐️ 3. 내용물로 LifestyleResultContent 위젯 사용
        child: LifestyleResultContent(nickname: nickname),
      );
    },
  );
}


// ⭐️ 4. 기존 Scaffold를 "LifestyleResultContent" 위젯으로 변경
// (이것이 팝업의 내용물이 됩니다)
class LifestyleResultContent extends StatelessWidget {
  final String nickname;

  const LifestyleResultContent({super.key, required this.nickname});

  // ⭐️ 색상 정의
  static const Color _textColor = Color(0xBF4C6DAF); // 4C6DAF 75%
  static const Color _buttonColor = Color(0xFF4C6DAF);

  @override
  Widget build(BuildContext context) {
    const String lifestyleType = " "; // (나중에 받을 결과값)

    // ⭐️ 5. Scaffold/Center 대신 Container가 최상위
    return Container(
      width: MediaQuery.of(context).size.width * 0.85, // 화면 가로폭의 85%
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white, // ⭐️ 팝업의 흰색 배경
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 팝업 크기 잡기
        children: [

          // (임시) 아이콘
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),

          // 결과 텍스트 (닉네임 포함)
          Text(
            "[$nickname]님의 라이프 스타일 유형은\n“$lifestyleType”입니다!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // "홈으로" 버튼
          OutlinedButton(
            onPressed: () {
              print("홈 이동");
              // ⭐️ 6. 홈 화면으로 이동 (이전 화면 스택 모두 제거)
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