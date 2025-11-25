class GroupModel {
  final String id;
  final String groupName; // group_name
  final String? description;
  final String? category;
  final int maxMember; // max_member
  final String? groupImage; // group_image
  final String? createdAt; // created_at (ISO 포맷 문자열)
  final String? chatId; // chat_id
  final String leaderId;

  // 🔥 백엔드 서비스 코드에서 Firestore 문서를 읽을 때 'current_member' 필드를 사용함.
  // 이 필드는 GroupRead 스키마에 직접 없지만, 문서에 포함되어 있으므로 추가합니다.
  final int currentMember;

  // 🔥 GroupDetailResponse 스키마에 있는 필드 (만약 상세 조회 API가 GroupDetailResponse를 쓴다면 필요)
  // 현재 라우터는 GroupRead를 반환하므로, 필요하다면 API 응답을 GroupRead로 단순화하거나,
  // 그룹 서비스에서 추가 정보를 합쳐서 보내도록 백엔드를 수정해야 합니다.
  // 여기서는 GroupRead 기준으로 진행하되, currentMember를 추가합니다.

  GroupModel({
    required this.id,
    required this.groupName,
    this.description,
    this.category,
    this.maxMember = 10,
    this.groupImage,
    this.createdAt,
    this.chatId,
    required this.currentMember, // Firestore 문서에서 읽어옴
    required this.leaderId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json, String id) {
    return GroupModel(
      id: id,
      groupName: json['group_name'] ?? '이름 없음',
      description: json['description'],
      category: json['category'],
      maxMember: json['max_member'] ?? 10,
      groupImage: json['group_image'],
      createdAt: json['created_at'],
      chatId: json['chat_id'],
      currentMember: json['current_member'] ?? 0, // Firestore 문서에 있는 필드
      leaderId: json['leader_id'] ?? '',
    );
  }
}