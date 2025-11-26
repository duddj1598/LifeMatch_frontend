// lib/features/team_management/screens/my_group_manage_screen.dart (가정)

import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/auth/models/user_group_model.dart'; // ⭐️ UserGroup 모델 import
import 'package:lifematch_frontend/features/team_management/services/team_management_service.dart';

import '../../group/models/group_model.dart';
import '../../group/screens/group_detail_screen.dart';
import '../../group/services/group_service.dart';
import '../../team_management/screens/team_management_screen.dart';


// ------------------------------------------------------------------
// ⭐️ MyGroupManageScreen (메인 소모임 관리 화면)
// ------------------------------------------------------------------

class MyGroupManageScreen extends StatefulWidget {
  const MyGroupManageScreen({super.key});

  @override
  State<MyGroupManageScreen> createState() => _MyGroupManageScreenState();
}

class _MyGroupManageScreenState extends State<MyGroupManageScreen> with SingleTickerProviderStateMixin {
  final TeamManagementService _service = TeamManagementService();
  late TabController _tabController;
  final GroupService _groupDetailService = GroupService();

  bool _isLoading = true;
  List<UserGroup> _managedGroups = []; // 내가 리더인 소모임
  List<UserGroup> _joinedGroups = [];  // 내가 멤버인 소모임 (리더 그룹 제외)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchMyGroupLists(); // ⭐️ API 호출 시작
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ⭐️ API를 호출하여 내가 관리/참여하는 소모임 목록을 가져오는 함수
  Future<void> _fetchMyGroupLists() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, List<UserGroup>> result = await _service.getMyGroupLists();

      if (!mounted) return;
      setState(() {
        _managedGroups = result['managed'] ?? [];
        _joinedGroups = result['joined'] ?? [];
        _isLoading = false;
      });

    } catch (e) {
      print("❌ 소모임 목록 로딩 실패: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('소모임 목록을 불러오는 데 실패했습니다: ${e.toString()}')),
      );
    }
  }

  void _handleBottomTap(String tag) {
    // 하단 바 라우팅 로직
    switch (tag) {
      case 'home':
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 'chat':
        Navigator.pushReplacementNamed(context, '/chat');
        break;
      case 'connection':
      // 현재 화면
        break;
      case 'bell':
        Navigator.pushReplacementNamed(context, '/notification');
        break;
      case 'profile':
        Navigator.pushReplacementNamed(context, '/my-profile');
        break;
    }
  }

  // ⭐️ [신규] 참여 소모임 상세 화면으로 이동 (GroupDetailScreen)
  void _navigateToGroupDetail(UserGroup group) {
    print("➡️ 참여 소모임: GroupDetailScreen으로 이동 (ID: ${group.id}, ButtonType: none)");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(
          groupId: group.id,
          buttonType: GroupDetailButtonType.none, // GroupDetailButtonType 임포트 필요
        ),
      ),
    ).then((_) {
      _fetchMyGroupLists();
    });
  }

  // ⭐️ [수정] 관리 소모임 상세 화면으로 이동 (TeamManagementScreen)
  void _navigateToTeamDetail(UserGroup group) async {
    print("➡️ 관리 소모임: TeamManagementScreen으로 이동 (ID: ${group.id}, 상세 정보 로딩 시작)");

    // 로딩 상태를 표시하는 동안 사용자 입력을 막는 것이 좋습니다.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. GroupService를 사용하여 상세 GroupModel을 가져옵니다.
      final GroupModel detailModel = await _groupDetailService.getGroupDetail(group.id);

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      // 2. TeamManagementScreen으로 상세 GroupModel을 initialGroupDetail로 전달합니다.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamManagementScreen(
            groupId: group.id,
            initialGroupDetail: detailModel, // ⭐️ 상세 정보 전달
          ),
        ),
      );

      // 3. 화면에서 돌아왔을 때 목록 갱신
      _fetchMyGroupLists();

    } catch (e) {
      // 로딩 다이얼로그 닫기 (오류 발생 시)
      if(mounted) Navigator.pop(context);

      print("❌ 상세 정보 로드 실패 및 이동 불가: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상세 정보를 불러올 수 없습니다: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 소모임 관리', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6B7AA1),
          tabs: const [
            Tab(text: '관리 소모임'),
            Tab(text: '참여 소모임'),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B7AA1))) // 로딩 인디케이터
          : TabBarView(
        controller: _tabController,
        children: [
          // 1. 관리 소모임 탭
          _buildGroupList(
            groups: _managedGroups,
            emptyMessage: "관리하는 소모임이 없습니다.",
            isManagement: true,
          ),
          // 2. 참여 소모임 탭
          _buildGroupList(
            groups: _joinedGroups,
            emptyMessage: "참가중인 소모임이 없습니다.",
            isManagement: false,
          ),
        ],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'connection', // 현재 탭 강조
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // ⭐️ 그룹 목록 또는 빈 메시지를 표시하는 위젯
  Widget _buildGroupList({
    required List<UserGroup> groups,
    required String emptyMessage,
    required bool isManagement,
  }) {
    if (groups.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupTile(group, isManagement);
      },
    );
  }

  // ⭐️ 그룹 목록의 개별 항목 위젯 (onTap 로직 수정)
  Widget _buildGroupTile(UserGroup group, bool isManagement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        // ⭐️ [수정] isManagement에 따라 이동할 함수 분리
        onTap: () => isManagement
            ? _navigateToTeamDetail(group) // 관리 소모임: TeamManagementScreen
            : _navigateToGroupDetail(group), // 참여 소모임: GroupDetailScreen

        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6B7AA1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            // ⭐️ 그룹 이미지 표시 (groupImage 필드 사용)
            image: group.groupImage != null && group.groupImage!.isNotEmpty
                ? DecorationImage(
              image: NetworkImage(group.groupImage!),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: group.groupImage == null || group.groupImage!.isEmpty
              ? const Icon(Icons.group, color: Color(0xFF6B7AA1))
              : null,
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '주제: ${group.category ?? '미정'} | 인원: ${group.currentMember}/${group.maxMember}명',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: isManagement
            ? const Icon(Icons.arrow_forward_ios, size: 18) // 관리 그룹은 화살표
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('참여 중', style: TextStyle(color: Colors.lightGreen.shade700, fontSize: 12)), // 참여 그룹은 '참여 중' 태그
        ),
      ),
    );
  }
}