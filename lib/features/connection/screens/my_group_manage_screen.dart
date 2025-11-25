import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import '../../group/screens/group_detail_screen.dart';

// ⭐️ [추가] TeamManagementScreen 임포트
import 'package:lifematch_frontend/features/team_management/screens/team_management_screen.dart';


class MyGroupManageScreen extends StatelessWidget {
  const MyGroupManageScreen({super.key});

  // ⭐️ [추가] TeamManagementScreen으로 이동하는 함수
  void _navigateToTeamManagement(BuildContext context, String groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // TODO: 실제 소모임 ID를 TeamManagementScreen에 전달해야 합니다.
        builder: (context) => TeamManagementScreen(groupId: groupId),
      ),
    );
  }

  // ⭐️ [추가] GroupDetailScreen으로 이동하는 함수
  void _navigateToGroupDetail(BuildContext context, String groupId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(
          // 세부사항 조회는 참가/문의 버튼 타입을 사용합니다.
          buttonType: GroupDetailButtonType.none,
          // TODO: 소모임 ID도 전달 가능
          groupId: groupId,
        ),
      ),
    );
  }

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

            // ⚙️ 내가 관리하는 소모임 (isInvite: true -> '설정' 버튼)
            _sectionTitle("⚙️ 내가 관리하는 소모임", "소모임 세부사항 설정"),
            const SizedBox(height: 12),
            _groupList(context, isInvite: true),

            const SizedBox(height: 32),

            // 👥 내가 참가하는 소모임 (isInvite: false -> '세부사항' 버튼)
            _sectionTitle("👥 내가 참가하는 소모임", "소모임 세부사항 조회"),
            const SizedBox(height: 12),
            _groupList(context, isInvite: false),
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
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 'chat':
              Navigator.pushReplacementNamed(context, '/chat');
              break;
            case 'connection':
              break;
            case 'bell':
              Navigator.pushReplacementNamed(context, '/notification');
              break;
            case 'profile':
              Navigator.pushReplacementNamed(context, '/my-profile');
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
  Widget _groupList(BuildContext context, {required bool isInvite}) {
    return Column(
      children: List.generate(
        3,
            (index) {
          final String groupId = isInvite ? 'manage_id_$index' : 'joined_id_$index';

          // ⭐️ [수정] onPressed 로직 분리 및 네비게이션 함수 연결
          void onPressedHandler() {
            print('${isInvite ? "설정" : "세부사항"} 버튼 클릭 - 소모임 ID: $groupId');

            if (isInvite) {
              // '내가 관리하는 소모임' → '설정' 버튼 클릭 시 TeamManagementScreen으로 이동
              _navigateToTeamManagement(context, groupId);
            } else {
              // '내가 참가하는 소모임' → '세부사항' 버튼 클릭 시 GroupDetailScreen으로 이동
              _navigateToGroupDetail(context, groupId);
            }
          }

          return Container(
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
                        "[소모임 이름 ${groupId}]",
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
                  onPressed: onPressedHandler, // ⭐️ 분리된 핸들러 연결
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: isInvite ? const Color(0xFF9AA8DA) : const Color(0xFF9AA8DA), // 설정은 파란색, 세부사항은 회색으로 구분 가능
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
          );
        },
      ),
    );
  }
}