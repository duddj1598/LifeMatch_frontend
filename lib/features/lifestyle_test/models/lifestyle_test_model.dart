// ⭐️ 백엔드 스키마와 1:1로 대응되는 Dart 모델들

// 1. QuestionOption (옵션)
class QuestionOption {
  final int optionId;
  final String text;

  QuestionOption({required this.optionId, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      optionId: json['option_id'],
      text: json['text'],
    );
  }
}

// 2. Question (질문)
class Question {
  final int questionId;
  final String questionText;
  final List<QuestionOption> options;

  Question({
    required this.questionId,
    required this.questionText,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List;
    List<QuestionOption> options =
    optionsList.map((i) => QuestionOption.fromJson(i)).toList();

    return Question(
      questionId: json['question_id'],
      questionText: json['question_text'],
      options: options,
    );
  }
}

// 3. QuestionParts (질문 파트 1~4)
class QuestionParts {
  final List<Question> part1;
  final List<Question> part2;
  final List<Question> part3;
  final List<Question> part4;

  QuestionParts({
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
  });

  factory QuestionParts.fromJson(Map<String, dynamic> json) {
    var p1 = (json['part1'] as List).map((i) => Question.fromJson(i)).toList();
    var p2 = (json['part2'] as List).map((i) => Question.fromJson(i)).toList();
    var p3 = (json['part3'] as List).map((i) => Question.fromJson(i)).toList();
    var p4 = (json['part4'] as List).map((i) => Question.fromJson(i)).toList();

    return QuestionParts(part1: p1, part2: p2, part3: p3, part4: p4);
  }

  // ⭐️ 8개의 질문을 하나의 리스트로 합쳐주는 헬퍼 함수
  List<Question> get allQuestions => [...part1, ...part2, ...part3, ...part4];
}

// 4. LifestyleTestResultDetail (최종 결과)
class LifestyleTestResultDetail {
  final String typeName;
  final String keywords;
  final String description;

  LifestyleTestResultDetail({
    required this.typeName,
    required this.keywords,
    required this.description,
  });

  factory LifestyleTestResultDetail.fromJson(Map<String, dynamic> json) {
    return LifestyleTestResultDetail(
      typeName: json['type_name'],
      keywords: json['keywords'],
      description: json['description'],
    );
  }
}