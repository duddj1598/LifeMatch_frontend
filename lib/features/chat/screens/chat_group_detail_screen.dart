import 'package:flutter/material.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_box.dart';

class ChatGroupDetailScreen extends StatefulWidget {
  const ChatGroupDetailScreen({super.key});

  @override
  State<ChatGroupDetailScreen> createState() => _ChatGroupDetailScreenState();
}

class _ChatGroupDetailScreenState extends State<ChatGroupDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 채팅 메시지 List
  List<Map<String, dynamic>> messages = [
    {"text": "안녕하세요~ 채팅방에 오신걸 환영합니다!", "isMine": false},
    {"text": "자유롭게 채팅을 나눠보세요 😊", "isMine": false},
  ];

  // 메시지 전송 함수
  void _sendMessage() {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      messages.add({
        "text": _inputController.text.trim(),
        "isMine": true,
      });
    });

    _inputController.clear();

    // 스크롤 가장 아래로 이동
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
    // 🔥 여기에서 지금 눌린 채팅방의 이름을 받아온다!
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final String roomName = args['roomName'];  // ← 핵심

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        // 🔥 "고정 텍스트" 제거하고 전달받은 roomName 사용
        title: Text(
          roomName,
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
          // 채팅 메시지 목록
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isMine = messages[index]["isMine"];
                final text = messages[index]["text"];

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
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

          // 입력창
          _buildInputBox(),
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: Colors.white,
      child: Row(
        children: [
          // 입력필드
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

          // 전송버튼
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
