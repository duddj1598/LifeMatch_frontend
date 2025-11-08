import 'package:flutter/material.dart';

class DropdownMenuExample extends StatefulWidget {
  final String label;
  const DropdownMenuExample({super.key, required this.label});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  String? selectedQuestion;
  final List<String> questions = [
    '가장 좋아하는 음식은?',
    '졸업한 초등학교 이름은?',
    '가장 친한 친구 이름은?',
    '첫 반려동물 이름은?',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        initialValue: selectedQuestion,
        decoration: InputDecoration(
          labelText: widget.label,
          border: InputBorder.none,
        ),
        items: questions
            .map((q) => DropdownMenuItem(value: q, child: Text(q)))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedQuestion = value;
          });
        },
      ),
    );
  }
}
