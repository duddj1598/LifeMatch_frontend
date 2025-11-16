import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final Function(String tag) onTabSelected;
  const CustomBottomNavBar({super.key, required this.onTabSelected});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  String _selected = 'home';

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
    final bool isSelected = (_selected == tag);

    return GestureDetector(
      onTap: () {
        setState(() => _selected = tag);
        widget.onTabSelected(tag);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imagePath,
            width: isSelected ? 32 : 28,
            height: isSelected ? 32 : 28,
            color: isSelected
                ? const Color(0xFF6B7AA1)
                : Colors.grey.shade500,
          ),
          const SizedBox(height: 3),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              isSelected ? const Color(0xFF6B7AA1) : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
