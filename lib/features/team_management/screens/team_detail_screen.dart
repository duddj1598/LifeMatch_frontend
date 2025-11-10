import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart'; // 하단바 위젯 import

class TeamDetailScreen extends StatefulWidget {
  const TeamDetailScreen({super.key});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}


class _TeamDetailScreenState extends State<TeamDetailScreen> {
  bool isCreateSelected = true;

  final List<Map<String, String>> _groupList = [
    {"title": "[소모임 이름]", "topic": "투자ㆍ소비습관"},
    {"title": "[소모임 이름]", "topic": "투자ㆍ소비습관"},
    {"title": "[소모임 이름]", "topic": "투자ㆍ소비습관"},
    {"title": "[소모임 이름]", "topic": "투자ㆍ소비습관"},
    {"title": "[소모임 이름]", "topic": "투자ㆍ소비습관"},
    {"title": "[소모임 이름]", "topic": "운동ㆍ헬스"},
    {"title": "[소모임 이름]", "topic": "맛집 탐방"},
    {"title": "[소모임 이름]", "topic": "반려동물"},
    {"title": "[소모임 이름]", "topic": "코딩 스터디"},
  ];

  // ⭐️ 1. "더보기"를 위한 카운터 변수 추가
  int _groupCounter = 1;

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
        // ... (기존 AppBar)
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
      // ⭐️ 기존 SingleChildScrollView 레이아웃 유지
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ... (제목, 탭 버튼)
            const Text(
              "카테고리",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7AA1),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSelectButton("소모임 개설", true),
                const SizedBox(width: 10),
                _buildSelectButton("소모임 참여", false),
              ],
            ),
            const SizedBox(height: 16),

            // 탭에 따라 UI 변경
            if(isCreateSelected)
              _buildCreateForm()
            else
              _buildJoinList() // ⭐️ "더보기" 기능이 추가된 _buildJoinList

          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(onTabSelected: _handleBottomTap),
    );
  }

  // --- "소모임 개설" 폼 (기존과 동일) ---
  Widget _buildCreateForm() {
    return Column(
      children: [
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
              // ... (대표 사진 설정) ...
              const Text(
                "대표 사진 설정",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

              // ... (입력 필드들) ...
              _buildTextField("소모임 이름", "2~10자 내외로 설정 해 주세요"),
              _buildTextField("소모임 설명", "30자 이내로 작성 해 주세요"),
              _buildTextField("소모임 모임 장소", "30자 이내로 작성 해 주세요"),
              _buildTextField("소모임 인원 수", "2~10자 내외로 설정 해 주세요"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ... (다음 버튼) ...
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
    );
  }

  // --- "소모임 참여" 목록 (⭐️ 2. ListView.builder로 수정) ---
  Widget _buildJoinList() {
    return Column(
      children: [
        // 검색창
        _buildSearchBar(),
        const SizedBox(height: 20),

        // 소모임 목록 (ListView.builder로 변경)
        ListView.builder(
          // ⭐️ SingleChildScrollView 내부에 있으므로 스크롤 충돌 방지
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          padding: EdgeInsets.zero, // 바깥 Column이 패딩을 관리
          itemCount: _groupList.length + 1, // ⭐️ 목록 + 더보기 버튼
          itemBuilder: (context, index) {
            if (index == _groupList.length) {
              // ⭐️ 마지막 항목은 "더보기" 버튼
              return _buildGroupMoreButton();
            } else {
              // ⭐️ 목록 아이템
              final group = _groupList[index];
              return _buildGroupListItem(
                group['title']!,
                group['topic']!,
              );
            }
          },
        ),
      ],
    );
  }

  // 🔹 검색창 위젯 (기존과 동일)
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4C6DAF), width: 1.0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "관심 있는 주제를 검색해보세요.",
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7AA1)),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }


// 🔹 소모임 목록 아이템 위젯 (⭐️ 버튼 로직 수정)
  Widget _buildGroupListItem(String title, String topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ... (대표 사진)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFECECEC),
            ),
            child: const Center(
                child: Text("대표\n사진",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey))),
          ),
          const SizedBox(width: 12),

          // ... (소모임 정보)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "주제 : $topic",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ⭐️ 세부정보 버튼
          ElevatedButton(
            // ⭐️ 1. onPressed 로직 수정
            onPressed: () {
              // ⭐️ 2. 디버그 콘솔에 메시지 출력
              print("페이지 이동! (세부정보: $title)");

              // ⭐️ 3. (선택사항) 사용자에게 스낵바 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$title 세부정보 페이지로 이동 (구현 예정)"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("세부정보"),
          ),
        ],
      ),
    );
  }

  // ⭐️ 4. "더보기" 버튼 위젯 및 로직 추가 (MemberInviteScreen 참고)
  Widget _buildGroupMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: () {
          // --- 5개 추가 로직 ---
          setState(() {
            List<Map<String, String>> newGroups = []; // 1. 5개를 담을 빈 리스트
            for (int i = 0; i < 5; i++) { // 2. 5번 반복
              newGroups.add(
                  {
                    "title": "새 소모임 $_groupCounter", // 3. 카운터로 고유 이름
                    "topic": "추가 주제"
                  }
              );
              _groupCounter++; // 4. 카운터 1 증가
            }
            _groupList.addAll(newGroups); // 5. 5개 한꺼번에 추가
          });
          // --- 로직 끝 ---
        },
        child: const Text(
          '소모임 더보기',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C6DAF), // MemberInvite와 색상 통일
          ),
        ),
      ),
    );
  }

  // 🔹 재사용 가능한 텍스트필드 위젯 (기존과 동일)
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

  // 🔹 소모임 개설/참여 버튼 (기존과 동일)
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                  isSelected ? Colors.white70 : const Color(0xFF6B7AA1),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}