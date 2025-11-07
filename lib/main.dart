import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/screens/team_detail_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/memberInvite_screen.dart';
import 'features/auth/screens/find_id_screen.dart';
import 'features/auth/screens/find_pw_screen.dart';

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

      // ✅ 앱이 시작할 때 바로 이동할 첫 화면
      initialRoute: '/login',

      // ✅ 네비게이션 라우트 등록
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/find_id': (context) => const FindIdScreen(),
        '/find_pw': (context) => const FindPwScreen(),
      },

    );
  }
}
