import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient;

import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:lifematch_frontend/features/notification/services/notification_service.dart';
import '../../chat/services/chat_service.dart';
import '../models/group_model.dart';
import '../services/group_service.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

// 버튼 타입 정의
enum GroupDetailButtonType {
  none,
  join,
  joinOrInquire,
  acceptOrDecline,
}

class GroupDetailScreen extends StatefulWidget {
  final GroupDetailButtonType buttonType;
  final String groupId;
  final String? actionId;

  const GroupDetailScreen({
    super.key,
    required this.buttonType,
    required this.groupId,
    this.actionId,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final StorageService _storageService = StorageService();

  final NotificationService _notificationService = NotificationService();
  final ChatService _chatService = ChatService();

  bool _isLoading = true;
  bool _hasError = false;

  late GroupModel _groupDetail;
  String? _myUserDocId;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetailsAndUserId();
  }

  // 📌 그룹 정보 + 유저 ID
  Future<void> _fetchGroupDetailsAndUserId() async {
    try {
      final String? userId = await _storageService.getUserId();
      if (userId == null) throw Exception("로그인 유저 ID 없음");

      // 📌 Dio로 그룹 상세 정보 가져오기
      final response = await ApiClient.dio.get("/api/group/${widget.groupId}");

      setState(() {
        _groupDetail = GroupModel.fromJson(response.data, widget.groupId);
        _myUserDocId = userId;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ 그룹 상세 정보 로딩 실패: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // 📌 참가 신청
  Future<void> _handleApplyJoin() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('토큰이 없습니다. 다시 로그인해주세요.')),
        );
        return;
      }

      final response = await ApiClient.dio.post(
        '/api/group-action/apply',
        data: {
          "group_id": widget.groupId,
        },
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('참가 신청 완료되었습니다.')));
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ 참가 신청 에러 : $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("오류: ${e.toString()}")));
    }
  }

  // 📌 수락 / 거절
  Future<void> _handleAcceptDecline(String action) async {
    if (widget.actionId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('신청 ID가 없습니다.')));
      return;
    }

    final success =
    await _notificationService.respondToAction(widget.actionId!, action);

    if (success) {
      final msg = action == "accept" ? "수락되었습니다." : "거절되었습니다.";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.pushReplacementNamed(context, '/notification');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('요청 처리 중 오류가 발생했습니다.')));
    }
  }

  // 📌 리더에게 문의하기 → DM 생성
  Future<void> _handleInquireChat() async {
    if (!_groupDetail.hasLeaderLoginId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('리더 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    final leaderLoginId = _groupDetail.leaderId!;

    try {
      final result = await _chatService.createChatRoom(
        type: "dm",
        groupId: null,
        targetIds: [leaderLoginId],
      );

      final chatId = result["chat_id"];

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/chat-personal-detail',
          arguments: {
            "chatId": chatId,
            "roomName": _groupDetail.leaderNickname,
            "myUserDocId": _myUserDocId,
          },
        );
      }
    } catch (e) {
      print("❌ 문의하기 실패: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("문의 채팅 생성 오류: $e")));
    }
  }

  // ⭐ UI 시작 ⭐

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_hasError) return const Scaffold(body: Center(child: Text("정보를 불러올 수 없습니다.")));

    final groupName = _groupDetail.groupName;
    final groupCategory = _groupDetail.category ?? '미정';
    final groupDescription = _groupDetail.description ?? '설명 없음';

    final current = _groupDetail.currentMember;
    final max = _groupDetail.maxMember;
    final leaderNickname = _groupDetail.leaderNickname;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("세부정보",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        onTabSelected: _handleBottomTap,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: 100,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 정보 컨테이너
                  _infoContainer(
                    category: groupCategory,
                    current: current,
                    max: max,
                    description: groupDescription,
                    leaderNickname: leaderNickname,
                  ),
                ],
              ),
            ),
          ),

          _buildPersistentButtons(widget.buttonType),
          const SafeArea(child: SizedBox.shrink()),
        ],
      ),
    );
  }

  // 🔘 버튼 영역
  Widget _buildPersistentButtons(GroupDetailButtonType type) {
    switch (type) {
      case GroupDetailButtonType.none:
        return const SizedBox.shrink();
      case GroupDetailButtonType.join:
        return _buildOneButton("참가신청", _handleApplyJoin);
      case GroupDetailButtonType.joinOrInquire:
        return _buildTwoButtons("문의하기", "참가신청",
            _handleInquireChat, _handleApplyJoin);
      case GroupDetailButtonType.acceptOrDecline:
        return _buildTwoButtons("거절", "수락",
                () => _handleAcceptDecline("decline"),
                () => _handleAcceptDecline("accept"));
    }
  }

  // 버튼 스타일
  Widget _buildOneButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.7),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoButtons(String t1, String t2,
      VoidCallback f1, VoidCallback f2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: f1,
              child: Text(t1,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.7),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: f2,
              child: Text(t2,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // 정보 출력
  Widget _infoContainer({
    required String category,
    required int current,
    required int max,
    required String description,
    required String leaderNickname,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4C6DAF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("모임 주제 :", category),
          const SizedBox(height: 15),
          _buildInfoRow("인원 수 :", "$current / $max 명"),
          const SizedBox(height: 15),
          _buildInfoRow("모임 설명 :", description),
          const SizedBox(height: 20),
          Text("팀장 닉네임 : $leaderNickname",
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    bool multi = label.contains("설명");
    return Row(
      crossAxisAlignment:
      multi ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              maxLines: multi ? 5 : 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        Navigator.pushNamed(context, '/home');
        break;
      case 'chat':
        Navigator.pushNamed(context, '/chat');
        break;
      case 'connection':
        Navigator.pushNamed(context, '/my-group-manage');
        break;
      case 'bell':
        Navigator.pushNamed(context, '/notification');
        break;
      case 'profile':
        Navigator.pushNamed(context, '/my-profile');
        break;
    }
  }
}
