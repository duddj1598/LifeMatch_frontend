import 'package:flutter/material.dart';

// 임시 데이터 모델
class TeamMember {
  final String nickname;
  final String interest;
  bool isInvited;

  TeamMember({required this.nickname, required this.interest, this.isInvited = false});
}

class MemberInviteScreen extends StatefulWidget {
  const MemberInviteScreen({super.key});

  @override
  State<MemberInviteScreen> createState() => _MemberInviteScreenState();
}

class _MemberInviteScreenState extends State<MemberInviteScreen> {
  final List<TeamMember> _suggestedMembers = [
    TeamMember(nickname: '김멋쟁', interest: '운동, 독서'),
    TeamMember(nickname: '이개발', interest: '코딩, 게임'),
    TeamMember(nickname: '박디자인', interest: '그림, 영화'),
    TeamMember(nickname: '최기획', interest: '여행, 음악'),
    TeamMember(nickname: '정마케터', interest: '브랜딩, 사진'),
  ];

  final TextEditingController _searchController = TextEditingController();

  // ✅ 1. 새 멤버의 번호를 추적하기 위한 카운터 변수를 추가합니다.
  int _newMemberCounter = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            const SizedBox(height: 18), // 검색창 상단 여백

            // 검색 바
            TextField(
              controller: _searchController,
              decoration: _buildInputDecoration(
                '원하는 팀원을 검색해보세요!',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4C6DAF)),
              ),
              onChanged: (value) {
                // 검색 로직
              },
            ),

            const SizedBox(height: 20),

            // [소모임 이름]에 어울리는 팀원이에요!
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '[소모임 이름]에 어울리는 팀원이에요!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 프로필 목록
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4C6DAF), width: 1.0), // 외부 테두리
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0), // 외부 테두리와 카드 리스트 사이의 여백
                  itemCount: _suggestedMembers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _suggestedMembers.length) {
                      return _buildProfileMoreButton();
                    } else {
                      final member = _suggestedMembers[index];
                      return _buildTeamMemberCard(member);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24), // 하단 버튼과의 간격

            // 하단 버튼 (이전 / 완료)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // '이전' 버튼: 이전 페이지로 돌아갑니다. (변경 없음)
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '이전',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    // '완료' 버튼: 요청하신 디버그 프린트 및 주석 추가
                    onPressed: () {
                      // 1. 요청하신 디버그 메시지 출력
                      print("완료 버튼 입력");

                      // 2. 기존 SnackBar 메시지 (유지)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("팀원 초대 완료 (선택된 팀원 처리 로직 필요)")),
                      );

                      // 3. 다음 페이지로 이동 (현재는 주석 처리)
                      // 다음 페이지(예: YourNextPageScreen)가 구현되면 이 부분의 주석을 해제하세요.
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const YourNextPageScreen()),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C6DAF).withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
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

  // '프로필 더보기' 버튼 (✅ 2. 로직이 5명씩 추가하도록 변경됨)
  Widget _buildProfileMoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: () {
          // --- 5명 추가 로직 ---
          setState(() {
            List<TeamMember> newMembers = []; // 1. 5명을 담을 빈 리스트 생성
            for (int i = 0; i < 5; i++) { // 2. 5번 반복
              newMembers.add(
                TeamMember(
                  nickname: '새 멤버 $_newMemberCounter', // 3. 카운터를 이용해 고유 이름 부여
                  interest: '추가 관심사',
                  isInvited: false,
                ),
              );
              _newMemberCounter++; // 4. 다음 이름을 위해 카운터 1 증가
            }
            _suggestedMembers.addAll(newMembers); // 5. 5명이 담긴 리스트를 한꺼번에 추가
          });
          // --- 로직 끝 ---
        },
        child: const Text(
          '프로필 더보기',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C6DAF),
          ),
        ),
      ),
    );
  }

  // 팀원 프로필 카드 (변경 없음)
  Widget _buildTeamMemberCard(TeamMember member) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 8.0), // (left, top, right, bottom)
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // 카드 자체의 테두리
        border: Border.all(color: const Color(0xFF4C6DAF), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '프로필\n사진',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C6DAF),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF4C6DAF)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '관심사: ${member.interest}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: member.isInvited
                ? null
                : () {
              setState(() {
                member.isInvited = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member.nickname}님을 초대했습니다.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: member.isInvited
                  ? const Color(0xFF4C6DAF).withOpacity(0.5)
                  : const Color(0xFF002B82).withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              member.isInvited ? '초대완료' : '초대하기',
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}