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
  List<dynamic> _dmChats = [];

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
      final List rooms = await _chatService.getChatRooms(); // ⭐️ List<dynamic>으로 타입 명시

      print("🔥 서버 응답 데이터: $rooms");

      List<dynamic> groups = [];
      List<dynamic> dms = [];

      // ⭐️ [수정] type 필드를 기준으로 그룹 채팅과 DM 채팅 분리
      for (var room in rooms) {
        if (room["type"] == "group") {
          groups.add(room);
        } else if (room["type"] == "dm") {
          dms.add(room);
        }
      }

      setState(() {
        _groupChats = groups;
        _dmChats = dms; // ⭐️ DM 채팅 목록 저장
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
        _buildChatList(_groupChats, type: "group"), // ⭐️ type 인자 추가
        _buildChatList(_dmChats, type: "dm"), // ⭐️ [수정] DM 채팅 목록 연결
      ],
    );
  }

  // ------------------------------------------------------------
  // 그룹 채팅 리스트 UI
  // ------------------------------------------------------------
  Widget _buildChatList(List chats, {required String type}) { // ⭐️ type 인자 받도록 수정
    if (chats.isEmpty) return _buildEmpty();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final room = chats[index];

        // ⭐️ [수정] 채팅방 타입에 따라 제목, 메시지, 아이콘, 라우팅 경로 변경
        String title = room["name"] ?? "제목 없음";
        String message;
        IconData icon;
        String route;

        if (type == "group") {
          title = room["name"] ?? room["group_name"] ?? "그룹 제목 없음";
          message = room["category"] ?? "그룹 채팅";
          icon = Icons.group_rounded;
          route = '/chat-group-detail';
        } else { // DM
          // DM에서는 name 필드에 상대방 닉네임이 들어있음 (chat_service.py 참고)
          message = "1:1 대화";
          icon = Icons.person_rounded;
          route = '/chat-personal-detail';
        }

        return _buildChatCard(
          title: title,
          message: message,
          time: "", // 시간 정보가 없으므로 공백
          unread: "0", // 안 읽은 메시지 수 정보가 없으므로 0
          icon: icon,
          onTap: () {
            // ⭐️ [수정] DM/그룹 타입에 따라 라우팅 경로 변경 및 arguments 전달
            Navigator.pushNamed(
              context,
              route,
              arguments: {
                "chatId": room["chat_id"],
                "roomName": title, // 채팅방 상세 화면에 이름 전달
                // "myUserDocId": "...", // 필요하면 여기서 전달 (로그인 서비스 필요)
              },
            ).then((_) {
              // 채팅방에서 돌아왔을 때 목록 새로고침 (새 메시지 반영)
              _loadChatRooms();
            });
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
