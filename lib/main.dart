import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeMatch',
      theme: ThemeData(primarySwatch: Colors.blue),

      // ✅ 앱 시작 시 LoginScreen으로 이동
      home: const LoginScreen(),

      // ✅ 네비게이션 라우트 등록
      routes: {
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
