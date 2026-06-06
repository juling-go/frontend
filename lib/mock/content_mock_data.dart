// TODO: 임시 목 데이터입니다. 백엔드 API 연동 후 이 파일과 MockContentService를 제거하세요.

import '../models/content.dart';

const List<ContentSubject> mockContentSubjects = [
  ContentSubject(
    name: '경제',
    chapters: [
      ContentChapter(
        title: '거시경제',
        description: '경제 전체를 보는 거시적 관점에서 주요 경제 변수를 학습합니다.',
        sections: [
          ContentSection(
            title: '금리',
            description: '금리의 개념과 경제 전반에 미치는 영향을 이해합니다.',
            stages: [
              ContentStage(title: '금리란 무엇인가'),
              ContentStage(title: '금리 결정 요인'),
              ContentStage(title: '중앙은행의 역할'),
              ContentStage(title: '금리와 물가의 관계'),
              ContentStage(title: '금리와 환율의 관계'),
            ],
          ),
          ContentSection(
            title: '환율',
            description: '환율의 개념과 국제 경제에서의 역할을 학습합니다.',
            stages: [
              ContentStage(title: '환율이란 무엇인가'),
              ContentStage(title: '환율 결정 요인'),
              ContentStage(title: '환율과 무역의 관계'),
              ContentStage(title: '환율 변동의 영향'),
            ],
          ),
          ContentSection(
            title: '물가와 인플레이션',
            description: '물가 지수와 인플레이션의 원인 및 영향을 분석합니다.',
            stages: [
              ContentStage(title: '물가 지수의 종류'),
              ContentStage(title: '인플레이션 원인'),
              ContentStage(title: '디플레이션이란'),
              ContentStage(title: '스태그플레이션'),
            ],
          ),
        ],
      ),
      ContentChapter(
        title: '미시경제',
        description: '개별 경제 주체의 행동과 시장 원리를 분석합니다.',
        sections: [
          ContentSection(
            title: '수요와 공급',
            description: '시장에서 가격과 수량을 결정하는 수요·공급 원리를 학습합니다.',
            stages: [
              ContentStage(title: '수요 곡선의 이해'),
              ContentStage(title: '공급 곡선의 이해'),
              ContentStage(title: '시장 균형'),
              ContentStage(title: '탄력성의 개념'),
            ],
          ),
          ContentSection(
            title: '시장 구조',
            description: '다양한 시장 형태와 경쟁 원리를 이해합니다.',
            stages: [
              ContentStage(title: '완전경쟁 시장'),
              ContentStage(title: '독점 시장'),
              ContentStage(title: '과점 시장'),
              ContentStage(title: '독점적 경쟁'),
            ],
          ),
        ],
      ),
      ContentChapter(
        title: '경기순환',
        description: '경제의 호황과 불황이 반복되는 경기순환 패턴을 학습합니다.',
        sections: [
          ContentSection(
            title: '경기순환의 개념',
            description: '경기순환의 주기와 단계를 이해합니다.',
            stages: [
              ContentStage(title: '경기순환이란'),
              ContentStage(title: '확장기와 수축기'),
              ContentStage(title: '선행·동행·후행 지표'),
            ],
          ),
          ContentSection(
            title: '경기 예측',
            description: '다양한 지표를 활용하여 경기 흐름을 예측하는 방법을 학습합니다.',
            stages: [
              ContentStage(title: 'GDP와 경기'),
              ContentStage(title: '실업률과 경기'),
              ContentStage(title: '소비자 신뢰지수'),
              ContentStage(title: '투자와 경기'),
            ],
          ),
        ],
      ),
    ],
  ),
  ContentSubject(
    name: '주식 투자',
    chapters: [
      ContentChapter(
        title: '주식 기초',
        description: '주식의 개념과 주식 시장의 기본 구조를 학습합니다.',
        sections: [
          ContentSection(
            title: '주식이란',
            description: '주식의 정의와 주주로서의 권리를 이해합니다.',
            stages: [
              ContentStage(title: '주식의 정의'),
              ContentStage(title: '보통주와 우선주'),
              ContentStage(title: '주주의 권리'),
              ContentStage(title: '배당이란'),
            ],
          ),
          ContentSection(
            title: '주식 시장 참여자',
            description: '주식 시장에서 활동하는 다양한 참여자들을 파악합니다.',
            stages: [
              ContentStage(title: '개인 투자자'),
              ContentStage(title: '기관 투자자'),
              ContentStage(title: '외국인 투자자'),
              ContentStage(title: '증권사의 역할'),
            ],
          ),
        ],
      ),
      ContentChapter(
        title: '기술적 분석',
        description: '차트와 기술적 지표를 활용한 주가 분석 방법을 학습합니다.',
        sections: [
          ContentSection(
            title: '차트 기초',
            description: '주가 차트의 종류와 기본 패턴을 이해합니다.',
            stages: [
              ContentStage(title: '캔들스틱 차트'),
              ContentStage(title: '지지선과 저항선'),
              ContentStage(title: '추세선 그리기'),
              ContentStage(title: '거래량 분석'),
            ],
          ),
          ContentSection(
            title: '이동평균선',
            description: '이동평균선의 원리와 매매 신호 파악 방법을 학습합니다.',
            stages: [
              ContentStage(title: '이동평균선이란'),
              ContentStage(title: '단기 vs 장기 이평선'),
              ContentStage(title: '골든크로스와 데드크로스'),
              ContentStage(title: '이평선 활용 전략'),
            ],
          ),
          ContentSection(
            title: '보조 지표',
            description: 'RSI, MACD 등 주요 보조 지표를 활용합니다.',
            stages: [
              ContentStage(title: 'RSI 지표'),
              ContentStage(title: 'MACD 지표'),
              ContentStage(title: '볼린저 밴드'),
              ContentStage(title: '스토캐스틱'),
            ],
          ),
        ],
      ),
      ContentChapter(
        title: '기본적 분석',
        description: '기업의 재무 상태와 가치를 분석하는 방법을 학습합니다.',
        sections: [
          ContentSection(
            title: '재무제표 분석',
            description: '손익계산서, 대차대조표, 현금흐름표를 분석합니다.',
            stages: [
              ContentStage(title: '손익계산서 읽기'),
              ContentStage(title: '대차대조표 읽기'),
              ContentStage(title: '현금흐름표 읽기'),
              ContentStage(title: '주요 재무 비율'),
            ],
          ),
          ContentSection(
            title: '기업 가치 평가',
            description: '다양한 방법으로 기업의 적정 가치를 산출합니다.',
            stages: [
              ContentStage(title: 'PER (주가수익비율)'),
              ContentStage(title: 'PBR (주가순자산비율)'),
              ContentStage(title: 'ROE와 ROA'),
              ContentStage(title: 'DCF 분석'),
            ],
          ),
        ],
      ),
    ],
  ),
  ContentSubject(
    name: '투자 전략',
    chapters: [
      ContentChapter(
        title: '가치 투자',
        description: '저평가된 기업을 발굴하여 장기 투자하는 전략을 학습합니다.',
        sections: [
          ContentSection(
            title: '가치 투자 철학',
            description: '버핏·그레이엄 등 가치 투자의 핵심 원칙을 이해합니다.',
            stages: [
              ContentStage(title: '가치 투자란'),
              ContentStage(title: '안전 마진의 개념'),
              ContentStage(title: '워렌 버핏의 원칙'),
              ContentStage(title: '벤저민 그레이엄 전략'),
            ],
          ),
          ContentSection(
            title: '저평가 주식 발굴',
            description: '시장에서 저평가된 우량 주식을 찾는 방법을 배웁니다.',
            stages: [
              ContentStage(title: '스크리닝 기법'),
              ContentStage(title: '경제적 해자'),
              ContentStage(title: '배당 성장주'),
              ContentStage(title: '내재 가치 계산'),
            ],
          ),
        ],
      ),
      ContentChapter(
        title: '성장주 투자',
        description: '높은 성장 가능성을 가진 기업에 투자하는 전략을 학습합니다.',
        sections: [
          ContentSection(
            title: '성장주의 특징',
            description: '성장주를 정의하고 선별하는 기준을 이해합니다.',
            stages: [
              ContentStage(title: '성장주란'),
              ContentStage(title: 'PEG 비율 활용'),
              ContentStage(title: '매출 성장률 분석'),
              ContentStage(title: '섹터 트렌드'),
            ],
          ),
          ContentSection(
            title: '성장주 리스크 관리',
            description: '성장주 투자 시 발생할 수 있는 리스크를 관리합니다.',
            stages: [
              ContentStage(title: '고평가 리스크'),
              ContentStage(title: '금리 민감도'),
              ContentStage(title: '손절 원칙'),
            ],
          ),
        ],
      ),
      ContentChapter(
        title: '포트폴리오 관리',
        description: '분산 투자와 리스크 관리를 통한 포트폴리오 최적화를 학습합니다.',
        sections: [
          ContentSection(
            title: '분산 투자',
            description: '자산 배분을 통한 리스크 분산 전략을 이해합니다.',
            stages: [
              ContentStage(title: '분산 투자의 원리'),
              ContentStage(title: '상관계수의 이해'),
              ContentStage(title: '자산 배분 전략'),
              ContentStage(title: '리밸런싱'),
            ],
          ),
          ContentSection(
            title: '리스크 관리',
            description: '투자 리스크를 측정하고 관리하는 방법을 학습합니다.',
            stages: [
              ContentStage(title: '변동성의 이해'),
              ContentStage(title: '베타 계수'),
              ContentStage(title: '손절매 원칙'),
              ContentStage(title: '포지션 사이징'),
            ],
          ),
        ],
      ),
    ],
  ),
];
