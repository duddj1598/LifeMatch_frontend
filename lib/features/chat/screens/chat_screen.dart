import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // --- 1. 그룹 채팅 리스트 ---
  final List<Map<String, String>> _groupChats = [
    {
      "title": "서울시, 러닝Together",
      "message": "이번 주말 한강 러닝 어떠신가요?",
      "time": "4:30 PM",
      "unread": "10"
    },
    {
      "title": "보드게임 할래요!",
      "message": "다른 가능한 멤버 알려주세요~",
      "time": "11:25 AM",
      "unread": "6"
    },
    {
      "title": "편안하고 조용한 독서",
      "message": "독서모임 관심 있으신가요?",
      "time": "어제",
      "unread": "5"
    },
  ];

  // --- 2. 개인 채팅 리스트 ---
  final List<Map<String, String>> _personalChats = [
    {
      "title": "사용자 아이디 A",
      "message": "어떤 영화 같은 거 해요??",
      "time": "4:30 PM",
      "unread": "2"
    },
    {
      "title": "사용자 아이디 B",
      "message": "정확히 어떤 위치에서 만날까요?",
      "time": "11:25 AM",
      "unread": "1"
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
        Navigator.pushNamed(context, '/home');
        break;
      case 'chat':
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
          "채팅",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4C6DAF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4C6DAF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "그룹"),
            Tab(text: "개인"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGroupChatTab(),
          _buildPersonalChatTab(),
        ],
      ),

      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'chat',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // ----------------------------
  // [탭 1] 그룹 채팅 목록 (수정됨: arguments 전달)
  // ----------------------------
  Widget _buildGroupChatTab() {
    if (_groupChats.isEmpty) return _buildEmpty();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _groupChats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final item = _groupChats[index];
        return _buildChatCard(
          title: item['title']!,
          message: item['message']!,
          time: item['time']!,
          unread: item['unread']!,
          icon: Icons.group_rounded,

          // 🔥 각 채팅방의 정보를 arguments로 전달
          onTap: () {
            Navigator.pushNamed(
              context,
              '/chat-group-detail',
              arguments: {
                'roomName': item['title'],
              },
            );
          },
        );
      },
    );
  }

  // ----------------------------
  // [탭 2] 개인 채팅 목록 (수정됨)
  // ----------------------------
  Widget _buildPersonalChatTab() {
    if (_personalChats.isEmpty) return _buildEmpty();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _personalChats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final item = _personalChats[index];
        return _buildChatCard(
          title: item['title']!,
          message: item['message']!,
          time: item['time']!,
          unread: item['unread']!,
          icon: Icons.person_rounded,

          onTap: () {
            Navigator.pushNamed(
              context,
              '/chat-personal-detail',
              arguments: {
                'roomName': item['title'],
              },
            );
          },
        );
      },
    );
  }

  // ----------------------------
  // 공통: 채팅 카드 UI
  // ----------------------------
  Widget _buildChatCard({
    required String title,
    required String message,
    required String time,
    required String unread,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE4E9F7),
              child: Icon(icon, color: const Color(0xFF4C6DAF)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Text(time,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C6DAF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unread,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // 공통: 빈 화면
  // ----------------------------
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("메시지가 없습니다", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
