import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/group/screens/group_detail_screen.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // --- 1. 소모임 초대 데이터 (나에게 온 초대) ---
  final List<Map<String, String>> _myInvites = [
    {
      "groupName": "서울 맛집 탐방",
      "leader": "맛잘알",
      "message": "회원님의 프로필을 보고 저희 모임에 딱 맞을 것 같아 초대합니다!",
      "time": "10분 전"
    },
    {
      "groupName": "주말 등산 크루",
      "leader": "산타할아버지",
      "message": "이번 주 관악산 등반 함께 하실래요?",
      "time": "1시간 전"
    },
    {
      "groupName": "영어 회화 스터디",
      "leader": "EnglishMaster",
      "message": "초급반 인원 충원 중입니다. 관심 있으시면 수락해주세요.",
      "time": "어제"
    },
  ];

  // --- 2. 소모임 신청자 데이터 (내 모임에 들어온 신청) ---
  final List<Map<String, String>> _groupApplicants = [
    {
      "userName": "김철수",
      "targetGroup": "코딩 스터디",
      "message": "열심히 참여하겠습니다! 파이썬 기초 공부 중입니다.",
      "time": "방금 전"
    },
    {
      "userName": "이영희",
      "targetGroup": "코딩 스터디",
      "message": "안녕하세요, 모임 분위기가 좋아 보여서 신청합니다.",
      "time": "30분 전"
    },
    {
      "userName": "박지성",
      "targetGroup": "주말 축구단",
      "message": "포지션은 미드필더입니다. 매주 참석 가능합니다.",
      "time": "2시간 전"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        print('🏠 홈 이동');
        Navigator.pushNamed(context, '/home');
        break;
      case 'chat':
        print('💬 채팅 탭');
        Navigator.pushNamed(context, '/chat');
      case 'connection':
        print('🔗 소모임 연결');
        Navigator.pushNamed(context, '/my-group-manage');
        break;
      case 'bell':
        break;
      case 'profile':
        print('👤 프로필 탭');
        Navigator.pushNamed(context, '/my-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home')
        ),
        title: const Text(
          "알림",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4C6DAF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4C6DAF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "소모임 초대"), // Tab 1
            Tab(text: "소모임 신청자"), // Tab 2
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInviteTab(),    // 초대 탭 화면
          _buildApplicantTab(), // 신청자 탭 화면
        ],
      ),

      // ⭐️ 수정: SafeArea 제거 (여백 삭제)
      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'bell',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // --- [탭 1] 소모임 초대 리스트 ---
  Widget _buildInviteTab() {
    if (_myInvites.isEmpty) return _buildEmptyState("받은 초대가 없습니다.");

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _myInvites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = _myInvites[index];
        return _buildNotificationCard(
          icon: Icons.mark_email_unread_rounded,
          iconColor: const Color(0xFFFF9800), // 주황색 (초대 느낌)
          title: item['groupName']!,
          subtitle: "보낸사람: ${item['leader']}",
          message: item['message']!,
          time: item['time']!,
          isApplicant: false, // 초대 모드
        );
      },
    );
  }

  // --- [탭 2] 소모임 신청자 리스트 ---
  Widget _buildApplicantTab() {
    if (_groupApplicants.isEmpty) return _buildEmptyState("들어온 신청이 없습니다.");

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _groupApplicants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = _groupApplicants[index];
        return _buildNotificationCard(
          icon: Icons.person_rounded,
          iconColor: const Color(0xFF4C6DAF), // 파란색 (신청자 느낌)
          title: item['userName']!,
          subtitle: "신청 모임: ${item['targetGroup']}",
          message: item['message']!,
          time: item['time']!,
          isApplicant: true, // 신청자 모드
        );
      },
    );
  }

  // --- 공통: 알림 카드 위젯 (버튼 포함) ---
  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String message,
    required String time,
    required bool isApplicant,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 상단 정보 (아이콘, 제목, 시간) - 기존과 동일
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. 메시지 내용 (박스 처리) - 기존과 동일
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),

          const SizedBox(height: 16),

          // 3. 액션 버튼 (수정된 부분)
          isApplicant
              ? Row( // 소모임 신청자 (거절/수락 버튼 2개)
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    print("거절 클릭");
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("거절",
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    print("수락 클릭");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C6DAF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("수락",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
              : // 소모임 초대 (세부사항 버튼 1개)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print("세부사항 클릭 - GroupDetailScreen으로 이동");
                // 🚨 여기에 GroupDetailScreen으로 이동하는 로직을 추가해야 합니다.
                Navigator.push(context, MaterialPageRoute(builder: (c) => GroupDetailScreen(buttonType: GroupDetailButtonType.acceptOrDecline)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6DAF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("세부사항",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
  // 빈 화면 표시 위젯
  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}