import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _deviceNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              "알림 설정",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 구분선
            Divider(color: Colors.grey.shade300, thickness: 1),

            const SizedBox(height: 20),

            // 타이틀 + 스위치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "기기 알림 설정",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _deviceNotification,
                  activeColor: Colors.blueAccent,
                  onChanged: (value) {
                    setState(() {
                      _deviceNotification = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 설명 텍스트
            const Text(
              "참여 중인 소모임의 중요소식 등\n꼭 필요한 것만 알려드려요",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
