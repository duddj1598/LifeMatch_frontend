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
import 'features/connection/screens/my_group_manage_screen.dart';
import 'package:lifematch_frontend/features/chat/screens/chat_screen.dart';
import 'package:lifematch_frontend/features/chat/screens/chat_group_detail_screen.dart';
import 'package:lifematch_frontend/features/chat/screens/chat_personal_detail_screen.dart';
import 'package:lifematch_frontend/features/profile/screens/my_profile_screen.dart';
import 'package:lifematch_frontend/features/profile/screens/edit_profile_screen.dart';

//테스트 임포트
import 'features/notification/screens/notification_screen.dart';

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

        '/style_test': (context) => const LifestyleTestScreen(),
        '/my-group-manage': (context) => const MyGroupManageScreen(),


        '/notification': (context) => const NotificationScreen(),
        '/chat': (context) => const ChatScreen(),
        '/chat-group-detail': (context) => const ChatGroupDetailScreen(),
        '/chat-personal-detail': (context) => const ChatPersonalDetailScreen(),
        '/my-profile': (context) => const MyProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      //   '/invite': (context) {
      //     // ⭐️ [수정] settings.arguments에서 실제 groupId를 추출합니다.
      //     final groupId = ModalRoute.of(context)!.settings.arguments as String;
      //
      //     // ⭐️ [수정] 추출한 groupId를 MemberInviteScreen에 전달합니다.
      //     //          나머지 필드는 필요하다면 해당 라우트에서 처리하거나,
      //     //          MemberInviteScreen의 생성자에 맞게 기본값/널 값을 지정합니다.
      //     return MemberInviteScreen(
      //       groupId: groupId, // ✅ 실제 그룹 ID 전달
      //       initialGroupDetail: null, // 기존대로 유지
      //       selectedCategory: "category", // 기존대로 유지
      //     );
      //   },

       },
    );
  }
}
