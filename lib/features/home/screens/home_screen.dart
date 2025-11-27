import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/team_management/screens/team_detail_screen.dart';
import 'package:lifematch_frontend/features/group/screens/group_detail_screen.dart';

// 🔥 추가된 import
import 'package:lifematch_frontend/features/home/services/home_service.dart';
import 'package:lifematch_frontend/features/home/models/home_recommendation_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 🔥 Home API 데이터
  HomeRecommendation? _homeData;
  bool _isLoading = true;

  final HomeService _homeService = HomeService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  /// 🔥 Home API + JWT Token 포함하여 요청
  Future<void> _loadHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? accessToken = await _storageService.getToken();

      if (accessToken == null) {
        print("⚠️ accessToken 없음 → 로그인 필요");
        setState(() => _isLoading = false);
        return;
      }

      final res = await _homeService.getHomeRecommendations(accessToken);

      setState(() {
        _homeData = res;
        _isLoading = false;
      });

    } catch (e) {
      print("❌ 홈 데이터 로딩 실패: $e");

      setState(() {
        _isLoading = false; // 무한로딩 방지
        _homeData = null;
      });
    }
  }

  // 하단바 이동 처리
  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'chat':
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 'connection':
        Navigator.pushReplacementNamed(context, '/my-group-manage');
        break;
      case 'bell':
        Navigator.pushReplacementNamed(context, '/notification');
        break;
      case 'profile':
        Navigator.pushReplacementNamed(context, '/my-profile');
        break;
    }
  }

  // 카테고리 이동
  void _navigateToTeamDetail(String category) {
    print("✅ 카테고리 선택: $category. TeamDetailScreen으로 직접 이동하며 인자 전달.");
    // ⭐️ MaterialPageRoute를 사용하여 TeamDetailScreen으로 이동하며 category 인자 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailScreen(
          selectedCategory: category, // ⭐️ selectedCategory 필드에 값 전달
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 16),

            _buildRecommendationSection(),

            const SizedBox(height: 25),

            _buildCategoryGrid(),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'home',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // -------------------------------
  // 🟣 HEADER 영역
  // -------------------------------
  Widget _buildHeader() {
    return Container(
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
    );
  }

  // -------------------------------
  // 🟣 추천 활동 영역 (API 기반)
  // -------------------------------
  Widget _buildRecommendationSection() {
    if (_homeData == null) {
      return const Text("추천 데이터를 불러올 수 없습니다.");
    }

    final lifestyle = _homeData!.userLifestyleType;
    final activities = _homeData!.recommendedActivities;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '오늘의 추천 활동',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lifestyle type 표시
          Row(
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 10)),
              Text(
                '"$lifestyle" 유형에게 추천되는 활동이에요!',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 🔥 추천 활동 반복 렌더링
          ...activities.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildRecommendationItem(
                '"${item.groupName}"',
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupDetailScreen(
                        buttonType: GroupDetailButtonType.joinOrInquire,
                        groupId: item.groupId,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),

          const SizedBox(height: 10),

          Row(
            children: const [

            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // 추천 아이템 Row
  // -------------------------------
  static Widget _buildRecommendationItem(
      String title, VoidCallback onDetailTap) {
    return Row(
      children: [
        const Text(
          '• ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onDetailTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFBDBDBD)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '세부정보',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // 카테고리 Grid
  // -------------------------------
  Widget _buildCategoryGrid() {
    return Expanded(
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
    );
  }

  Widget _buildCategoryCard(
      String title, String imagePath, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
                ),
              ),
            ),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
