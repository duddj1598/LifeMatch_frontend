class HomeRecommendation {
  final String userLifestyleType;
  final List<RecommendedActivity> recommendedActivities;

  HomeRecommendation({
    required this.userLifestyleType,
    required this.recommendedActivities,
  });

  factory HomeRecommendation.fromJson(Map<String, dynamic> json) {
    return HomeRecommendation(
      userLifestyleType: json['user_lifestyle_type'],
      recommendedActivities: (json['recommended_activities'] as List)
          .map((e) => RecommendedActivity.fromJson(e))
          .toList(),
    );
  }
}

class RecommendedActivity {
  final String groupId;
  final String groupName;
  final String category;
  final String leaderId;

  RecommendedActivity({
    required this.groupId,
    required this.groupName,
    required this.category,
    required this.leaderId,
  });

  factory RecommendedActivity.fromJson(Map<String, dynamic> json) {
    return RecommendedActivity(
      groupId: json['group_id'],
      groupName: json['group_name'],
      category: json['category'],
      leaderId: json['leader_id'] ?? '',
    );
  }
}
