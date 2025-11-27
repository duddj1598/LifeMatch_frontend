import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/chat/services/chat_service.dart';
import '../widgets/chat_bubble.dart';
import 'dart:async';

class ChatPersonalDetailScreen extends StatefulWidget {
  const ChatPersonalDetailScreen({super.key});

  @override
  State<ChatPersonalDetailScreen> createState() =>
      _ChatPersonalDetailScreenState();
}

class _ChatPersonalDetailScreenState extends State<ChatPersonalDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();

  Timer? _pollingTimer;

  List<dynamic> messages = [];
  int? nextMessageId;

  bool _isLoading = true;
  bool _hasError = false;

  late String chatId;
  late String roomName;
  late String myUserDocId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    chatId = args["chatId"];
    roomName = args["roomName"] ?? "개인 채팅";
    myUserDocId = args["myUserDocId"] ?? ""; // 필요하면 ChatScreen에서 넘겨줘

    _loadMessages();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // ⭐️ [필수] 타이머 해제
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  // -----------------------------------------------------------
  //  폴링 시작 (3초마다 메시지 갱신)
  // -----------------------------------------------------------
  void _startPolling() {
    // 3초 간격으로 서버에 메시지 요청
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // ⭐️ [_loadMessages]를 호출하되, UI 로딩 상태는 변경하지 않음 (백그라운드 갱신)
      _loadMessages(isPolling: true);
    });
  }
  // -----------------------------------------------------------
  // 🔥 메시지 불러오기
  // -----------------------------------------------------------
  Future<void> _loadMessages({bool isPolling = false}) async {
    // 최초 로딩이 아니고 폴링 중이라면, 로딩 상태를 변경하지 않음
    if (!isPolling) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    // ⭐️ [주의] 폴링 방식으로 메시지를 갱신할 때는 nextMessageId (페이징) 로직을 사용하지 않고
    // 매번 최신 메시지부터 N개를 가져와 기존 목록과 비교/갱신하는 복잡한 로직이 필요합니다.
    // 여기서는 간단하게 nextMessageId 없이 항상 최신 20개만 가져오는 것으로 가정하고 구현합니다.
    // (페이징과 폴링을 동시에 처리하는 것은 매우 복잡합니다.)

    try {
      // messageId를 넘기지 않고, 항상 최신 메시지 20개를 요청합니다.
      final Map<String, dynamic> data = await _chatService.getChatMessages(chatId);

      List<dynamic> loadedMessages = data["messages"] ?? [];
      loadedMessages = loadedMessages.reversed.toList(); // 최신 메시지가 아래로 오도록 역순 정렬

      // ⭐️ [추가] 새로 받은 메시지 목록이 기존 목록과 다를 때만 업데이트 (setState 최소화)
      if (messages.length != loadedMessages.length || (messages.isNotEmpty && messages.last['message_id'] != loadedMessages.last['message_id'])) {
        setState(() {
          messages = loadedMessages;
          nextMessageId = data["next_message_id"];
        });

        // 새 메시지가 있을 때만 스크롤 (맨 아래 메시지가 다를 경우)
        if (!isPolling || (messages.isNotEmpty && messages.last['user_id'] != myUserDocId)) {
          _scrollToBottom();
        }
      }

      if (!isPolling) {
        setState(() {
          _isLoading = false;
        });
      }

    } catch (e) {
      print("개인채팅 불러오기 오류 (폴링): $e");
      if (!isPolling) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }
  // -----------------------------------------------------------
  // 🔥 메시지 전송
  // -----------------------------------------------------------
  Future<void> _sendMessage() async {
    if (_inputController.text.trim().isEmpty) return;

    final text = _inputController.text.trim();
    _inputController.clear();

    // 1. UI에 임시 메시지 즉시 반영 (낙관적 업데이트)
    final tempMessageId = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      messages.add({
        "message_id": tempMessageId,
        "content": text,
        "user_id": myUserDocId,
        "time": DateTime.now().toIso8601String(),
        "isMine": true,
        "isSending": true, // 전송 중 상태 표시
      });
    });

    _scrollToBottom();

    try {
      // 2. 서버에 메시지 전송 (HTTP POST)
      await _chatService.sendMessage(chatId, text);

      // 3. 전송 성공 후, 다음 폴링 시 서버 DB에 저장된 실제 메시지를 가져오므로
      // 임시 메시지 제거 및 강제 폴링 시작
      setState(() {
        messages.removeWhere((msg) => msg["message_id"] == tempMessageId);
      });
      // ⭐️ [추가] 성공 후 즉시 폴링하여 DB에 저장된 메시지를 가져옴 (UX 개선)
      _loadMessages();

    } catch (e) {
      print("개인채팅 메시지 전송 오류: $e");

      // 4. 전송 실패 시 UI 메시지 제거 및 에러 표시
      setState(() {
        messages.removeWhere((msg) => msg["message_id"] == tempMessageId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메시지 전송에 실패했습니다.')),
      );
    }
  }
  void _scrollToBottom() {
    // ⭐️ [추가] 스크롤 함수 정의
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        // maxScrollExtent로 이동하면 맨 아래로 스크롤
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  // -----------------------------------------------------------
  // 화면 UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          roomName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
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
                    )
                  ],
                ),
              ),
            ),

          if (!_isLoading && !_hasError)
            Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  key: const PageStorageKey("chat_list"),
                  itemBuilder: (context, index) {
                    final msg = messages[index];

                    final String text = msg["content"] ?? "";
                    // 백엔드에서 'is_mine'이라는 키로 boolean 값을 내려줍니다. (Python 코드 참조)
                    // msg["isMine"]은 프론트에서 임시로 넣은 키일 수 있으니 둘 다 체크합니다.
                    final bool isMine = msg["is_mine"] ?? msg["isMine"] ?? (msg["user_id"] == myUserDocId);

                    // ⭐️ [핵심 수정] Align 위젯으로 감싸서 좌/우 정렬
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
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

  // -----------------------------------------------------------
  // 입력창
  // -----------------------------------------------------------
  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: "채팅 입력",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
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
