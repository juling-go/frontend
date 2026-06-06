import '../models/curriculum.dart';
import '../mock/curriculum_mock_data.dart';

/// 커리큘럼 목록을 제공하는 서비스 인터페이스.
/// API 연동 시 [ApiCurriculumService]를 구현하여 교체하세요.
abstract class CurriculumService {
  Future<List<Curriculum>> fetchCurriculums();
}

/// 목 서비스 — 백엔드 연동 전까지 사용합니다.
class MockCurriculumService implements CurriculumService {
  const MockCurriculumService();

  @override
  Future<List<Curriculum>> fetchCurriculums() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockCurriculums;
  }
}

/// API 연동 시 이 클래스를 완성하고 [MockCurriculumService] 대신 주입하세요.
///
// class ApiCurriculumService implements CurriculumService {
//   const ApiCurriculumService({required this.baseUrl});
//   final String baseUrl;
//
//   @override
//   Future<List<Curriculum>> fetchCurriculums() async {
//     final response = await http.get(Uri.parse('$baseUrl/v1/curriculums'));
//     if (response.statusCode != 200) throw Exception('Failed to load curriculums');
//     final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
//     return json.map((e) => Curriculum.fromJson(e as Map<String, dynamic>)).toList();
//   }
// }
