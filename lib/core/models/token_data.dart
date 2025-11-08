// lib/core/models/token_data.dart

// ⭐️ 1번에서 만든 UserModel 모델을 임포트합니다.
// (프로젝트 이름(lifematch_frontend)이 다르면 맞게 수정하세요)
import 'package:lifematch_frontend/core/models/user_model.dart';

class TokenData {
  final String accessToken;
  final String refreshToken;
  final UserModel userInfo; // ⭐️ UserModel을 멤버 변수로 가집니다.

  TokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.userInfo,
  });

  // ⭐️ 서버에서 받은 JSON(Map)을 TokenData 객체로 변환
  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      // 중첩된 'userInfo' JSON 객체는 UserModel.fromJson을 호출하여 변환합니다.
      userInfo: UserModel.fromJson(json['userInfo'] as Map<String, dynamic>),
    );
  }
}