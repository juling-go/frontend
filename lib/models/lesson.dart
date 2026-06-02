class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'isCompleted': isCompleted,
    };
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}