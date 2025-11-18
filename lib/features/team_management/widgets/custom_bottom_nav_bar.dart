import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final Function(String tag) onTabSelected;
  final String selectedTag; // ⭐️ 1. 외부에서 현재 탭 정보를 받는 변수 추가

  const CustomBottomNavBar({
    super.key,
    required this.onTabSelected,
    this.selectedTag = 'home', // ⭐️ 2. 기본값은 'home'
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  // ⭐️ 3. 내부 상태 변수(_selected) 삭제.
  // 화면이 바뀔 때마다 위젯이 새로 빌드되므로 widget.selectedTag만 믿으면 됩니다.

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: Color(0xFFE8EAF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavIcon('home', 'assets/images/home_icon.png'),
            _buildNavIcon('chat', 'assets/images/chat_icon.png'),
            _buildNavIcon('connection', 'assets/images/connection_icon.png'),
            _buildNavIcon('bell', 'assets/images/bell_icon.png'),
            _buildNavIcon('profile', 'assets/images/profile_icon.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(String tag, String imagePath) {
    // ⭐️ 4. 현재 탭인지 확인 (내부 변수 대신 widget.selectedTag 사용)
    final bool isSelected = (widget.selectedTag == tag);

    return GestureDetector(
      onTap: () {
        // setState(() => _selected = tag); // ⭐️ 삭제 (화면 이동하므로 불필요)
        widget.onTabSelected(tag);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: isSelected ? 32 : 28,
            height: isSelected ? 32 : 28,
            // ⭐️ 5. 선택되면 파란색(#6B7AA1), 아니면 회색
            color: isSelected
                ? const Color(0xFF4C6DAF) // 요청하신 파란색 계열
                : Colors.grey.shade500,
          ),
          const SizedBox(height: 3),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ⭐️ 6. 선택된 탭만 아래 점 표시
              color: isSelected
                  ? const Color(0xFF4C6DAF)
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}