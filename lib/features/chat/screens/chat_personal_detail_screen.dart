import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/chat/services/chat_service.dart';
import '../widgets/chat_bubble.dart';

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
  }

  // -----------------------------------------------------------
  // 🔥 메시지 불러오기
  // -----------------------------------------------------------
  Future<void> _loadMessages() async {
    try {
      final Map<String, dynamic> data =
      await _chatService.getChatMessages(chatId);

      setState(() {
        messages = data["messages"] ?? [];
        nextMessageId = data["next_message_id"];
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print("개인채팅 불러오기 오류: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // -----------------------------------------------------------
  // 🔥 메시지 전송
  // -----------------------------------------------------------
  Future<void> _sendMessage() async {
    if (_inputController.text.trim().isEmpty) return;

    final text = _inputController.text.trim();
    _inputController.clear();

    // UI 먼저 반영
    setState(() {
      messages.add({
        "content": text,
        "user_id": myUserDocId,
        "time": DateTime.now().toIso8601String(),
        "isMine": true,
      });
    });

    _scrollToBottom();

    try {
      await _chatService.sendMessage(chatId, text);
    } catch (e) {
      print("개인채팅 메시지 전송 오류: $e");
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
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  final String text = msg["content"] ?? "";
                  final String sender = msg["user_id"] ?? "";
                  final bool isMine =
                      msg["isMine"] ?? (sender == myUserDocId);

                  return ChatBubble(
                    text: text,
                    isMine: isMine,
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
