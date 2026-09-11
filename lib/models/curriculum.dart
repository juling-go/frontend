import 'stage.dart';

class CurriculumNode {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String chapter;
  final int level;
  final List<String> prereqIds;
  final List<Stage> stages;

  const CurriculumNode({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.chapter,
    required this.level,
    required this.prereqIds,
    required this.stages,
  });
}

class Curriculum {
  final String id;
  final String name;
  final String description;
  final List<CurriculumNode> nodes;

  const Curriculum({
    required this.id,
    required this.name,
    required this.description,
    required this.nodes,
  });
}
