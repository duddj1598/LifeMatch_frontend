import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:lifematch_frontend/features/notification/services/notification_service.dart'; // ⭐️ [추가] NotificationService import
import '../../chat/services/chat_service.dart';
import '../models/group_model.dart';
import '../services/group_service.dart'; // GroupService가 getGroupDetail을 제공한다고 가정
import 'package:http/http.dart' as http;
import 'dart:convert';

// 2. ⭐️ (핵심) 버튼 타입 정의 (기존과 동일)
enum GroupDetailButtonType {
  none, //팀원이 소모임 세부사항 볼 때
  join, //오늘의 추천활동 세부사항
  joinOrInquire, //문의 or 참가신청
  acceptOrDecline, //참가신청 수락 or 거절
}

// 3. ⭐️ GroupDetailScreen (기존과 동일)
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
  final GroupService _groupService = GroupService();
  final NotificationService _notificationService = NotificationService(); // ⭐️ [추가] NotificationService 인스턴스

  bool _isLoading = true;
  bool _hasError = false;

  // ⭐️ 로딩이 완료된 후 GroupModel 객체를 가리킬 변수
  late GroupModel _groupDetail;

  String? _myUserDocId;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetailsAndUserId();
  }

  // ✅ 그룹 상세 정보와 유저 ID를 모두 로드하는 통합 함수 (기존 로직 유지)
  Future<void> _fetchGroupDetailsAndUserId() async {
    try {
      // 1. 사용자 ID 로드
      final String? userId = await _storageService.getUserId();
      if (userId == null) {
        throw Exception("로그인된 사용자 ID를 찾을 수 없습니다. 다시 로그인 해주세요.");
      }

      // 2. 그룹 상세 정보 로드 (HTTP 직접 호출)
      final url = Uri.parse("http://10.0.2.2:8000/api/group/${widget.groupId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _groupDetail = GroupModel.fromJson(data, widget.groupId);
          _myUserDocId = userId;
          _isLoading = false;
          _hasError = false;
        });
      } else {
        print("❌ 그룹 상세 정보 로드 실패: ${response.statusCode}");
        throw Exception("서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 그룹 상세 정보 로딩/유저 ID 로딩 실패: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모임 정보를 불러오는 데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleApplyJoin() async {
    if (_myUserDocId == null || widget.groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보 또는 그룹 정보가 누락되었습니다.')),
      );
      return;
    }

    try {
      // ⭐️ [참고] GroupService나 NotificationService를 통해 baseUrl을 가져오는 것이 이상적이지만,
      // 현재 구조상 http.post를 직접 사용하며 URL을 구성합니다.

      // NotificationService와 동일한 URL을 사용합니다.
      const String finalBaseUrl = NotificationService.baseUrl;

      final token = await _storageService.getToken(); // StorageService를 통해 토큰을 가져옵니다.

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 토큰이 필요합니다.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("$finalBaseUrl/api/group-action/apply"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "group_id": widget.groupId, // group_id만 전송 (user_id는 JWT에서 추출)
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 그룹 가입 신청이 완료되었습니다.')),
        );
        if (mounted) {
          Navigator.pop(context); // 신청 후 이전 화면으로 돌아갑니다.
        }
      } else {
        print("❌ 신청 실패 (${response.statusCode}): ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 신청 실패: 서버 오류 (${response.statusCode})')),
        );
      }
    } catch (e) {
      print("❌ 신청 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 신청 중 오류 발생: ${e.toString()}')),
      );
    }
  }
  // ⭐️ [신규 함수] 수락/거절 API 호출 및 후처리
  Future<void> _handleAcceptDecline(String actionType) async {
    if (widget.actionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('처리할 신청 ID가 없습니다.')),
      );
      return;
    }
    // 로딩 인디케이터 표시 (선택 사항)
    // showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));

    try {
      final bool success = await _notificationService.respondToAction(
        widget.actionId!,
        actionType, // "accept" 또는 "decline"
      );

      // Navigator.pop(context); // 로딩 인디케이터 닫기 (선택 사항)

      if (success) {
        final String message = (actionType == 'accept' ? '수락' : '거절') + ' 처리되었습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // 처리 후 이전 화면으로 돌아가기 (예: 알림 목록)
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/notification');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('처리 실패: 서버 응답 오류')),
        );
      }
    } catch (e) {
      // Navigator.pop(context); // 로딩 인디케이터 닫기 (선택 사항)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('처리 중 오류 발생: ${e.toString()}')),
      );
      print("❌ 액션 처리 오류: $e");
    }
  }

  Future<void> _handleInquireChat() async {
    final chatService = ChatService();
    print("--- 문의하기 로직 진입 ---");

    // 1. 리더 ID 확인
    if (!_groupDetail.hasLeaderLoginId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ 리더 정보를 찾을 수 없습니다.')),
      );
      return;
    }

    final String leaderLoginId = _groupDetail.leaderId!; // 리더의 로그인 user_id
    print("리더 Login ID: $leaderLoginId");
    // 2. ChatService 인스턴스 준비 (ChatPersonalDetailScreen에서 사용한 ChatService와 동일)
    // 🚨 [필수] GroupService와 별개로, ChatService가 필요합니다.
    // 현재 import에 ChatService가 없으므로, 추가한다고 가정합니다.
    // import '../services/chat_service.dart'; // ⭐️ ChatService 임포트 필요

     // ChatService 인스턴스 생성

    try {
      // 3. 채팅방 생성 API 호출
      print("API 호출 시작: /api/chat/create");
      final Map<String, dynamic> result = await chatService.createChatRoom(
        type: "dm",
        targetIds: [leaderLoginId], // 리더의 로그인 ID를 상대방으로 지정
      );

      final String chatId = result['chat_id'];
      final String roomName = _groupDetail.leaderNickname;
      final String? myUserDocId = _myUserDocId; // 내 Firestore 문서 ID (필요시)

      if (chatId.isEmpty) {
        throw Exception("채팅방 ID를 받지 못했습니다.");
      }
      print("✅ 채팅방 생성 성공. Chat ID: $chatId");
      // 4. ChatPersonalDetailScreen으로 이동
      if (mounted) {
        // ⭐️ [라우팅] 1:1 채팅 상세 화면으로 이동
        await Navigator.pushNamed(
          context,
          '/chat-personal-detail',
          arguments: {
            "chatId": chatId,
            "roomName": roomName,
            "myUserDocId": myUserDocId, // 내 문서 ID 전달 (메시지 구분을 위함)
          },
        );
        // 채팅방에서 돌아오면 화면을 갱신할 수 있음 (선택 사항)
        _fetchGroupDetailsAndUserId();
      }

    } catch (e) {
      print("❌ DM 채팅방 생성/이동 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 문의 채팅방 생성 실패: ${e.toString()}')),
      );
    }
  }
  // --- 4. ⭐️ 색상 정의 (유지) ---
  final Color _borderColor = const Color(0xFF4C6DAF);
  final Color _buttonColor70 = const Color(0xFF4C6DAF).withOpacity(0.7);

  // --- 5. ⭐️ 하단 내비게이션 탭 핸들러 (유지) ---
  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        print('🏠 홈 이동');
        Navigator.pushNamed(context, '/home');
        break;
      case 'chat':
        print('💬 채팅 탭');
        Navigator.pushNamed(context, '/chat');
        break;
      case 'connection':
        print('🔗 소모임 연결');
        Navigator.pushNamed(context, '/my-group-manage');
        break;
      case 'bell':
        print('🔔 알림 탭');
        Navigator.pushNamed(context, '/notification');
        break;
      case 'profile':
        print('👤 프로필 탭');
        Navigator.pushNamed(context, '/my-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return const Scaffold(
        body: Center(child: Text("정보를 로드할 수 없습니다.")),
      );
    }

    // ⭐️ 로드된 데이터 사용 (GroupModel)
    final groupName = _groupDetail.groupName;
    final groupCategory = _groupDetail.category ?? '미정';
    final groupDescription = _groupDetail.description ?? '설명 없음';
    final currentCapacity = _groupDetail.currentMember;
    final maxCapacity = _groupDetail.maxMember;
    final leaderNickname = _groupDetail.leaderNickname; // ⭐️ GroupModel에서 직접 접근


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("세부정보",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      bottomNavigationBar: CustomBottomNavBar(
        onTabSelected: _handleBottomTap,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // 소모임 대표 이미지 (유지)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_icon.png',
                        fit: BoxFit.contain,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ⭐️ 소모임 이름 (데이터 연결)
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 모임 정보 프레임
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ⭐️ 모임 주제 (데이터 연결)
                        _buildInfoRow('모임 주제 :', groupCategory),
                        const SizedBox(height: 15),
                        // ⭐️ 인원 수 (데이터 연결)
                        _buildInfoRow('인원 수 :', '$currentCapacity/$maxCapacity명'),
                        const SizedBox(height: 15),
                        // ⭐️ 모임 설명 (데이터 연결)
                        _buildInfoRow('모임 설명 :', groupDescription),
                        const SizedBox(height: 25),

                        // 팀장 정보 Row
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400, width: 1),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: const Icon(Icons.person, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '팀장 닉네임: $leaderNickname',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '관심사 : 유저 관심사', // (임시 데이터)
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 3. ⭐️ 하단 버튼 영역
          _buildPersistentButtons(widget.buttonType),

          // 4. ⭐️ 안전 영역 확보
          SafeArea(
            top: false,
            child: Container(),
          ),
        ],
      ),
    );
  }

  // --- 10. ⭐️ 버튼 생성 헬퍼 함수 (수락/거절 로직 추가) ---
  Widget _buildPersistentButtons(GroupDetailButtonType type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: switch (type) {
        GroupDetailButtonType.none => const SizedBox.shrink(),
        GroupDetailButtonType.join =>
            _buildOneButton(
              text: '참가신청',
              color: _buttonColor70,
              onPressed: () {
                // ⭐️ [연결] 참가 신청 로직 연결
                _handleApplyJoin();
              },
            ),
        GroupDetailButtonType.joinOrInquire =>
            _buildTwoButtons(
              text1: '문의하기',
              text2: '참가신청',
              onPressed1: () {
                // ⭐️ [연결] 문의하기 로직 연결
                _handleInquireChat();
              },
              onPressed2: () {
                // 참가 신청 로직 연결
                _handleApplyJoin();
              },
            ),
        GroupDetailButtonType.acceptOrDecline =>
            _buildTwoButtons(
              text1: '거절',
              text2: '수락',
              onPressed1: () {
                // ⭐️ [수정] 거절 로직 연결
                _handleAcceptDecline('decline');
              },
              onPressed2: () {
                // ⭐️ [수정] 수락 로직 연결
                _handleAcceptDecline('accept');
              },
            )
      },
    );
  }

  // --- 11. ⭐️ 버튼 스타일 헬퍼 (유지) ---
  Widget _buildOneButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text,
            style:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTwoButtons({
    required String text1,
    required String text2,
    required VoidCallback onPressed1,
    required VoidCallback onPressed2,
  }) {
    final Color buttonColor1 = Colors.grey; // 거절은 회색으로 변경 (선택 사항)
    final Color buttonColor2 = _buttonColor70;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed1,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor1,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(text1,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed2,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor2,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(text2,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- 12. ⭐️ 정보 행(Row) 스타일 헬퍼 (유지) ---
  Widget _buildInfoRow(String label, String value) {
    bool isMultiline = label.contains("설명");
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
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
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
              maxLines: isMultiline ? 5 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}