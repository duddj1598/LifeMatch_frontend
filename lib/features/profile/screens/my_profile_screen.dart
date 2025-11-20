import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/profile/services/profile_api.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final StorageService _storage = StorageService();

  String accessToken = "";
  String userId = "";

  // 실제 데이터
  String _nickname = "닉네임";
  String _lifestyleType = "";
  String _keywords = "";
  String _description = "";
  String _email = "";

  @override
  void initState() {
    super.initState();
    _loadStoredInfo();
  }

  Future<void> _loadStoredInfo() async {
    accessToken = await _storage.getToken() ?? "";
    userId = await _storage.getUserId() ?? "";

    if (accessToken.isEmpty || userId.isEmpty) {
      print("❌ 토큰/유저ID 없음");
      return;
    }

    // API 연동
    final data = await ProfileApi.getUserProfile(userId, accessToken);

    if (data != null) {
      setState(() {
        _nickname = data["user_nickname"];
        _email = data["user_email"];

        final lifestyle = data["lifestyle_info"];

        if (lifestyle != null) {
          _lifestyleType = lifestyle["type_name"] ?? "";
          _keywords = lifestyle["keywords"] ?? "";
          _description = lifestyle["description"] ?? "";
        } else {
          _lifestyleType = "";
          _keywords = "";
          _description = "";
          print("⚠️ lifestyle_info 가 null");
        }

      });
    }
  }

  // 프로필 수정, 알림 설정, 로그아웃
  void _handleSettingsTap(String label) async {
    if (label == "프로필 수정") {
      final result = await Navigator.pushNamed(context, "/edit-profile");

      if (result == true) {
        print("🔄 프로필 변경됨 → 새로고침 실행");
        await _loadStoredInfo();
        setState(() {});
      }
    } else if (label == "알림 설정") {
      Navigator.pushNamed(context, "/settings");
    } else if (label == "로그아웃") {
      _showLogoutDialog();
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text("로그아웃하시겠어요?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Divider(height: 1),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _storage.deleteAll();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                child: const Text(
                  "로그아웃",
                  style: TextStyle(
                      color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                child: const Text(
                  "취소",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "마이페이지",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // --------------------------- 프로필 영역 ---------------------------
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nickname,
                      style:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _email,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 25),

            // --------------------------- 라이프스타일 카드 ---------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Column(
                children: [
                  const Text(
                    "라이프스타일 유형",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "“$_lifestyleType”",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _keywords,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, height: 1.4, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------- 활동 리포트 ---------------------------
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("[ 나의 활동 리포트 ]",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 10),
                  Text("이번 달 참여 활동 : 4회", style: TextStyle(fontSize: 13)),
                  Text("이번 달 추천 활동 참여율 : 75%", style: TextStyle(fontSize: 13)),
                  Text("가장 활발한 카테고리 : ‘여가 · 문화’",
                      style: TextStyle(fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------- 설정 ---------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("[ 설정 ]",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 10),
                  _settingItem("프로필 수정"),
                  _settingItem("알림 설정"),
                  _settingItem("로그아웃"),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'profile',
        onTabSelected: (tag) {
          if (tag == 'profile') return;
          Navigator.pushNamed(context, '/$tag');
        },
      ),
    );
  }

  Widget _settingItem(String label) {
    return InkWell(
      onTap: () => _handleSettingsTap(label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
