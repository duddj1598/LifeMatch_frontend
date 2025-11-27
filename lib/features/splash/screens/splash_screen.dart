import 'dart:async';
import 'package:flutter/material.dart';
// ⭐️ 로그인 화면이나 홈 화면을 import 하세요
import 'package:lifematch_frontend/features/auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ⏳ 2.5초 뒤에 다음 화면으로 이동
    Timer(const Duration(milliseconds: 2500), () {
      // pushReplacement를 써야 뒤로가기 했을 때 다시 스플래쉬가 안 나옵니다.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        // 👆 LoginScreen 대신 홈 화면이나 다른 화면으로 바꿔도 됩니다.
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
          children: [
            // 🔹 1. 상단 텍스트
            const Text(
              "당신의 라이프,\n나와 맞는 매치",
              textAlign: TextAlign.center, // 텍스트 가운데 정렬
              style: TextStyle(
                // ⭐️ 지정해주신 색상
                color: Color(0xFF4C6DAF),
                fontSize: 24, // 폰트 크기 (이미지 비율에 맞춰 조절 가능)
                fontWeight: FontWeight.w500, // 너무 굵지 않은 적당한 두께
                height: 1.4, // 줄 간격 살짝 띄우기
              ),
            ),

            const SizedBox(height: 16), // 텍스트와 로고 사이 간격

            // 🔹 2. 로고 이미지
            Image.asset(
              'assets/images/logo_text.png',
              width: 220, // 로고 크기 조절 (화면에 맞춰 변경하세요)
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}