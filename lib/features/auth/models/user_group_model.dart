class UserGroup {
  final String id;
  final String name;
  final String? category;
  final int currentMember;
  final int maxMember;
  final String? description;
  final String? groupImage;

  UserGroup({
    required this.id,
    required this.name,
    this.category,
    required this.currentMember,
    required this.maxMember,
    this.description,
    this.groupImage,
  });

  // 백엔드의 MyGroup 스키마에 맞춘 fromJson 팩토리 메서드
  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['group_id'] ?? json['id'] ?? '',
      name: json['group_name'] ?? '이름 없음',
      category: json['category'],
      currentMember: (json['current_member'] as num?)?.toInt() ?? 0,
      maxMember: (json['max_member'] as num?)?.toInt() ?? 10,
      description: json['description'],
      groupImage: json['group_image'],
    );
  }
}