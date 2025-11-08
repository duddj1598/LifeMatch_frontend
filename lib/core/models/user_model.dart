// lib/core/models/user_model.dart

class UserModel {
  final String userId;
  final String name; // 백엔드의 'user_nickname'이 매핑됩니다.
  final String email;
  final String? profileImageUrl; // null일 수 있으므로 '?'를 붙입니다.

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  // ⭐️ 서버에서 받은 JSON(Map)을 UserModel 객체로 변환하는 factory 생성자
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?, // null 허용
    );
  }
}