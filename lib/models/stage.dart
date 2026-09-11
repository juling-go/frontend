import 'question.dart';

class Stage {
  final String id;
  final String title;
  final String subtitle;
  final String learningObjective;
  final int estimatedMinutes;
  final bool isCompleted;
  final List<Question> questions;

  const Stage({
    required this.id,
    required this.title,
    required this.subtitle,
    this.learningObjective = '',
    this.estimatedMinutes = 10,
    this.isCompleted = false,
    this.questions = const [],
  });
}
