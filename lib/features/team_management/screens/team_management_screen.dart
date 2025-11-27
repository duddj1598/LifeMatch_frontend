import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/group/models/group_model.dart';

// ------------------------------------------------------------------
// ⭐️ [유지] Mock Group Service (GroupModel 필드명 반영)
// ------------------------------------------------------------------
class MockGroupService {
  // ⭐️ [수정] 반환 타입을 GroupModel로 변경
  Future<GroupModel> getGroupDetail(String groupId) async {
    print("API CALL: Group ID $groupId의 상세 정보 요청 (Mock)");
    await Future.delayed(const Duration(milliseconds: 700)); // 로딩 지연

    if (groupId.isEmpty) {
      throw Exception("groupId가 유효하지 않습니다. 상세 정보를 불러올 수 없습니다.");
    }

    // groupId에 따라 다른 데이터를 반환한다고 가정
    if (groupId.startsWith('invite-')) {
      // ⭐️ GroupModel 생성자를 사용하여 반환
      return GroupModel(
        id: groupId, // Firestore 문서 ID
        groupName: "초대받은 맛집탐방 모임",
        category: "맛집 탐방",
        description: "서울의 숨겨진 맛집을 같이 탐방하며 정보를 공유해요!",
        currentMember: 3, // GroupModel 필드 사용
        maxMember: 5, // GroupModel 필드 사용
        members: ["맛잘알(리더)", "미식가", "배고픈자"],

        // GroupModel의 추가 필수 필드 (Mock 값 채워 넣기)
        leaderId: "leader-1",
        leaderNickname: "맛잘알",
        groupImage: null,
        createdAt: "2025-01-01T10:00:00Z",
        chatId: "chat-123",
      );
    }

    // 요청된 그룹 ID에 대한 Mock 데이터가 없는 경우 예외 발생
    throw Exception("그룹 ID [$groupId]에 대한 상세 Mock 데이터가 없습니다.");
  }
}
// ------------------------------------------------------------------
// ⭐️ [수정] TeamManagementScreen 위젯
// ------------------------------------------------------------------
class TeamManagementScreen extends StatefulWidget {
  final String groupId;
  final GroupModel? initialGroupDetail;

  const TeamManagementScreen({
    super.key,
    required this.groupId,
    this.initialGroupDetail,
  });

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final MockGroupService _groupService = MockGroupService();
  bool _isLoading = true;
  GroupModel? _groupDetail;

  bool _isNameEditing = false;
  bool _isTopicEditing = false;
  bool _isDescriptionEditing = false;

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupTopicController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  String _groupName = "로딩 중...";
  String _groupTopic = "로딩 중...";
  String _groupDescription = "로딩 중...";
  final List<String> _members = [];


  @override
  void initState() {
    super.initState();
    _fetchGroupDetail();
  }

  // ⭐️ 모임 상세 정보를 서버에서 가져오는 함수 (initialGroupDetail 우선 사용)
  Future<void> _fetchGroupDetail() async {
    // groupId가 없는 경우 즉시 오류 처리
    if (widget.groupId.isEmpty) {
      print("❌ 치명적 오류: groupId가 전달되지 않았습니다.");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오류: 모임 ID가 누락되었습니다.')),
        );
      }
      return;
    }
    try {
      GroupModel model;

      if (widget.initialGroupDetail != null) {
        model = widget.initialGroupDetail!;
        print("✅ TeamManagementScreen: 전달받은 초기 데이터로 구성함.");
      } else {
        // Mock API를 호출하는 경우
        model = await _groupService.getGroupDetail(widget.groupId);
      }

      if (!mounted) return;
      setState(() {
        _groupDetail = model;

        _groupName = model.groupName;

        // GroupModel의 category (NonNull 가정)
        _groupTopic = model.category ?? "주제 미정";

        // GroupModel의 description (NonNull 가정)
        _groupDescription = model.description ?? "";

        _members.clear();
        _members.addAll(model.members);

        _groupNameController.text = _groupName;
        _groupTopicController.text = _groupTopic.isNotEmpty ? _groupTopic : "주제 미정";
        _groupDescriptionController.text = _groupDescription;

        _isLoading = false; // 로딩 완료
      });
    } catch (e) {
      print("❌ 그룹 상세 정보 로딩 실패: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _groupDetail = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모임 정보를 불러오는 데 실패했습니다: ${e.toString()}')),
      );
    }
  }


  @override
  void dispose() {
    _groupNameController.dispose();
    _groupTopicController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

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

  void _onCompletePressed() {
    print("✅ 소모임 설정 완료 버튼 클릭, MyGroupManageScreen으로 이동");
    Navigator.of(context).popUntil(ModalRoute.withName('/my-group-manage'));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6B7AA1)),
        ),
      );
    }

    if (_groupDetail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("모임 정보를 불러올 수 없습니다.")),
        bottomNavigationBar: CustomBottomNavBar(onTabSelected: (String tag) {  },),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
                // ⭐️ GroupModel의 groupImage 필드 사용
                image: _groupDetail!.groupImage != null
                    ? DecorationImage(
                    image: NetworkImage(_groupDetail!.groupImage!),
                    fit: BoxFit.cover)
                    : null,
              ),
              child: _groupDetail!.groupImage == null
                  ? Icon(
                Icons.image_outlined,
                color: Colors.grey[600],
                size: 50,
              )
                  : null,
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _groupNameController,
                    readOnly: !_isNameEditing,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      hintText: "[소모임 이름]",
                      border: _isNameEditing ? const UnderlineInputBorder() : InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isNameEditing) {
                        print("소모임 이름 저장: ${_groupNameController.text}");
                        // TODO: 여기에 서버 저장 로직 추가
                      }
                      _isNameEditing = !_isNameEditing;
                    });
                  },
                  child: _isNameEditing
                      ?
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7AA1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      :
                  Image.asset(
                    // 'assets/images/edit_icon.png', // 이미지 경로가 로컬에 없으므로 주석 처리
                    'assets/images/edit_icon.png', // 이미지 경로 가정
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildInfoCard(context),
            const SizedBox(height: 30),

            _buildMemberListCard(),
            const SizedBox(height: 30),

            _buildCompletionButton(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'connection',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // -------------------------------
  // 🟣 완료 버튼 위젯
  // -------------------------------
  Widget _buildCompletionButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _onCompletePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B7AA1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          '완료',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ⭐️ 모임 정보 카드 위젯
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "모임 정보",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          _buildInfoRow(
            context,
            label: "모임 주제 :",
            controller: _groupTopicController,
            isEditing: _isTopicEditing,
            onToggleEdit: () {
              setState(() {
                _isTopicEditing = !_isTopicEditing;
              });
            },
            onSave: () {
              print("모임 주제 저장: ${_groupTopicController.text}");
              // TODO: 여기에 서버 저장 로직 추가
            },
          ),
          const SizedBox(height: 16),

          _buildInfoRow(
            context,
            label: "모임 설명 :",
            controller: _groupDescriptionController,
            isEditing: _isDescriptionEditing,
            maxLines: 3,
            onToggleEdit: () {
              setState(() {
                _isDescriptionEditing = !_isDescriptionEditing;
              });
            },
            onSave: () {
              print("모임 설명 저장: ${_groupDescriptionController.text}");
              // TODO: 여기에 서버 저장 로직 추가
            },
          ),
        ],
      ),
    );
  }

  // ⭐️ 정보 카드 내 개별 Row 위젯
  Widget _buildInfoRow(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required bool isEditing,
        required VoidCallback onToggleEdit,
        VoidCallback? onSave,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isEditing ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isEditing ? const Color(0xFF6B7AA1) : Colors.grey.shade300,
              width: isEditing ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  readOnly: !isEditing,
                  decoration: InputDecoration(
                    hintText: "내용을 기입해주세요",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: (maxLines > 1 ? 10 : 8)),
                  ),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (isEditing) {
                    onSave?.call();
                  }
                  onToggleEdit();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: isEditing
                      ?
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7AA1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "완료",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                      :
                  Image.asset(
                    // 'assets/images/edit_icon.png', // 이미지 경로 가정
                    'assets/images/edit_icon.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ⭐️ 팀원 목록 카드 위젯 (GroupModel 필드명 반영)
  Widget _buildMemberListCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "팀원 목록",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                // ⭐️ GroupModel의 필드명 currentMember, maxMember 사용
                "${_groupDetail!.currentMember}/${_groupDetail!.maxMember}",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),


          const SizedBox(height: 10),
          Divider(color: Colors.grey[300], thickness: 1),
          const SizedBox(height: 10),

          _buildMemberRow(
            context,
            memberName: "팀원 초대",
            icon: Icons.person_add_alt_1_outlined,
            isInvite: true,
            onTap: () {
              print("팀원 초대 클릭 - /invite로 이동 (Group ID: ${widget.groupId})");
              Navigator.pushNamed(context, '/invite', arguments: widget.groupId);
            },
          ),

          // ⭐️ GroupModel의 members 리스트 사용
          ..._groupDetail!.members.map((member) => _buildMemberRow(context, memberName: member)).toList(),
        ],
      ),
    );
  }

  // ⭐️ 팀원 목록의 개별 Row 위젯 (리더 표시 로직 추가)
  Widget _buildMemberRow(
      BuildContext context, {
        required String memberName,
        IconData? icon,
        bool isInvite = false,
        VoidCallback? onTap,
      }) {
    // ⭐️ 리더 닉네임 확인
    final isLeader = memberName == _groupDetail!.leaderNickname;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isInvite ? const Color(0xFF6B7AA1).withOpacity(0.1) : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: icon != null
                  ? Icon(icon, color: Colors.grey[600], size: 24)
                  : Center(
                child: Text(
                  "프로필\n사진",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                memberName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isInvite || isLeader ? FontWeight.bold : FontWeight.normal,
                  color: isInvite ? const Color(0xFF6B7AA1) : Colors.black87,
                ),
              ),
            ),
            // ⭐️ 리더 태그
            if (isLeader)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7AA1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "리더",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}