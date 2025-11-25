import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/group/screens/group_detail_screen.dart';
import 'package:lifematch_frontend/features/team_management/screens/team_management_screen.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/group/services/group_service.dart';
import 'memberInvite_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  // ⭐️ 1. 홈 화면에서 카테고리 이름을 받을 변수 추가
  final String selectedCategory;

  // ⭐️ 2. 생성자 수정: 'selectedCategory'를 받도록 변경
  const TeamDetailScreen({
    super.key,
    required this.selectedCategory, // ⭐️ required 추가
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}


class _TeamDetailScreenState extends State<TeamDetailScreen> {
  bool isCreateSelected = true;
  // GroupService는 GroupDetail을 반환하도록 수정되어야 합니다.
  final GroupService _groupService = GroupService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  // ⭐️ [수정] _groupList에 groupId 필드 추가
  final List<Map<String, String>> _groupList = [
    {"groupId": "join-id-a", "title": "[소모임 이름 A]", "topic": "투자ㆍ소비습관"},
    {"groupId": "join-id-b", "title": "[소모임 이름 B]", "topic": "투자ㆍ소비습관"},
    {"groupId": "join-id-c", "title": "[소모임 이름 C]", "topic": "투자ㆍ소비습관"},
    {"groupId": "join-id-d", "title": "[소모임 이름 D]", "topic": "투자ㆍ소비습관"},
    {"groupId": "join-id-e", "title": "[소모임 이름 E]", "topic": "투자ㆍ소비습관"},
    {"groupId": "join-id-f", "title": "[소모임 이름 F]", "topic": "운동ㆍ헬스"},
    {"groupId": "join-id-g", "title": "[소모임 이름 G]", "topic": "맛집 탐방"},
    {"groupId": "join-id-h", "title": "[소모임 이름 H]", "topic": "반려동물"},
    {"groupId": "join-id-i", "title": "[소모임 이름 I]", "topic": "코딩 스터디"},
  ];



  // ⭐️ 1. "더보기"를 위한 카운터 변수 추가
  int _groupCounter = 1;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        // ... (기존 AppBar)
        title: const Text(
          "",
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
            Text(
              widget.selectedCategory,
              style: const TextStyle(
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
              _buildCreateForm(context) // ⭐️ context 전달
            else
              _buildJoinList(context) // ⭐️ context 전달

          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(onTabSelected: _handleBottomTap),
    );
  }

  // --- "소모임 개설" 폼 (수정) ---
  // ⭐️ context 인자 추가
  Widget _buildCreateForm(BuildContext context) {
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
              _buildTextField("소모임 이름", "2~10자 내외로 설정 해 주세요", controller: _nameController),
              _buildTextField("소모임 설명", "30자 이내로 작성 해 주세요", controller: _descController),
              _buildTextField("소모임 모임 장소", "30자 이내로 작성 해 주세요", controller: _locationController),
              _buildTextField("소모임 인원 수", "2~10자 내외로 설정 해 주세요", controller: _capacityController), // 인원수는 숫자만 받도록 가정
            ],
          ),
        ),
        const SizedBox(height: 24),
        // ... (다음 버튼) ...
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            // ⭐️ 4. API 호출 및 다음 화면 이동 로직
            onPressed: () async {
              await _createGroupAndNavigate(context); // ⭐️ 새 함수 호출
            },
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

  // --- "소모임 참여" 목록 (수정) ---
  // ⭐️ context 인자 추가
  Widget _buildJoinList(BuildContext context) {
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
                context, // ⭐️ context 전달
                group['title']!,
                group['topic']!,
                group['groupId']!, // ⭐️ groupId 전달
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


// 🔹 소모임 목록 아이템 위젯 (수정)
  // ⭐️ context 인자 및 groupId 인자 추가
  Widget _buildGroupListItem(BuildContext context, String title, String topic, String groupId) {
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
            onPressed: () {
              // ⭐️ GroupDetailScreen으로 이동 시 groupId 전달
              print("페이지 이동! (세부정보: $title) - GroupDetailScreen으로 이동 (ID: $groupId)");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(
                    buttonType: GroupDetailButtonType.joinOrInquire,
                    groupId: groupId, // ⭐️ groupId 전달
                  ),
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

  // ⭐️ 4. "더보기" 버튼 위젯 및 로직 추가 (groupId 추가 반영)
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
                    "groupId": "new-join-id-$_groupCounter", // ⭐️ groupId 필드 추가
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
  Widget _buildTextField(String label, String hint, {TextEditingController? controller, bool isNumber = false}) {
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
            controller: controller, // ⭐️ 컨트롤러 연결
            keyboardType: isNumber ? TextInputType.number : TextInputType.text, // ⭐️ 숫자 입력 타입 설정
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

  // ⭐️⭐️⭐️ [핵심 수정] _createGroupAndNavigate 함수
  Future<void> _createGroupAndNavigate(BuildContext context) async {
    // 5-1. 입력값 검증 (간소화)
    final name = _nameController.text;
    final desc = _descController.text;
    final location = _locationController.text;
    final capacity = int.tryParse(_capacityController.text) ?? 0;
    final category = widget.selectedCategory; // 홈 화면에서 받은 카테고리 사용

    if (name.isEmpty || desc.isEmpty || location.isEmpty || capacity < 2) {
      // 에러 처리: snackbar 등을 띄워야 함
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 올바르게 입력해주세요.')),
      );
      return;
    }

    try {
      // 로딩 인디케이터 표시 (옵션)
      // showLoading(context);

      // ⭐️ 1. await 호출을 완료하고, GroupDetail 객체를 받습니다.
      final GroupDetail newGroupDetail = await _groupService.createGroup(
        groupName: name,
        description: desc,
        category: category,
        capacity: capacity,
        location: location,
      );

      // ⭐️ 2. API 호출 성공 후의 순차적 코드를 아래에 배치합니다. (이전 오류 해결)
      print('✅ 소모임 생성 성공! Group ID: ${newGroupDetail.groupId}');

      // MemberInviteScreen으로 이동 (시나리오 4번)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberInviteScreen(
            groupId: newGroupDetail.groupId,
            // ⭐️ 초기 데이터를 MemberInviteScreen으로 전달
            initialGroupDetail: newGroupDetail,
          ),
        ),
      );

    } catch (e) {
      // 5-4. API 호출 실패
      print('❌ 소모임 생성 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소모임 생성 실패: ${e.toString()}')),
      );
    } finally {
      // 로딩 인디케이터 숨김 (옵션)
      // hideLoading(context);
    }
  }
}