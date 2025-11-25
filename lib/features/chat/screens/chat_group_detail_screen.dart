import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/chat/services/chat_service.dart';

class ChatGroupDetailScreen extends StatefulWidget {
  const ChatGroupDetailScreen({super.key});

  @override
  State<ChatGroupDetailScreen> createState() => _ChatGroupDetailScreenState();
}

class _ChatGroupDetailScreenState extends State<ChatGroupDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ChatService _chatService = ChatService();

  List<dynamic> messages = [];
  int? nextMessageId;

  bool _isLoading = true;
  bool _hasError = false;

  late String chatId;
  late String roomName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔥 ChatScreen에서 전달된 arguments 가져오기
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    chatId = args["chatId"];
    roomName = args["roomName"] ?? "";

    _loadMessages();
  }

  // -------------------------------------------------------
  // 🔥 API: 채팅 내역 불러오기
  // -------------------------------------------------------
  Future<void> _loadMessages() async {
    try {
      final Map<String, dynamic> data =
      await _chatService.getChatMessages(chatId);

      print("🔥 서버 채팅 내역 응답: $data");

      setState(() {
        messages = data["messages"] ?? [];
        nextMessageId = data["next_message_id"];
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print("채팅 내역 불러오기 오류: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // -------------------------------------------------------
  // 🔥 API: 메시지 전송
  // -------------------------------------------------------
  Future<void> _sendMessage() async {
    if (_inputController.text.trim().isEmpty) return;

    final text = _inputController.text.trim();
    _inputController.clear();

    // UI에 먼저 표시
    setState(() {
      messages.add({
        "content": text,
        "isMine": true,
        "time": DateTime.now().toIso8601String(),
      });
    });

    _scrollToBottom();

    try {
      await _chatService.sendMessage(chatId, text);
    } catch (e) {
      print("메시지 전송 오류: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent + 80,
        );
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
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  final String text = msg["content"] ?? "";
                  final String time = msg["time"] ?? "";
                  final bool isMine =
                      msg["isMine"] ??
                          (msg["user_id"] == "me"); // 백엔드 user_id 비교 가능

                  return Align(
                    alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isMine
                            ? const Color(0xFFD7E3FF)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(text),
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
              ),
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
