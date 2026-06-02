class Stage {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;

  Stage({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}
