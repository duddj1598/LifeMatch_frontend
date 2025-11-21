import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:lifematch_frontend/features/profile/services/profile_api.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final StorageService _storage = StorageService();

  File? _profileImage;
  final TextEditingController _nicknameController = TextEditingController();

  String userId = "";
  String accessToken = "";

  // 활동 선호도
  bool preferEconomy = true;
  bool preferHealth = false;
  bool preferTech = true;
  bool preferCulture = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// ---------------------------
  /// JWT, userId 불러오고 기존 프로필 로드
  /// ---------------------------
  Future<void> _loadInitialData() async {
    accessToken = await _storage.getToken() ?? "";
    userId = await _storage.getUserId() ?? "";

    if (accessToken.isEmpty || userId.isEmpty) {
      print("❌ 사용자 인증 정보 없음");
      return;
    }

    final profile = await ProfileApi.getUserProfile(userId, accessToken);
    if (profile != null) {
      _nicknameController.text = profile["user_nickname"] ?? "";

      final prefs = profile["activity_preferences"];
      if (prefs != null) {
        preferEconomy = prefs["economy"] ?? true;
        preferHealth = prefs["health"] ?? false;
        preferTech = prefs["tech"] ?? true;
        preferCulture = prefs["culture"] ?? true;
      }

      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  /// ---------------------------
  /// 프로필 저장
  /// ---------------------------
  Future<void> _saveProfile() async {
    if (accessToken.isEmpty || userId.isEmpty) {
      print("❌ 저장 불가: userId/token 없음");
      return;
    }

    final body = {
      "user_nickname": _nicknameController.text,
      "activity_preferences": {
        "economy": preferEconomy,
        "health": preferHealth,
        "tech": preferTech,
        "culture": preferCulture,
      },
      "profile_image": null,   // 이미지 업로드 기능 추후 구현
    };

    print("🟦 PATCH 요청 데이터 → $body");

    final success = await ProfileApi.updateProfile(
      userId,
      accessToken,
      body,
    );

    if (success) {
      print("✅ 프로필 수정 성공!");
      Navigator.pop(context, true);
    } else {
      print("❌ 프로필 수정 실패");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "프로필 수정",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileImage(),
            const SizedBox(height: 30),

            _buildNicknameInput(),
            const SizedBox(height: 28),

            _buildPreferenceSection(),
            const SizedBox(height: 40),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _profileImage == null
                  ? const Icon(Icons.person, size: 80, color: Colors.grey)
                  : Image.file(_profileImage!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_rounded),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              IconButton(
                icon: const Icon(Icons.photo_library_rounded),
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("닉네임 수정",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: "닉네임을 입력해주세요",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("활동 선호도",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        _buildSwitch("소비 · 경제", preferEconomy,
                (v) => setState(() => preferEconomy = v)),
        _buildSwitch("생활습관 · 건강", preferHealth,
                (v) => setState(() => preferHealth = v)),
        _buildSwitch("기술", preferTech,
                (v) => setState(() => preferTech = v)),
        _buildSwitch("여가 · 문화", preferCulture,
                (v) => setState(() => preferCulture = v)),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8EAF6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          "저장",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
