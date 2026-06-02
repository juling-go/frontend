import 'package:flutter/material.dart';
import '../services/lesson_service.dart';
import '../models/lesson.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final _lessonService = LessonService();
  List<Lesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final lessons = await _lessonService.getLessons();
      setState(() {
        _lessons = lessons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('학습 데이터를 불러오는데 실패했습니다')),
        );
      }
    }
  }

  Future<void> _completeLesson(String id) async {
    await _lessonService.markLessonCompleted(id);
    setState(() {
      _lessons = _lessons.map((lesson) {
        if (lesson.id == id) {
          return lesson.copyWith(isCompleted: true);
        }
        return lesson;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _lessons.length,
              itemBuilder: (context, index) {
                final lesson = _lessons[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(lesson.title),
                    subtitle: Text(lesson.description),
                    trailing: lesson.isCompleted
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => _showLessonDialog(lesson),
                            child: const Text('학습하기'),
                          ),
                  ),
                );
              },
            ),
    );
  }

  void _showLessonDialog(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson.title),
        content: Text(lesson.content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              _completeLesson(lesson.id);
              Navigator.of(context).pop();
            },
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
}