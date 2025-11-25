import 'package:flutter/material.dart';
import 'package:lifematch_frontend/features/team_management/widgets/custom_bottom_nav_bar.dart';
import 'package:lifematch_frontend/features/group/screens/group_detail_screen.dart';
import 'package:lifematch_frontend/features/notification/services/notification_service.dart'; // 🔥 여기만 수정

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final NotificationService _service = NotificationService();

  List<dynamic> _myInvites = [];
  List<dynamic> _groupApplicants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _service.getNotifications();

      setState(() {
        _myInvites = data["invites"] ?? [];
        _groupApplicants = data["applicants"] ?? [];
        _loading = false;
      });
    } catch (e) {
      print("❌ 알림 불러오기 오류: $e");
      setState(() => _loading = false);
    }
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
        Navigator.pushNamed(context, '/chat');
        break;
      case 'connection':
        Navigator.pushNamed(context, '/my-group-manage');
        break;
      case 'bell':
        break;
      case 'profile':
        Navigator.pushNamed(context, '/my-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text(
          "알림",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4C6DAF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4C6DAF),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "소모임 초대"),
            Tab(text: "소모임 신청자"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInviteTab(),
          _buildApplicantTab(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedTag: 'bell',
        onTabSelected: _handleBottomTap,
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔹 [탭 1] 나에게 온 초대
  // ---------------------------------------------------------
  Widget _buildInviteTab() {
    if (_myInvites.isEmpty) return _buildEmptyState("받은 초대가 없습니다.");

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _myInvites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = _myInvites[index];

        return _buildNotificationCard(
          icon: Icons.mark_email_unread_rounded,
          iconColor: const Color(0xFFFF9800),
          title: item["group_name"] ?? "",
          subtitle: "보낸 사람: ${item["leader_name"] ?? ""}",
          message: item["message"] ?? "",
          time: item["created_at"] ?? "",
          isApplicant: false,
          actionId: item["action_id"],
          groupId: item["group_id"],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // 🔹 [탭 2] 내 모임 신청자
  // ---------------------------------------------------------
  Widget _buildApplicantTab() {
    if (_groupApplicants.isEmpty) return _buildEmptyState("들어온 신청이 없습니다.");

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _groupApplicants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final item = _groupApplicants[index];

        return _buildNotificationCard(
          icon: Icons.person_rounded,
          iconColor: const Color(0xFF4C6DAF),
          title: item["user_name"] ?? "",
          subtitle: "신청 모임: ${item["group_name"] ?? ""}",
          message: item["message"] ?? "",
          time: item["created_at"] ?? "",
          isApplicant: true,
          actionId: item["action_id"],
          groupId: item["group_id"],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // 🔹 공통 카드 UI + 버튼 (수락/거절 or 세부사항)
  // ---------------------------------------------------------
  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String message,
    required String time,
    required bool isApplicant,
    required String actionId,
    required String groupId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(time,
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(message,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          ),

          const SizedBox(height: 16),

          isApplicant
              ? Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final ok = await _service.respondToAction(
                        actionId, "decline");
                    if (ok) {
                      _loadNotifications();
                    }
                  },
                  child: const Text("거절"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final ok = await _service.respondToAction(
                        actionId, "accept");
                    if (ok) {
                      _loadNotifications();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C6DAF),
                  ),
                  child: const Text("수락",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          )
              : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => GroupDetailScreen(
                      groupId: groupId,
                      buttonType: GroupDetailButtonType.acceptOrDecline,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C6DAF)),
              child: const Text("세부사항",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
