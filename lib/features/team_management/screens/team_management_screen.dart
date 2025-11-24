import 'package:flutter/material.dart';
// ⭐️ 하단 내비게이션 바 위젯 임포트
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

// (MyGroupManageScreen이 라우트로 등록되어 있으므로 별도의 import는 필요하지 않습니다.)

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  // ⭐️ [추가] 모임 이름 수정 상태
  bool _isNameEditing = false;
  // ⭐️ [기존] 모임 주제 수정 상태
  bool _isTopicEditing = false;
  // ⭐️ [기존] 모임 설명 수정 상태
  bool _isDescriptionEditing = false;

  // ⭐️ 하단바 이동 로직
  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'chat':
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 'connection':
        Navigator.pushReplacementNamed(context, '/my-group-manage'); // 연결 탭 클릭 시 내 소모임 관리 화면으로 이동
        break;
      case 'bell':
        Navigator.pushReplacementNamed(context, '/notification');
        break;
      case 'profile':
        Navigator.pushReplacementNamed(context, '/my-profile');
        break;
    }
  }

  // ⭐️ [추가] 완료 버튼 클릭 시 MyGroupManageScreen으로 이동하는 함수
  void _onCompletePressed() {
    print("✅ 소모임 설정 완료 버튼 클릭");
    // '/my-group-manage' 라우트로 현재 화면을 대체하며 이동합니다.
    Navigator.pushReplacementNamed(context, '/my-group-manage');
  }

  // 예시 데이터 - 실제로는 서버에서 데이터를 가져와야 합니다.
  String _groupName = "[소모임 이름]";
  String _groupTopic = "모임 주제 기입";
  String _groupDescription = "모임 설명 기입";
  final List<String> _members = ["닉네임", "닉네임", "닉네임", "닉네임", "닉네임"]; // 3/5 멤버를 가정

  // 텍스트 필드 컨트롤러
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupTopicController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ⭐️ 컨트롤러 초기화
    _groupNameController.text = _groupName;
    _groupTopicController.text = _groupTopic;
    _groupDescriptionController.text = _groupDescription;
  }

  @override
  void dispose() {
    // ⭐️ 컨트롤러 해제
    _groupNameController.dispose();
    _groupTopicController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // 밝은 회색 배경
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 투명 AppBar
        elevation: 0, // 그림자 없음
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            // 이전 화면으로 돌아가기 (보통 MyGroupManageScreen이 될 것입니다.)
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
            // ⭐️ 대표 이미지 영역
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
              child: Icon(
                Icons.image_outlined,
                color: Colors.grey[600],
                size: 50,
              ),
            ),
            const SizedBox(height: 16),

            // ⭐️ 소모임 이름 영역: TextField와 수정/완료 버튼 토글
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150, // TextField가 너무 커지는 것을 방지
                  child: TextField(
                    controller: _groupNameController,
                    readOnly: !_isNameEditing, // ⭐️ 수정 상태에 따라 읽기 전용 결정
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      hintText: "[소모임 이름]",
                      border: _isNameEditing ? const UnderlineInputBorder() : InputBorder.none, // 수정 중일 때만 밑줄 표시
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ⭐️ 수정/완료 버튼 (이름용)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isNameEditing) {
                        print("소모임 이름 저장: ${_groupNameController.text}");
                        // TODO: 여기에 서버 저장 로직 추가
                      }
                      _isNameEditing = !_isNameEditing; // 상태 토글
                    });
                  },
                  child: _isNameEditing
                      ? // ⭐️ 완료 버튼 (수정 중일 때)
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
                      : // ⭐️ 수정 아이콘 (읽기 전용일 때)
                  Image.asset(
                    'assets/images/edit_icon.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ⭐️ 모임 정보 카드
            _buildInfoCard(context),
            const SizedBox(height: 30),

            // ⭐️ 팀원 목록 카드
            _buildMemberListCard(),
            const SizedBox(height: 30), // 하단 여백 조정

            // ⭐️ [추가] 완료 버튼 영역
            _buildCompletionButton(),
            const SizedBox(height: 80), // 하단바와의 최종 여백
          ],
        ),
      ),
      // ⭐️ 하단 네비게이션 바
      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'connection', // 현재 화면이 'connection' 탭에 해당한다고 가정
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // -------------------------------
  // 🟣 [추가] 완료 버튼 위젯
  // -------------------------------
  Widget _buildCompletionButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _onCompletePressed, // ⭐️ '/my-group-manage' 라우트로 이동
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

  // ⭐️ 모임 정보 카드 위젯 (상태 변수 연결)
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

          // ⭐️ 모임 주제 Row 연결
          _buildInfoRow(
            context,
            label: "모임 주제 :",
            controller: _groupTopicController,
            isEditing: _isTopicEditing, // ⭐️ 상태 변수 연결
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

          // ⭐️ 모임 설명 Row 연결
          _buildInfoRow(
            context,
            label: "모임 설명 :",
            controller: _groupDescriptionController,
            isEditing: _isDescriptionEditing, // ⭐️ 상태 변수 연결
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

  // ⭐️ 정보 카드 내 개별 Row 위젯 (수정/완료 버튼 로직)
  Widget _buildInfoRow(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required bool isEditing, // 현재 수정 상태
        required VoidCallback onToggleEdit, // 수정/완료 상태를 토글하는 함수
        VoidCallback? onSave, // 완료 버튼 클릭 시 저장 로직
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
            // ⭐️ 수정 중일 때 배경 및 테두리 스타일 변경
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
                  // ⭐️ 수정 상태에 따라 읽기 전용 결정
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
              // ⭐️ 수정/완료 버튼 영역
              GestureDetector(
                onTap: () {
                  if (isEditing) {
                    onSave?.call(); // 저장 로직 실행
                  }
                  onToggleEdit(); // 상태 토글 (수정 -> 읽기 | 읽기 -> 수정)
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: isEditing
                      ? // ⭐️ 완료 버튼 (수정 중일 때)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7AA1), // 파란 계열 배경색
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
                      : // ⭐️ 수정 아이콘 (읽기 전용일 때)
                  Image.asset(
                    'assets/images/edit_icon.png', // ⭐️ 이미지 경로
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

  // ⭐️ 팀원 목록 카드 위젯
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
              Text(
                "팀원 목록",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "3/${_members.length}", // 현재 3명 / 전체 5명으로 가정 (예시)
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

          // ⭐️ 팀원 초대 항목
          _buildMemberRow(
            context,
            memberName: "팀원 초대",
            icon: Icons.person_add_alt_1_outlined,
            isInvite: true,
            onTap: () {
              print("팀원 초대 클릭");
              // 팀원 초대 로직 또는 화면 이동
              Navigator.pushNamed(context, '/invite');
            },
          ),

          // ⭐️ 실제 팀원 목록
          ..._members.map((member) => _buildMemberRow(context, memberName: member)).toList(),
        ],
      ),
    );
  }

  // ⭐️ 팀원 목록의 개별 Row 위젯 (수직 패딩 조정)
  Widget _buildMemberRow(
      BuildContext context, {
        required String memberName,
        IconData? icon,
        bool isInvite = false,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ⭐️ 수직 패딩을 4.0으로 줄여 간격 조정
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // 프로필 사진/아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
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
            // 닉네임/팀원 초대 텍스트
            Text(
              memberName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isInvite ? FontWeight.bold : FontWeight.normal,
                color: isInvite ? Colors.blue[700] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}