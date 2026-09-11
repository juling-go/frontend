import 'package:flutter_test/flutter_test.dart';
import 'package:julingo/models/stage_result.dart';

void main() {
  test('정답률과 백분율을 계산한다', () {
    const result = StageResult(total: 4, correct: 3);
    expect(result.ratio, 0.75);
    expect(result.percent, 75);
  });

  test('합격선 이상이면 통과한다', () {
    // kStagePassRatio = 0.6
    expect(const StageResult(total: 5, correct: 3).passed, isTrue); // 60%
    expect(const StageResult(total: 5, correct: 5).passed, isTrue);
  });

  test('합격선 미만이면 통과하지 못한다', () {
    expect(const StageResult(total: 5, correct: 2).passed, isFalse); // 40%
    expect(const StageResult(total: 5, correct: 0).passed, isFalse);
  });

  test('문항이 없으면 통과 처리하지 않는다', () {
    const empty = StageResult(total: 0, correct: 0);
    expect(empty.ratio, 0);
    expect(empty.passed, isFalse);
  });
}
