import '../models/section.dart';
import '../models/stage.dart';

class SectionService {
  Future<Section> getSection() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return Section(
      subject: '경제',
      chapter: '거시경제',
      sectionName: '금리',
      description: '금리와 다양한 거시경제 변수들 간의 관계에 대해 이해한다.',
      stages: [
        Stage(
          id: '1',
          title: '기본 개념',
          subtitle: '금리란 무엇인가요?',
          learningObjective: '금리의 정의와 기준금리·시장금리의 차이를 이해한다.',
          estimatedMinutes: 10,
          isCompleted: true,
        ),
        Stage(
          id: '2',
          title: '수요와 공급',
          subtitle: '금리 결정 요인을 살펴봅니다.',
          learningObjective: '자금 시장에서 금리가 결정되는 원리를 파악한다.',
          estimatedMinutes: 10,
          isCompleted: true,
        ),
        Stage(
          id: '3',
          title: '중앙은행 역할',
          subtitle: '금리 정책의 목적을 이해합니다.',
          learningObjective: '중앙은행의 통화 정책 수단과 목표를 설명한다.',
          estimatedMinutes: 10,
          isCompleted: true,
        ),
        Stage(
          id: '4',
          title: '물가와 금리',
          subtitle: '금리와 물가 상승 간 관계를 학습합니다.',
          learningObjective: '금리 변화가 물가에 미치는 메커니즘을 이해한다.',
          estimatedMinutes: 15,
          isCompleted: false,
        ),
        Stage(
          id: '5',
          title: '환율 영향',
          subtitle: '금리가 환율에 미치는 영향을 확인합니다.',
          learningObjective: '금리 변동과 환율 사이의 관계를 분석한다.',
          estimatedMinutes: 15,
          isCompleted: false,
        ),
        Stage(
          id: '6',
          title: '경기순환',
          subtitle: '금리와 경기순환의 상관관계를 분석합니다.',
          learningObjective: '경기 국면에 따른 금리 흐름을 예측한다.',
          estimatedMinutes: 15,
          isCompleted: false,
        ),
        Stage(
          id: '7',
          title: '정책 시나리오',
          subtitle: '금리 변동 시나리오를 예측합니다.',
          learningObjective: '다양한 경제 상황에서 금리 정책 방향을 추론한다.',
          estimatedMinutes: 20,
          isCompleted: false,
        ),
      ],
    );
  }
}
