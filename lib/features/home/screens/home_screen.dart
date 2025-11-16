import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/team_management/screens/team_detail_screen.dart'; // ✅ TeamDetailScreen import 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ 하단바 클릭 처리
  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        print('🏠 홈 이동');
        break;
      case 'chat':
        print('💬 채팅 탭');
      case 'connection':
        print('🔗 소모임 연결');
        Navigator.pushNamed(context, '/my-group-manage');
        break;
        break;
      case 'bell':
        print('🔔 알림 탭');
        break;
      case 'profile':
        print('👤 프로필 탭');
        break;
    }
  }

  // ✅ 카테고리 클릭 시 TeamDetailScreen으로 이동
  void _navigateToTeamDetail(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // ⭐️ 1. builder 부분을 수정
        builder: (context) => TeamDetailScreen(
          selectedCategory: category, // 👈 ⭐️ 클릭한 카테고리 이름 전달
        ),
      ),
    );
    print('📂 $category 카테고리 선택 → TeamDetailScreen 이동');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black54),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E3F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 30),
                  const Expanded(
                    child: Text(
                      '당신과 비슷한 사람들과\n모임을 즐겨보세요!!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ 오늘의 추천 활동
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      '오늘의 추천 활동',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 16)),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                          children: [
                            TextSpan(
                              text: '"균형형 탐험가" ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            TextSpan(text: '유형에게 추천되는 활동이에요!'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _buildRecommendationItem('"도심 속 피크닉 모임"'),
                  const SizedBox(height: 10),
                  _buildRecommendationItem('"주말 독서모임 모집"'),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 16)),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                          children: [
                            TextSpan(
                              text: '다른',
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(text: ' 유형에게 추천되는 활동 더보기'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ✅ 카테고리 그리드 (onTap 추가)
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildCategoryCard(
                    '소비 · 경제',
                    'assets/images/economy_icon.png',
                    const Color(0xFFFFF9E6),
                        () => _navigateToTeamDetail('소비 · 경제'),
                  ),
                  _buildCategoryCard(
                    '생활습관 · 건강',
                    'assets/images/health_icon.png',
                    const Color(0xFFE8F5E9),
                        () => _navigateToTeamDetail('생활습관 · 건강'),
                  ),
                  _buildCategoryCard(
                    '기술',
                    'assets/images/technology_icon.png',
                    const Color(0xFFE3F2FD),
                        () => _navigateToTeamDetail('기술'),
                  ),
                  _buildCategoryCard(
                    '여가 · 문화',
                    'assets/images/culture_icon.png',
                    const Color(0xFFFFF3E0),
                        () => _navigateToTeamDetail('여가 · 문화'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ 기존 BottomNavigationBar 대신 CustomBottomNavBar 연결
      bottomNavigationBar: CustomBottomNavBar(
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // ✅ 추천 활동 아이템
  static Widget _buildRecommendationItem(String title) {
    return Row(
      children: [
        const Text('• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFBDBDBD)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '세부정보',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // ✅ 카테고리 카드 (onTap 파라미터 추가)
  Widget _buildCategoryCard(
      String title, String imagePath, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // ✅ 클릭 시 TeamDetailScreen으로 이동
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}