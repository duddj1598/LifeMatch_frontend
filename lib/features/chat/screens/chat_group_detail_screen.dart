import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/chat/services/chat_service.dart';
import '../widgets/chat_bubble.dart'; // ChatBubble 위젯 임포트
import 'dart:async';

class ChatGroupDetailScreen extends StatefulWidget {
  const ChatGroupDetailScreen({super.key});

  @override
  State<ChatGroupDetailScreen> createState() => _ChatGroupDetailScreenState();
}

class _ChatGroupDetailScreenState extends State<ChatGroupDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  Timer? _pollingTimer;
  List<dynamic> messages = [];
  bool _isLoading = true;
  bool _hasError = false;

  late String chatId;
  late String roomName;
  late String myUserDocId; // ⭐️ 내 ID 변수 추가

  // ⭐️ 중복 갱신 방지를 위한 마지막 메시지 ID
  int _lastMessageId = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    chatId = args["chatId"];
    roomName = args["roomName"] ?? "";
    myUserDocId = args["myUserDocId"] ?? ""; // ⭐️ 내 ID 받아오기

    _loadMessages();
    _startPolling(); // 폴링 시작
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // 타이머 해제
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------
  // 🔄 폴링 로직 (3초 주기)
  // -------------------------------------------------------
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages(isPolling: true);
    });
  }

  // -------------------------------------------------------
  // 🔥 API: 채팅 내역 불러오기 (최적화 적용)
  // -------------------------------------------------------
  Future<void> _loadMessages({bool isPolling = false}) async {
    if (!isPolling) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final Map<String, dynamic> data = await _chatService.getChatMessages(chatId);

      // 백엔드에서 날짜순(오래된 것 -> 최신)으로 온다고 가정
      final List<dynamic> loadedMessages = data["messages"] ?? [];

      // ⭐️ [최적화] 데이터가 있고, 마지막 메시지가 변하지 않았다면 리턴 (화면 갱신 X)
      if (loadedMessages.isNotEmpty) {
        final newLastId = loadedMessages.last['message_id'];

        if (messages.length == loadedMessages.length && _lastMessageId == newLastId) {
          return;
        }

        if (mounted) {
          setState(() {
            messages = loadedMessages;
            _lastMessageId = newLastId;
          });

          // 폴링 중이 아니거나, 최신 메시지가 내가 보낸 것일 때만 스크롤 내림
          if (!isPolling || (loadedMessages.last['user_id'] == myUserDocId)) {
            _scrollToBottom();
          }
        }
      }

      if (!isPolling) {
        setState(() => _isLoading = false);
      }

    } catch (e) {
      print("채팅 내역 불러오기 오류: $e");
      if (!isPolling) setState(() => _isLoading = false);
    }
  }

  // -------------------------------------------------------
  // 🔥 API: 메시지 전송
  // -------------------------------------------------------
  Future<void> _sendMessage() async {
    if (_inputController.text.trim().isEmpty) return;

    final text = _inputController.text.trim();
    _inputController.clear();

    // 낙관적 업데이트 (UI에 먼저 표시)
    final tempMessageId = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      messages.add({
        "message_id": tempMessageId,
        "content": text,
        "user_id": myUserDocId, // 내 ID 사용
        "time": DateTime.now().toIso8601String(),
        "is_mine": true,
      });
    });

    _scrollToBottom();

    try {
      await _chatService.sendMessage(chatId, text);
      // 전송 성공 시 즉시 데이터 갱신
      _loadMessages(isPolling: true);
    } catch (e) {
      print("메시지 전송 오류: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        // 정방향 리스트이므로 maxScrollExtent가 맨 아래입니다.
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // -------------------------------------------------------
  // 화면 구성
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          roomName.isNotEmpty ? roomName : "채팅방",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF4C6DAF)),
              ),
            ),

          if (_hasError)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("메시지를 불러올 수 없습니다"),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadMessages,
                      child: const Text("다시 시도"),
                    ),
                  ],
                ),
              ),
            ),

          if (!_isLoading && !_hasError)
            Expanded(
              child: ListView.builder(
                // ⭐️ 스크롤 상태 유지를 위한 Key
                key: const PageStorageKey("group_chat_list"),
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  final String text = msg["content"] ?? "";
                  // is_mine 체크 로직 통일
                  final bool isMine = msg["is_mine"] ?? msg["isMine"] ?? (msg["user_id"] == myUserDocId);

                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    // ⭐️ 개인 채팅과 동일하게 ChatBubble 위젯 사용
                    child: ChatBubble(
                      text: text,
                      isMine: isMine,
                    ),
                  );
                },
              ),
            ),

          if (!_isLoading && !_hasError) _buildInputBox(),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // 입력창
  // -------------------------------------------------------
  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: "채팅 입력",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: const Icon(
              Icons.send_rounded,
              color: Color(0xFF4C6DAF),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}