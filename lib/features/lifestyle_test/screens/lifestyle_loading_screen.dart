import 'package:flutter/material.dart';
import 'dart:math' as math; // 원을 그리기 위해 math.pi 사용

// --- ⭐️ 1. 이 함수를 호출하여 팝업을 띄웁니다 ⭐️ ---
// 닉네임은 나중에 로그인한 유저의 닉네임을 넣어주세요.
void showLifestyleLoadingPopup(BuildContext context, String nickname) {
  showDialog(
    context: context,
    // ⭐️ 로딩 중에는 밖을 눌러도 닫히지 않게 설정
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        // 팝업 모서리 둥글게
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        // ⭐️ 팝업 내용물
        child: _LoadingPopupContent(nickname: nickname),
      );
    },
  );
}

// --- ⭐️ 2. 팝업의 내용 (스피너 + 텍스트) ⭐️ ---
class _LoadingPopupContent extends StatelessWidget {
  final String nickname;

  // ⭐️ 요청하신 색상 정의: 4C6DAF 75%
  static const Color textColor = Color(0xBF4C6DAF); // 0.75 * 255 = 191 = 0xBF

  const _LoadingPopupContent({required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ⭐️ 341x241 대신 반응형 크기를 사용합니다.
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      // ⭐️ 팝업 내용이 넘치지 않도록 MainAxisSize.min 사용
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ⭐️ 3. 회전하는 커스텀 로딩 스피너
          const _LoadingSpinner(size: 80.0), // 스피너 크기
          const SizedBox(height: 28),
          Text(
            "$nickname님의 취향을 파악 중 입니다.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "잠시만 기다려 주세요!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ⭐️ 3. (핵심) 커스텀 로딩 스피너 애니메이션 위젯 ⭐️ ---
class _LoadingSpinner extends StatefulWidget {
  final double size;
  // ⭐️ 요청하신 색상 정의: 4C6DAF 100%
  static const Color baseColor = Color(0xFF4C6DAF);

  const _LoadingSpinner({this.size = 80.0});

  @override
  State<_LoadingSpinner> createState() => _LoadingSpinnerState();
}

// ⭐️ SingleTickerProviderStateMixin을 사용하여 애니메이션 컨트롤러 생성
class _LoadingSpinnerState extends State<_LoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 1초에 한 바퀴
    )..repeat(); // ⭐️ 애니메이션 무한 반복
  }

  @override
  void dispose() {
    _controller.dispose(); // ⭐️ 위젯이 사라질 때 컨트롤러 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      // ⭐️ 1. 애니메이션 컨트롤러에 따라 위젯을 회전시킵니다.
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          // ⭐️ 2. 12개의 점을 생성합니다.
          children: List.generate(12, (i) {
            // 30도씩 (pi / 6) 회전
            final double angle = (math.pi / 6) * i;
            // 100% (1.0) 부터 10%씩(1/12) 옅어지게 설정
            final double opacity = 1.0 - (i / 12.0);
            // 점 크기
            final double dotSize = widget.size * 0.12;

            // ⭐️ 3. 각 점을 Transform.rotate로 회전시키고
            // Align(Alignment.topCenter)로 상단에 배치
            return Transform.rotate(
              angle: angle,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    // ⭐️ 4. 요청하신 옅어지는 색상 적용
                    color: _LoadingSpinner.baseColor.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}