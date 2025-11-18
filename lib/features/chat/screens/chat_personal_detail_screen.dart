import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_box.dart';

class ChatPersonalDetailScreen extends StatefulWidget {
  const ChatPersonalDetailScreen({super.key});

  @override
  State<ChatPersonalDetailScreen> createState() =>
      _ChatPersonalDetailScreenState();
}

class _ChatPersonalDetailScreenState extends State<ChatPersonalDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 기본 메시지 (개인 채팅)
  List<Map<String, dynamic>> messages = [
    {"text": "안녕하세요! 독서 소모임에 대해 궁금해서 연락드립니다!", "isMine": false},
    {"text": "정확히 어떤 책 읽어야 하나요?", "isMine": false},
    {"text": "안녕하세요!", "isMine": true},
    {"text": "원하는 책 자유롭게 읽으시면 됩니다~", "isMine": true},
    {"text": "독서 관련된 질문도 괜찮아나요??", "isMine": false},
    {"text": "자유로운 독서 채팅입니다!", "isMine": true},
    {"text": "감사합니다!", "isMine": false},
  ];

  void _sendMessage() {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": _inputController.text.trim(),
        "isMine": true,
      });
    });

    _inputController.clear();

    // 스크롤 아래로 자동 이동
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 ChatScreen에서 전달된 roomName 받아오기
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String roomName = args['roomName'];

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

        // 🔥 고정 텍스트 삭제 & roomName 적용
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
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(
                  text: msg["text"],
                  isMine: msg["isMine"],
                );
              },
            ),
          ),

          // 🔥 실시간 입력창
          Container(
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
          ),
        ],
      ),
    );
  }
}
