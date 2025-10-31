import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart'; // 하단바 위젯 import

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({super.key});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  bool isCreateSelected = true;

  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        print('홈 이동');
        break;
      case 'connection':
        print('소모임 연결');
        break;
      case 'chat':
        print('채팅 탭 이동');
        break;
      case 'bell':
        print('알림 탭 이동');
        break;
      case 'profile':
        print('프로필 탭 이동');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text(
          "세부사항 선택 (팀장)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 제목
            const Text(
              "카테고리",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7AA1),
              ),
            ),
            const SizedBox(height: 20),

            // 소모임 개설 / 참여 탭 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSelectButton("소모임 개설", true),
                const SizedBox(width: 10),
                _buildSelectButton("소모임 참여", false),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              "모임 설정을 완료 해 주세요",
              style: TextStyle(color: Color(0xFF6B7AA1)),
            ),
            const SizedBox(height: 16),

            // 모임 설정 폼 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF6B7AA1), width: 1.2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 대표 사진 설정
                  const Text(
                    "대표 사진 설정",
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFFECECEC),
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload),
                        label: const Text("사진 업로드"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9AA8DA),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 입력 필드들
                  _buildTextField("소모임 이름", "2~10자 내외로 설정 해 주세요"),
                  _buildTextField("소모임 설명", "30자 이내로 작성 해 주세요"),
                  _buildTextField("소모임 모임 장소", "30자 이내로 작성 해 주세요"),
                  _buildTextField("소모임 인원 수", "2~10자 내외로 설정 해 주세요"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 다음 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9AA8DA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "다음",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(onTabSelected: _handleBottomTap),
    );
  }

  // 🔹 재사용 가능한 텍스트필드 위젯
  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF2F2F2),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 소모임 개설/참여 버튼
  Widget _buildSelectButton(String text, bool isCreate) {
    final isSelected = (isCreateSelected == isCreate);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isCreateSelected = isCreate;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9AA8DA)
                : const Color(0xFFF7F7F7),
            border: Border.all(color: const Color(0xFF9AA8DA)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF6B7AA1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isCreate
                    ? "나만의 소모임을 직접\n만들어보세요!"
                    : "나에게 꼭 맞는\n모임을 찾아보세요!",
                textAlign: TextAlign.center, // 💡 줄바꿈 & 중앙정렬
                style: TextStyle(
                  color:
                  isSelected ? Colors.white70 : const Color(0xFF6B7AA1),
                  fontSize: 12,
                  height: 1.3, // 줄 간격
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
