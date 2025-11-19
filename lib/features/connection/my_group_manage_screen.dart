import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

class MyGroupManageScreen extends StatelessWidget {
  const MyGroupManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            // '/home' 라우트로 이동하며 현재 화면을 대체합니다.
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text(
          "내 소모임 관리",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 28),

            // 📩 소모임 초대
            _sectionTitle("📩 소모임 초대", "받은 초대장"),
            const SizedBox(height: 12),
            _groupList(isInvite: true),

            const SizedBox(height: 32),

            // 👥 소모임 신청자
            _sectionTitle("👥 내 소모임 신청자", "가입 대기 중"),
            const SizedBox(height: 12),
            _groupList(isInvite: false),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // ⭐️ 수정된 네비게이션 핸들러
      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'connection',
        onTabSelected: (tag) {
          switch (tag) {
            case 'home':
              print('🏠 홈 이동');
              // 홈으로 이동 (쌓인 스택 제거 후 이동 추천, 여기선 요청대로 pushNamed 사용)
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              break;
            case 'chat':
              print('💬 채팅 탭');
              Navigator.pushNamed(context, '/chat');
              break;
            case 'connection':
              print('🔗 소모임 연결');
              // 현재 화면이므로 이동 로직 없음
              break;
            case 'bell':
              print('🔔 알림 탭');
              Navigator.pushNamed(context, '/notification');
              break;
            case 'profile':
              print('👤 프로필 탭');
              Navigator.pushNamed(context, '/my-profile');
              break;
          }
        },
      ),
    );
  }

  // 📌 섹션 타이틀
  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // 📌 리스트 UI
  Widget _groupList({required bool isInvite}) {
    return Column(
      children: List.generate(
        3,
            (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 대표 사진 박스
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE8E3F5),
                      Color(0xFFD4CEE8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "사진",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // 소모임 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "[소모임 이름 ${index + 1}]",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "투자·소비습관",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 버튼
              ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF9AA8DA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isInvite ? "설정" : "세부사항",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}