import '../models/content.dart';
import '../mock/content_mock_data.dart';

/// 컨텐츠 데이터를 제공하는 서비스 인터페이스.
/// API 연동 시 [ApiContentService]를 구현하여 교체하세요.
abstract class ContentService {
  Future<List<ContentSubject>> fetchSubjects();
}

/// 목 서비스 — 백엔드 연동 전까지 사용합니다.
/// API 준비 후 [ApiContentService]로 교체하고 이 클래스를 제거하세요.
class MockContentService implements ContentService {
  const MockContentService();

  @override
  Future<List<ContentSubject>> fetchSubjects() async {
    // 실제 네트워크 지연을 흉내 냅니다.
    await Future.delayed(const Duration(milliseconds: 300));
    return mockContentSubjects;
  }
}

/// API 연동 시 이 클래스를 완성하고 [MockContentService] 대신 주입하세요.
///
/// 사용 예시:
///   ContentScreen(service: ApiContentService(baseUrl: 'https://api.example.com'))
///
// class ApiContentService implements ContentService {
//   const ApiContentService({required this.baseUrl});
//   final String baseUrl;
//
//   @override
//   Future<List<ContentSubject>> fetchSubjects() async {
//     final response = await http.get(Uri.parse('$baseUrl/v1/subjects'));
//     if (response.statusCode != 200) throw Exception('Failed to load subjects');
//     final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
//     return json
//         .map((e) => ContentSubject.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }
// }
