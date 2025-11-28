// lib/features/team_management/screens/member_invite_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart'; // ⭐️ Dio import
import 'package:lifematch_frontend/core/services/api_client.dart' as ApiClient; // ⭐️ ApiClient import

import 'package:lifematch_frontend/features/team_management/screens/team_management_screen.dart';
import 'package:lifematch_frontend/features/group/models/group_model.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';
import 'package:lifematch_frontend/features/lifestyle_test/screens/lifestyle_loading_screen.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';

import '../../chat/services/chat_service.dart';

class TeamMember {
  final String userId;
  final String nickname;
  final String lifestyle; // 라이프 스타일 필드
  bool isInvited;

  TeamMember({
    required this.userId,
    required this.nickname,
    required this.lifestyle,
    this.isInvited = false,
  });
}

class MemberInviteScreen extends StatefulWidget {
  final GroupModel groupDetail;

  const MemberInviteScreen({
    super.key,
    required this.groupDetail,
  });

  @override
  State<MemberInviteScreen> createState() => _MemberInviteScreenState();
}

class _MemberInviteScreenState extends State<MemberInviteScreen> {
  // ⭐️ Dio 인스턴스 사용
  final Dio dio = ApiClient.dio;
  final ChatService _chatService = ChatService();

  final List<TeamMember> _suggestedMembers = [];
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();

  String _currentQuery = "";
  bool _isLoading = false;
  bool _initialSearchCompleted = false;

  // ⭐️ 검색된 전체 패널 수를 저장할 변수 추가
  int _totalSuggestedMembers = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String shorten(String text, {int maxLength = 8}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + "...";
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query == _currentQuery) {
      return;
    }

    setState(() {
      _currentQuery = query;
    });

    _searchPanelMembers(query);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // 로드된 후 한 번만 _performSearch()를 호출
  //
  //   // 1. 검색 컨트롤러에 그룹 카테고리를 초기 검색어로 설정
  //   _searchController.text = widget.groupDetail.category ?? '';
  //
  //   // 2. 초기 검색 시작 플래그 설정
  //   _initialSearchCompleted = false;
  //
  //   // 3. 프레임이 그려진 후 검색을 실행
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _performSearch();
  //   });
  //
  // }

  // --------------------------------------------------
// 🔥 1:1 채팅방 ID 조회/생성 및 화면 이동
// --------------------------------------------------
  Future<void> _openChatWithMember(TeamMember targetMember) async {
    final myUserId = await _storageService.getUserId();

    if (myUserId == null || myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 정보가 필요합니다. 다시 로그인해주세요.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${targetMember.nickname}님과의 채팅방을 여는 중...")),
    );

    try {
      // ⭐️ [수정] ChatService의 createChatRoom 함수 사용
      final responseData = await _chatService.createChatRoom(
        type: "dm",
        groupId: null, // DM이므로 null
        // ⭐️ 참가자 목록: 나의 ID와 상대방 ID
        targetIds: [targetMember.userId],
      );

      final String chatId = responseData['chat_id'];

      // 4. 성공 시 ChatPersonalDetailScreen으로 이동
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Navigator.pushNamed(
        context,
        '/chat-personal-detail',
        arguments: {
          "chatId": chatId,
          "roomName": targetMember.nickname,
          "myUserDocId": myUserId,
        },
      );

    } catch (e) {
      // ⭐️ ChatService에서 던진 상세 오류 메시지를 사용
      final errorMessage = e.toString().replaceFirst("Exception: ", "");
      print("❌ 1:1 채팅방 오류: $errorMessage");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("채팅방 연결 실패: $errorMessage")),
      );
    }
  }

  // 🔥 패널 검색 API 연동 (새 응답 구조 반영)
  Future<void> _searchPanelMembers(String query) async {
    if (!mounted) return;

    if (query.isEmpty) {
      setState(() {
        _suggestedMembers.clear();
        _totalSuggestedMembers = 0; // 초기화
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _totalSuggestedMembers = 0; // 로딩 시 초기화
    });

    final String path = "/api/panel/search";

    try {
      final response = await dio.post(
        path,
        data: {
          "query": query,
          "category": widget.groupDetail.category ?? "",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = response.data;

        // ⭐️ 1. 최상위 user 객체 정보 추출
        final Map<String, dynamic>? user = res["user"];
        final String mainUserId = user?["id"] ?? "NoID";
        final String mainUserLifestyle = user?["lifestyle"] ?? "정보 없음";

        // ⭐️ 2. panel 리스트 및 length 추출
        final List<dynamic> panelIds = res["panel"] ?? [];
        final int length = res["length"] ?? 0;

        // ⭐️ 3. TeamMember 리스트 생성
        final List<TeamMember> newSuggestedMembers = [];

        // ⭐️ 3-1. user 객체의 ID를 첫 번째 항목으로 추가 (우선 표시)
        if (user != null) {
          newSuggestedMembers.add(
            TeamMember(
              userId: mainUserId,
              nickname: shorten(mainUserId),
              lifestyle: mainUserLifestyle,
            ),
          );
        }

        // ⭐️ 3-2. 나머지 panel ID를 추가
        for (var panelId in panelIds) {
          if (panelId is String && panelId != mainUserId) { // 중복 방지
            newSuggestedMembers.add(
              TeamMember(
                userId: panelId,
                nickname: shorten(panelId),
                // panel ID만 있으므로 라이프스타일은 "정보 없음"으로 표시
                lifestyle: "라이프스타일 정보 없음",
              ),
            );
          }
        }

        if (!mounted) return;
        setState(() {
          _suggestedMembers.clear();
          _suggestedMembers.addAll(newSuggestedMembers);
          _totalSuggestedMembers = length; // 전체 length 값 저장
        });
      } else {
        print("❌ API 오류: ${response.statusCode}");
        if (!mounted) return;
        setState(() {
          _suggestedMembers.clear();
          _totalSuggestedMembers = 0;
        });
      }
    } on DioException catch (e) {
      print("❌ Dio 오류: ${e.response?.data}");
      if (!mounted) return;
      setState(() {
        _suggestedMembers.clear();
        _totalSuggestedMembers = 0;
      });
    } catch (e) {
      print("❌ 네트워크/파싱 오류: $e");
      if (!mounted) return;
      setState(() {
        _suggestedMembers.clear();
        _totalSuggestedMembers = 0;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (!_initialSearchCompleted) {
            _searchController.clear(); // 검색창 비우기
            _initialSearchCompleted = true; // 플래그를 true로 설정하여 다음 검색부터는 비우지 않도록 함
          }
        });
      }
    }
  }

  // 🔥 초대 API 호출 함수 (변경 없음)
  Future<bool> _sendInvite(String targetUserId) async {
    const String path = "/api/group-action/invite";
    final String? accessToken = await _storageService.getToken();

    if (accessToken == null || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("초대를 위해 먼저 로그인해야 합니다.")),
      );
      return false;
    }

    try {
      final response = await dio.post(
        path,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
        ),
        data: {
          "group_id": widget.groupDetail.id,
          "user_id": targetUserId
        },
      );

      if (response.statusCode == 200) {
        final res = response.data;
        print("✅ 초대 성공: ${res['message']}");
        return true;
      } else {
        throw Exception("초대 요청 처리 실패: Status ${response.statusCode}");
      }
    } on DioException catch (e) {
      final errorBody = e.response?.data;
      final detail = errorBody?['detail'] ?? "초대 요청 처리 실패";
      print("❌ 초대 API 오류: $detail");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("초대 실패: $detail")),
      );
      return false;
    } catch (e) {
      print("❌ 알 수 없는 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
      );
      return false;
    }
  }

  InputDecoration _buildInputDecoration(String hintText, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4C6DAF), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4C6DAF), width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    );
  }

  // ----------------------------------------------------------------
  // ⭐️ UI 빌드 함수 수정: 검색 결과 수 표시 (_totalSuggestedMembers)
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '팀원 초대',
          style: TextStyle(
            color: Color(0xFF4C6DAF),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              decoration: _buildInputDecoration(
                '원하는 팀원을 검색해보세요!',
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFF4C6DAF)),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (value) {
                _performSearch();
              },
            ),

            const SizedBox(height: 20),

            // ⭐️ 수정된 부분: length 값 표시
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _totalSuggestedMembers > 0
                    ? '${widget.groupDetail.groupName}에 어울리는 팀원 ${_totalSuggestedMembers}명이에요!'
                    : '${widget.groupDetail.groupName}에 어울리는 팀원이 없습니다.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 검색 결과 리스트
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4C6DAF), width: 1.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading
                    ? const Center(
                  child: LoadingSpinner(size: 80.0),
                )
                    :_suggestedMembers.isEmpty && _currentQuery.isEmpty
                    ? const Center(
                  // ⭐️ 검색 전 초기 상태
                  child: Text(
                    "닉네임 또는 키워드를 검색하여 팀원을 찾아보세요.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _suggestedMembers.length,
                  itemBuilder: (context, index) {
                    return _buildTeamMemberCard(_suggestedMembers[index]);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('이전', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      print("완료 버튼 입력");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamManagementScreen(
                            groupId: widget.groupDetail.id,
                            initialGroupDetail: widget.groupDetail,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('완료', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ✔ 3. [수정] 팀원 카드 UI: 관심사 -> 라이프 스타일 표시 (변경 없음)
  Widget _buildTeamMemberCard(TeamMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4C6DAF), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('프로필\n사진',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(shorten(member.nickname),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C6DAF))),
                    const SizedBox(width: 4),
                    // const Icon(Icons.chat_bubble_outline,
                    //     size: 18, color: Color(0xFF4C6DAF)),
                    GestureDetector(
                      onTap: () => _openChatWithMember(member), // 👈 채팅방 열기 함수 호출
                      child: const Icon(Icons.chat_bubble_outline,
                          size: 18,
                          color: Color(0xFF4C6DAF)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 🔹 여기가 UI 핵심 변경 부분
                Text(
                  "${member.lifestyle}",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: member.isInvited
                ? null
                : () async {
              final success = await _sendInvite(member.userId);

              if (success) {
                setState(() => member.isInvited = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${member.nickname}님을 초대했습니다.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: member.isInvited
                  ? const Color(0xFF4C6DAF).withOpacity(0.5)
                  : const Color(0xFF002B82).withOpacity(0.8),
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(member.isInvited ? "초대완료" : "초대하기"),
          ),
        ],
      ),
    );
  }
}