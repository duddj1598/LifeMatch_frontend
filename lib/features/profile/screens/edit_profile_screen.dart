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

  String accessToken = "";

  // 활동 선호도
  bool preferEconomy = true;
  bool preferHealth = false;
  bool preferTech = true;
  bool preferCulture = true;

  @override
  void initState() {
    super.initState();
    _loadCreds();
  }

  Future<void> _loadCreds() async {
    accessToken = await _storage.getToken() ?? "";

    print("🟪 Loaded AccessToken = $accessToken");
  }

  // 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // 저장
  Future<void> _saveProfile() async {
    print("🟣 PATCH 요청 직전 accessToken = $accessToken");

    if (accessToken.isEmpty) {
      print("❌ 저장 불가: accessToken 없음");
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
      "profile_image": null, // 실제 파일 업로드는 별도 구현 가능
    };

    print("🟦 PATCH 요청 데이터: $body");

    final success = await ProfileApi.updateProfile(accessToken, body);

    if (success) {
      print("✅ 프로필 수정 성공!");
      Navigator.pop(context, true); // MyProfileScreen 새로고침
    } else {
      print("❌ 프로필 수정 실패");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("프로필 수정에 실패했습니다."),
          backgroundColor: Colors.redAccent,
        ),
      );
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

  // 프로필 사진 영역
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

  // 닉네임 입력
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

  // 활동 선호도 영역
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

  // 스위치 UI
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

  // 저장 버튼
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8EAF6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          "저장",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
