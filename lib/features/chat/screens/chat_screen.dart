import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/chat/services/chat_service.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatService _chatService = ChatService();

  bool _isLoading = true;
  bool _hasError = false;

  List<dynamic> _groupChats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChatRooms();
  }

  // ------------------------------------------------------------
  // 🔥 API: 채팅방 목록 불러오기
  // ------------------------------------------------------------
  Future<void> _loadChatRooms() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await _chatService.getChatRooms();

      print("🔥 서버 응답 데이터: $data");

      // FastAPI → {"status":200, "list":[{...}]}
      final List rooms = data;

      // 그룹 채팅만 존재하므로 그대로 저장
      setState(() {
        _groupChats = rooms;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("채팅 목록 오류: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ------------------------------------------------------------
  // 바텀바 탭 이동
  // ------------------------------------------------------------
  void _handleBottomTap(String tag) {
    switch (tag) {
      case 'home':
        Navigator.pushReplacementNamed(context, '/home');
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
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/home'),
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
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "그룹"),
            Tab(text: "개인"),
          ],
        ),
      ),

      body: _buildBody(),

      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'chat',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // ------------------------------------------------------------
  // 메인 화면 상태 관리
  // ------------------------------------------------------------
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4C6DAF)),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
            const SizedBox(height: 12),
            const Text("채팅 목록을 불러오지 못했습니다."),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadChatRooms,
              child: const Text("다시 시도"),
            )
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildChatList(_groupChats),
        _buildEmpty(), // 개인채팅 없음
      ],
    );
  }

  // ------------------------------------------------------------
  // 그룹 채팅 리스트 UI
  // ------------------------------------------------------------
  Widget _buildChatList(List chats) {
    if (chats.isEmpty) return _buildEmpty();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final room = chats[index];

        return _buildChatCard(
          title: room["group_name"] ?? "제목 없음",
          message: room["category"] ?? "",
          time: "",
          unread: "0",
          icon: Icons.group_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/chat-group-detail',
              arguments: {"chatId": room["chat_id"]},
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // 채팅 카드 UI
  // ------------------------------------------------------------
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
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
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
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Text(time,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                const SizedBox(height: 8),
                if (unread != "0")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C6DAF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 메시지 없음 화면
  // ------------------------------------------------------------
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
