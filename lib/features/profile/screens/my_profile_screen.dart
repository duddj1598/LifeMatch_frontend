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

  String _nickname = "닉네임";
  String _email = "";
  String _lifestyleType = "";
  String _keywords = "";
  String _description = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    accessToken = await _storage.getToken() ?? "";

    print("🟣 Loaded accessToken = $accessToken");

    if (accessToken.isEmpty) {
      print("❌ accessToken 없음");
      return;
    }

    final data = await ProfileApi.getUserProfile(accessToken);

    if (data != null) {
      setState(() {
        _nickname = data["user_nickname"] ?? "";
        _email = data["user_email"] ?? "";

        final lifestyle = data["lifestyle_info"];

        if (lifestyle != null) {
          _lifestyleType = lifestyle["type_name"] ?? "";
          _keywords = lifestyle["keywords"] ?? "";
          _description = lifestyle["description"] ?? "";
        } else {
          _lifestyleType = "아직 검사 전";
          _keywords = "";
          _description = "라이프스타일 유형 검사를 완료하면 표시됩니다.";
        }
      });
    }
  }

  void _handleSettingsTap(String label) async {
    if (label == "프로필 수정") {
      final result = await Navigator.pushNamed(context, "/edit-profile");
      if (result == true) {
        await _loadProfile();
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
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                child: const Text("로그아웃",
                    style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                child: const Text("취소", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "마이페이지",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildProfileHeader(),

            const SizedBox(height: 25),

            _buildLifestyleCard(),

            const SizedBox(height: 20),

            _buildSettingsCard(),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'profile',
        onTabSelected: (tag) {
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
              break;
          }
        },
      ),
    );
  }

  // ---------------------- UI 위젯들 ----------------------

  Widget _buildProfileHeader() {
    return Row(
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
            Text(_nickname,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            Text(_email, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildLifestyleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          const Text("라이프스타일 유형",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text("“$_lifestyleType”",
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(_keywords,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(_description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, height: 1.4, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("[ 설정 ]",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          _settingItem("프로필 수정"),
          _settingItem("알림 설정"),
          _settingItem("로그아웃"),
        ],
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
