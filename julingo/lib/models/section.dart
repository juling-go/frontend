import 'stage.dart';

class Section {
  final String subject;
  final String chapter;
  final String sectionName;
  final String description;
  final List<Stage> stages;

  Section({
    required this.subject,
    required this.chapter,
    required this.sectionName,
    required this.description,
    required this.stages,
  });
}
