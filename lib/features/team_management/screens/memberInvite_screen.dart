import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lifematch_frontend/features/team_management/screens/team_management_screen.dart';
import 'package:lifematch_frontend/features/group/models/group_model.dart';
import 'package:lifematch_frontend/core/services/storage_service.dart';

// 🔹 팀원 데이터 모델
class TeamMember {
  final String userId;
  final String nickname;
  final String interest;
  bool isInvited;

  TeamMember({
    required this.userId,
    required this.nickname,
    required this.interest,
    this.isInvited = false,
  });
}

class MemberInviteScreen extends StatefulWidget {
  // ⭐️ [수정] 오직 GroupModel 하나만 받습니다.
  final GroupModel groupDetail;

  const MemberInviteScreen({
    super.key,
    required this.groupDetail, // 필수값
  });

  @override
  State<MemberInviteScreen> createState() => _MemberInviteScreenState();
}

class _MemberInviteScreenState extends State<MemberInviteScreen> {
  final List<TeamMember> _suggestedMembers = [];
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();

  String _currentQuery = "";
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔹 8글자 넘으면 ... 처리하는 함수 (유지)
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

  // 🔥 패널 검색 API 연동
  Future<void> _searchPanelMembers(String query) async {
    if (!mounted) return;

    if (query.isEmpty) {
      setState(() {
        _suggestedMembers.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("http://10.0.2.2:8000/api/panel/search");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "query": query,
          // ⭐️ [수정] widget.selectedCategory 대신 모델에서 꺼내 사용
          // category가 null일 경우를 대비해 기본값 처리
          "category": widget.groupDetail.category ?? "",
        }),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final List<dynamic> idList = res["id"] ?? [];

        if (!mounted) return;
        setState(() {
          _suggestedMembers.clear();
          _suggestedMembers.addAll(
            idList.map((panelId) {
              return TeamMember(
                userId: panelId as String,
                nickname: shorten("$panelId"),
                interest: "관심사 정보 없음",
              );
            }),
          );
        });
      } else {
        print("❌ API 오류: ${response.body}");
        if (!mounted) return;
        setState(() {
          _suggestedMembers.clear();
        });
      }
    } catch (e) {
      print("❌ 네트워크 오류: $e");
      if (!mounted) return;
      setState(() {
        _suggestedMembers.clear();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 초대 API 호출 함수
  Future<bool> _sendInvite(String targetUserId) async {
    const url = "http://10.0.2.2:8000/api/group-action/invite";
    final String? accessToken = await _storageService.getToken();

    if (accessToken == null || accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("초대를 위해 먼저 로그인해야 합니다.")),
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          // ⭐️ [수정] widget.groupId 대신 모델의 ID 사용
          "group_id": widget.groupDetail.id,
          "user_id": targetUserId
        }),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("✅ 초대 성공: ${res['message']}");
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        final detail = errorBody['detail'] ?? "초대 요청 처리 실패";
        print("❌ 초대 API 오류: $detail");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("초대 실패: $detail")),
        );
        return false;
      }
    } catch (e) {
      print("❌ 네트워크/파싱 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("네트워크 오류가 발생했습니다.")),
      );
      return false;
    }
  }

  // 🔹 검색창 디자인 (유지)
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

            // 🔍 검색 바
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

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // ⭐️ [수정] 모델 내부의 groupName 사용
                '${widget.groupDetail.groupName}에 어울리는 팀원이에요!',
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
                child: ListView.builder(
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

                      // ⭐️ [수정] TeamManagementScreen으로 이동 시 GroupModel 전체 전달
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamManagementScreen(
                            // 모델에서 ID 추출
                            groupId: widget.groupDetail.id,

                            // 모델 자체를 초기값으로 전달 (서버 재호출 방지)
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

  // ✔ 팀원 카드 UI (유지)
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
                    const Icon(Icons.chat_bubble_outline,
                        size: 18, color: Color(0xFF4C6DAF)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("관심사: ${member.interest}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
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