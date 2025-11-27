import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/group/screens/group_detail_screen.dart';
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
  bool isCreateSelected = true; // ⭐️ 기본 탭을 '소모임 참여'로 변경 (목록이 먼저 보이도록)
  final GroupService _groupService = GroupService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  List<GroupModel> _filteredGroupList = [];
  bool _isGroupListLoading = true;


  @override
  void initState() {
    super.initState();
    // ⭐️ [추가] 카테고리 기반으로 소모임 목록을 로드하는 함수 호출
    _fetchFilteredGroupList(widget.selectedCategory, _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    // 키보드 숨기기 (UX 개선)
    FocusScope.of(context).unfocus();

    // 불필요한 API 호출 방지 (검색어가 이전과 같을 경우)
    if (query == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = query; // 최종 검색어로 상태 업데이트
    });

    // API 호출
    _fetchFilteredGroupList(widget.selectedCategory, _searchQuery);
  }

  Future<void> _fetchFilteredGroupList(String category, String query) async {
    if (!mounted) return;
    // 검색어가 변경될 때 로딩 상태를 보여주기 위해 잠시 true로 설정
    setState(() {
      _isGroupListLoading = true;
    });

    try {
      // ⭐️ GroupService에 category와 query(q)를 모두 전달
      final List<GroupModel> groups = await _groupService.getGroupList(
        category: category,
        q: query, // ⭐️ 검색어 전달
      );

      if (!mounted) return;
      setState(() {
        _filteredGroupList = groups;
        _isGroupListLoading = false;
        print("✅ 카테고리 '$category'에서 검색어 '$query'로 그룹 ${_filteredGroupList.length}개 로드 완료.");
      });
    } catch (e) {
      print("❌ 그룹 목록 로딩 실패: $e");
      if (!mounted) return;
      setState(() {
        _isGroupListLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소모임 목록을 불러오는 데 실패했습니다: ${e.toString()}')),
      );
    }
  }


  // ⭐️ [Mock] Mock 데이터 필터링 로직 (GroupModel 변환 포함)
  List<GroupModel> _applyMockFilter(String category) {
    // ⭐️ 기존 Mock 데이터를 GroupModel 형태로 변환하여 사용한다고 가정합니다.
    final List<Map<String, dynamic>> rawMockData = [
      {"groupId": "join-id-a", "title": "[소모임 이름 A]", "topic": "소비 · 경제", "current": 3, "max": 10},
      {"groupId": "join-id-b", "title": "[소모임 이름 B]", "topic": "소비 · 경제", "current": 5, "max": 8},
      {"groupId": "join-id-c", "title": "[소모임 이름 C]", "topic": "생활습관 · 건강", "current": 2, "max": 5},
      {"groupId": "join-id-d", "title": "[소모임 이름 D]", "topic": "기술", "current": 8, "max": 10},
      {"groupId": "join-id-e", "title": "[소모임 이름 E]", "topic": "여가 · 문화", "current": 1, "max": 4},
      // HomeScreen에서 선택 가능한 카테고리명과 일치하는 항목 추가
      {"groupId": "join-id-f", "title": "경제 스터디", "topic": "소비 · 경제", "current": 4, "max": 7},
      {"groupId": "join-id-g", "title": "주말 등산 모임", "topic": "생활습관 · 건강", "current": 6, "max": 12},
    ];

    // ⭐️ 선택된 카테고리로 필터링
    final filteredRaw = rawMockData.where((g) => g['topic'] == category).toList();

    // ⭐️ Map을 GroupModel로 변환
    return filteredRaw.map((raw) => GroupModel(
      id: raw['groupId'],
      groupName: raw['title'],
      category: raw['topic'],
      currentMember: raw['current'],
      maxMember: raw['max'],
      leaderId: 'mock-leader',
      leaderNickname: '리더',
      description: 'Mock 그룹입니다.',
      groupImage: null,
      createdAt: '2025-01-01T00:00:00Z',
      chatId: 'mock-chat-id',
      members: List.generate(raw['current'], (index) => '멤버 ${index + 1}'),
    )).toList();
  }


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
  // ⭐️ 1. BUILD WIDGETS (수정된 위젯 코드)
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

  // --- "소모임 참여" 목록 (수정됨: 로딩 및 필터링 적용) ---
  Widget _buildJoinList(BuildContext context) {

    // ⭐️ 1. 검색창은 리스트의 유무와 관계없이 항상 상단에 위치
    return Column(
      children: [
        // ⭐️ 검색창: 항상 표시
        _buildSearchBar(),
        const SizedBox(height: 20),

        // ⭐️ 2. 로딩 상태 처리
        if (_isGroupListLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: CircularProgressIndicator(color: Color(0xFF6B7AA1)),
            ),
          )

        // ⭐️ 3. 검색 결과가 비어 있을 때 메시지 표시
        else if (_filteredGroupList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                _searchQuery.isEmpty
                    ? "'${widget.selectedCategory}' 카테고리의 소모임이 없습니다."
                    : "검색어 '$_searchQuery'에 해당하는 소모임이 없습니다.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          )

        // ⭐️ 4. 검색 결과가 있을 때 목록 표시
        else
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _filteredGroupList.length,
                itemBuilder: (context, index) {
                  final group = _filteredGroupList[index];
                  return _buildGroupListItem(context, group);
                },
              ),
              // 검색 기능이 활성화되었으므로 '더보기' 버튼은 일반적으로 목록 끝에 추가되지 않습니다.
              // 필요하다면 여기에 _buildGroupMoreButton()을 추가하세요.
            ],
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
        controller: _searchController,
        onSubmitted: (value) {
          _performSearch();
        },
        // ⭐️ [개선] 현재 카테고리를 검색 힌트로 제공
        decoration: InputDecoration(
          hintText: "${widget.selectedCategory} 내에서 검색해보세요.",
          prefixIcon: IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF6B7AA1)),
            onPressed: _performSearch, // ⭐️ 돋보기 아이콘 클릭 시 검색 실행
          ),
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


  // 🔹 소모임 목록 아이템 위젯 (GroupModel 받도록 수정)
  Widget _buildGroupListItem(BuildContext context, GroupModel group) {
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
                  group.groupName, // ⭐️ GroupModel 필드 사용
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "주제 : ${group.category ?? '미정'} | 인원: ${group.currentMember}/${group.maxMember}", // ⭐️ GroupModel 필드 사용
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 세부정보 버튼
          ElevatedButton(
            onPressed: () {
              print("페이지 이동! (세부정보: ${group.groupName}) - GroupDetailScreen으로 이동 (ID: ${group.id})");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(
                    buttonType: GroupDetailButtonType.joinOrInquire,
                    groupId: group.id, // ⭐️ GroupModel 필드 사용
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


  // 🔹 재사용 가능한 텍스트필드 위젯 (유지)
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

  // 🔹 소모임 개설/참여 버튼 (유지)
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

  // ⭐️ API 호출 및 다음 화면 이동 함수 (유지)
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
            // ⭐️ [수정] 복잡한 매개변수 다 없애고, 방금 만든 모델 하나만 전달!
            groupDetail: newGroupModel,
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
              _buildJoinList(context) // ⭐️ 필터링된 목록을 출력
          ],
        ),
      ),
      bottomNavigationBar:
      CustomBottomNavBar(onTabSelected: _handleBottomTap),
    );
  }
}