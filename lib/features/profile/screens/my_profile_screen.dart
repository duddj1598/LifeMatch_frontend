import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

// 앱의 메인 색상 (예시로 지정, 실제 앱에 맞게 조정 필요)
const Color kPrimaryColor = Color(0xFF5A67F2); // 밝은 보라/파랑 계열
const Color kAccentColor = Color(0xFFFFC107); // 강조 색상

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  // 실제 데이터가 들어갈 예정인 변수들
  final String _nickname = "라이프매치";
  final String _userId = "user_id_001";
  final String _lifestyleType = "디지털 트렌드 세터";
  final String _lifestyleKeywords = "#신상 #IT #여행 #AI #소비";
  final String _lifestyleDescription =
      "새로운 기술과 트렌드를 빠르게 반응하여,\n일상 속에서 변화를 즐기는 사람입니다.";

  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        Navigator.pushNamed(context, '/home');
        break;
      case 'chat':
        Navigator.pushNamed(context, '/chat');
        break;
      case 'connection':
        Navigator.pushNamed(context, '/my-group-manage');
        break;
      case 'bell':
        Navigator.pushNamed(context, '/notification');
        break;
      case 'profile':
        break; // 현재 페이지
    }
  }

  void _navigateToEditProfile() {
    // 프로필 수정 페이지 이동 로직
    debugPrint("프로필 수정 페이지로 이동");
  }

  void _handleSettingsTap(String setting) {
    // 설정 항목별 이동/액션 로직
    debugPrint("'$setting' 항목 선택됨");
    if (setting == "로그아웃") {
      // 로그아웃 로직
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // 배경색을 미세하게 변경하여 카드와 대비
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        automaticallyImplyLeading: false,
        title: const Text(
          "마이페이지",
          style: TextStyle(
            color: Colors.black87, // 글자색 강조
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 프로필 영역
            _buildProfileSection(),
            const SizedBox(height: 20),

            // 🌟 라이프스타일 유형 UI
            _buildLifestyleCard(),
            const SizedBox(height: 20),

            // 📈 활동 리포트
            _buildActivityReportCard(),
            const SizedBox(height: 20),

            // ⚙️ 설정
            _buildSettingsCard(),
            const SizedBox(height: 40), // 하단 여백 추가
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'profile',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // 👤 프로필 섹션 위젯
  Widget _buildProfileSection() {
    return Card(
      elevation: 4, // 그림자 추가
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // 유저 이미지
                CircleAvatar(
                  radius: 40,
                  backgroundColor: kPrimaryColor.withOpacity(0.1),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nickname,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userId,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // 프로필 수정 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text("프로필 수정", style: TextStyle(fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryColor,
                  side: const BorderSide(color: kPrimaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔷 라이프스타일 유형 카드 위젯
  Widget _buildLifestyleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "✨ 나의 라이프스타일 유형",
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20, thickness: 0.5),
            Center(
              child: Column(
                children: [
                  Text(
                    _lifestyleType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 키워드 뱃지
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: _lifestyleKeywords
                        .split(' ')
                        .map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 13, color: Colors.white)),
                      backgroundColor: kPrimaryColor.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _lifestyleDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔷 활동 리포트 카드 위젯
  Widget _buildActivityReportCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📊 활동 리포트",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 20, thickness: 0.5),
            _buildReportItem(
                "이번 달 참여 활동", "4회", Icons.calendar_today_rounded),
            _buildReportItem(
                "추천 활동 참여율", "75%", Icons.percent_rounded),
            _buildReportItem(
                "가장 활발한 카테고리", "여가 · 문화", Icons.category_rounded,
                isHighlight: true),
          ],
        ),
      ),
    );
  }

  // 활동 리포트 개별 항목 위젯
  Widget _buildReportItem(String label, String value, IconData icon,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: kPrimaryColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isHighlight
                  ? kAccentColor.withOpacity(0.2)
                  : kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? kAccentColor : kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⚙️ 설정 카드 위젯
  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                "⚙️ 설정 및 지원",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
            const Divider(height: 20, thickness: 0.5),
            _buildSettingsItem("프로필 수정", Icons.person_outline_rounded),
            _buildSettingsItem("알림 설정", Icons.notifications_none_rounded),
            _buildSettingsItem("FAQ/문의", Icons.help_outline_rounded),
            _buildSettingsItem("로그아웃", Icons.logout_rounded, isLogout: true),
          ],
        ),
      ),
    );
  }

  // 설정 개별 항목 위젯 (ListTile 형태)
  Widget _buildSettingsItem(String label, IconData icon,
      {bool isLogout = false}) {
    return InkWell(
      onTap: () => _handleSettingsTap(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: Icon(icon, color: isLogout ? Colors.redAccent : kPrimaryColor),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isLogout ? Colors.redAccent : Colors.black87,
              fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              size: 18, color: Colors.grey),
        ),
      ),
    );
  }
}