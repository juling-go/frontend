class ContentStage {
  final String title;

  const ContentStage({required this.title});

  factory ContentStage.fromJson(Map<String, dynamic> json) {
    return ContentStage(title: json['title'] as String);
  }
}

class ContentSection {
  final String title;
  final String description;
  final List<ContentStage> stages;

  const ContentSection({
    required this.title,
    required this.description,
    required this.stages,
  });

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      title: json['title'] as String,
      description: json['description'] as String,
      stages: (json['stages'] as List<dynamic>)
          .map((e) => ContentStage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContentChapter {
  final String title;
  final String description;
  final List<ContentSection> sections;

  const ContentChapter({
    required this.title,
    required this.description,
    required this.sections,
  });

  factory ContentChapter.fromJson(Map<String, dynamic> json) {
    return ContentChapter(
      title: json['title'] as String,
      description: json['description'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ContentSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ContentSubject {
  final String name;
  final List<ContentChapter> chapters;

  const ContentSubject({
    required this.name,
    required this.chapters,
  });

  factory ContentSubject.fromJson(Map<String, dynamic> json) {
    return ContentSubject(
      name: json['name'] as String,
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => ContentChapter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
