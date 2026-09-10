/// 스테이지 통과에 필요한 최소 정답률.
const double kStagePassRatio = 0.6;

/// 스테이지 문제 풀이 결과.
class StageResult {
  /// 전체 문항 수.
  final int total;

  /// 맞힌 문항 수.
  final int correct;

  const StageResult({required this.total, required this.correct});

  /// 정답률 (0.0 ~ 1.0). 문항이 없으면 0.
  double get ratio => total == 0 ? 0 : correct / total;

  /// 백분율 정답률 (반올림).
  int get percent => (ratio * 100).round();

  /// [kStagePassRatio] 이상을 맞혀야 스테이지가 완료 처리됩니다.
  bool get passed => total > 0 && ratio >= kStagePassRatio;

  @override
  String toString() => 'StageResult($correct/$total, ${percent}%)';
}
