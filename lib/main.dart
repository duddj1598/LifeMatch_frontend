//패키지 임포트
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lifematch_frontend/features/auth/viewmodels/auth_viewmodel.dart';
//화면 임포트
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/find_id_screen.dart';
import 'features/auth/screens/find_pw_screen.dart';
import 'features/lifestyle_test/screens/lifestyle_test_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/connection/my_group_manage_screen.dart';

//테스트 임포트
import 'features/team_management/screens/team_detail_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthViewModel(), // AuthViewModel 생성
      child: const MyApp(),
    ),
  );
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
        '/home': (context) => const HomeScreen(),

        '/team_detail': (context) => const TeamDetailScreen(),
        '/style_test': (context) => const LifestyleTestScreen(),
        '/my-group-manage': (context) => const MyGroupManageScreen(),
      },

    );
  }
}
