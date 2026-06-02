import '../models/lesson.dart';

class LessonService {
  // Mock lesson data
  Future<List<Lesson>> getLessons() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Lesson(
        id: '1',
        title: '주식의 기초',
        description: '주식의 기본 개념과 용어들을 배워보세요.',
        content: '주식은 회사의 소유권을 나타내는 증서입니다. 투자자는 주식을 구매함으로써 회사의 일부를 소유하게 됩니다.',
        isCompleted: false,
      ),
      Lesson(
        id: '2',
        title: '기술적 분석',
        description: '차트와 지표를 활용한 분석 방법을 학습합니다.',
        content: '기술적 분석은 과거 가격과 거래량 데이터를 분석하여 미래 가격 변동을 예측하는 방법입니다.',
        isCompleted: false,
      ),
      Lesson(
        id: '3',
        title: '펀더멘털 분석',
        description: '기업의 재무제표와 경제 지표를 분석하는 방법을 배웁니다.',
        content: '펀더멘털 분석은 기업의 재무 상태, 경영 성과, 산업 동향 등을 분석하여 주식의 내재 가치를 평가하는 방법입니다.',
        isCompleted: false,
      ),
    ];
  }

  Future<Lesson?> getLesson(String id) async {
    final lessons = await getLessons();
    return lessons.firstWhere((lesson) => lesson.id == id);
  }

  Future<void> markLessonCompleted(String id) async {
    // In a real app, this would update the backend
    await Future.delayed(const Duration(milliseconds: 500));
  }
}