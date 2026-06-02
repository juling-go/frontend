import 'package:flutter/material.dart';
import '../models/stage.dart';

class ProblemScreen extends StatelessWidget {
  final Stage stage;

  const ProblemScreen({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stage.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              stage.subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            const Text(
              '이 스테이지에 대한 문제 뷰입니다. 실제 문제와 풀이가 여기에 표시됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('문제 풀이 페이지로 이동하는 기능 (Mock)')),
                  );
                },
                child: const Text('문제 풀기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
