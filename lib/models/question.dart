enum QuestionType { singleChoice, multipleChoice, ox }

class Choice {
  final String id;
  final String text;
  const Choice({required this.id, required this.text});
}

class Question {
  final String id;
  final QuestionType type;
  final String content;
  final List<Choice> choices; // OX 타입은 빈 리스트
  final List<String> correctIds; // OX는 ['O'] 또는 ['X']
  final String? hint;

  const Question({
    required this.id,
    required this.type,
    required this.content,
    this.choices = const [],
    required this.correctIds,
    this.hint,
  });
}
