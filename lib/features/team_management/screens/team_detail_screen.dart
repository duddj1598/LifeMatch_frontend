import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/group/screens/group_detail_screen.dart';
import 'package:lifematch_frontend/features/team_management/screens/team_management_screen.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/group/services/group_service.dart';
import 'package:lifematch_frontend/features/group/models/group_model.dart';
import 'memberInvite_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final String selectedCategory;

  const TeamDetailScreen({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}


class _TeamDetailScreenState extends State<TeamDetailScreen> {
  bool isCreateSelected = true;
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

  // ⭐️ 그룹 목록 Mock 데이터
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

  // =================================================================
  // ⭐️ 1. BUILD WIDGETS (생략된 위젯 코드)
  // =================================================================

  // --- "소모임 개설" 폼 ---
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
              // 대표 사진 설정
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

              // 입력 필드들
              _buildTextField("소모임 이름", "2~10자 내외로 설정 해 주세요", controller: _nameController),
              _buildTextField("소모임 설명", "30자 이내로 작성 해 주세요", controller: _descController),
              _buildTextField("소모임 모임 장소", "30자 이내로 작성 해 주세요", controller: _locationController),
              _buildTextField("소모임 인원 수", "2~10자 내외로 설정 해 주세요", controller: _capacityController, isNumber: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // 다음 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await _createGroupAndNavigate(context);
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

  // --- "소모임 참여" 목록 ---
  Widget _buildJoinList(BuildContext context) {
    return Column(
      children: [
        // 검색창
        _buildSearchBar(),
        const SizedBox(height: 20),

        // 소모임 목록
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: _groupList.length + 1,
          itemBuilder: (context, index) {
            if (index == _groupList.length) {
              return _buildGroupMoreButton();
            } else {
              final group = _groupList[index];
              return _buildGroupListItem(
                context,
                group['title']!,
                group['topic']!,
                group['groupId']!,
              );
            }
          },
        ),
      ],
    );
  }

  // 🔹 검색창 위젯
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


// 🔹 소모임 목록 아이템 위젯
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
          // 대표 사진
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

          // 소모임 정보
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

          // 세부정보 버튼
          ElevatedButton(
            onPressed: () {
              print("페이지 이동! (세부정보: $title) - GroupDetailScreen으로 이동 (ID: $groupId)");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(
                    buttonType: GroupDetailButtonType.joinOrInquire,
                    groupId: groupId,
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

  // ⭐️ "더보기" 버튼 위젯 및 로직
  Widget _buildGroupMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: () {
          // 5개 추가 로직
          setState(() {
            List<Map<String, String>> newGroups = [];
            for (int i = 0; i < 5; i++) {
              newGroups.add(
                  {
                    "groupId": "new-join-id-$_groupCounter",
                    "title": "새 소모임 $_groupCounter",
                    "topic": "추가 주제"
                  }
              );
              _groupCounter++;
            }
            _groupList.addAll(newGroups);
          });
        },
        child: const Text(
          '소모임 더보기',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C6DAF),
          ),
        ),
      ),
    );
  }

  // 🔹 재사용 가능한 텍스트필드 위젯
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
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  // ⭐️ API 호출 및 다음 화면 이동 함수
  Future<void> _createGroupAndNavigate(BuildContext context) async {
    final name = _nameController.text;
    final desc = _descController.text;
    final location = _locationController.text;
    final capacity = int.tryParse(_capacityController.text) ?? 0;
    final category = widget.selectedCategory;

    if (name.isEmpty || desc.isEmpty || location.isEmpty || capacity < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 올바르게 입력해주세요 (인원수 최소 2명).')),
      );
      return;
    }

    try {
      final GroupModel newGroupModel = await _groupService.createGroup(
        groupName: name,
        description: desc,
        category: category,
        capacity: capacity,
        location: location,
      );

      print('✅ 소모임 생성 성공! Group ID: ${newGroupModel.id}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberInviteScreen(
            groupId: newGroupModel.id,
            initialGroupDetail: newGroupModel,
            selectedCategory: widget.selectedCategory,
          ),
        ),
      );

    } catch (e) {
      print('❌ 소모임 생성 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소모임 생성 실패: ${e.toString()}')),
      );
    }
  }

  // =================================================================
  // ⭐️ 2. BUILD METHOD (최종 반환 위젯)
  // =================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              _buildCreateForm(context)
            else
              _buildJoinList(context)

          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(onTabSelected: _handleBottomTap),
    );
  }
}