import 'package:flutter_test/flutter_test.dart';
import 'package:julingo/models/curriculum.dart';
import 'package:julingo/models/stage.dart';
import 'package:julingo/state/progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 노드 하나에 스테이지 [stagesPerNode]개를 가진 커리큘럼 픽스처.
Curriculum _curriculum(String id, {int nodes = 1, int stagesPerNode = 2}) {
  return Curriculum(
    id: id,
    name: '커리큘럼 $id',
    description: '설명',
    nodes: List.generate(
      nodes,
      (n) => CurriculumNode(
        id: '$id-n$n',
        title: '노드 $n',
        description: '설명',
        subject: '경제',
        chapter: '거시경제',
        level: n,
        prereqIds: const [],
        stages: List.generate(
          stagesPerNode,
          (s) => Stage(
            id: '$id-n$n-s$s',
            title: '스테이지 $s',
            subtitle: '부제',
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('커리큘럼을 바꿔도 기존 커리큘럼의 진행률이 남아 있다', () async {
    final repo = ProgressRepository(prefs);

    await repo.setActiveCurriculum('a');
    await repo.markStageCompleted('a', 'a-n0-s0');

    // 다른 커리큘럼으로 전환
    await repo.setActiveCurriculum('b');
    await repo.markStageCompleted('b', 'b-n0-s0');

    expect(repo.completedStageIds('a'), {'a-n0-s0'});
    expect(repo.completedStageIds('b'), {'b-n0-s0'});
    expect(repo.activeCurriculumId, 'b');

    // 다시 돌아와도 그대로여야 한다
    await repo.setActiveCurriculum('a');
    expect(repo.completedStageIds('a'), {'a-n0-s0'});
  });

  test('노드의 모든 스테이지를 완료해야 완료 노드로 집계된다', () async {
    final repo = ProgressRepository(prefs);
    final curriculum = _curriculum('a', stagesPerNode: 2);

    await repo.markStageCompleted('a', 'a-n0-s0');
    expect(repo.completedNodeIds(curriculum), isEmpty);

    await repo.markStageCompleted('a', 'a-n0-s1');
    expect(repo.completedNodeIds(curriculum), {'a-n0'});
  });

  test('여러 커리큘럼의 완료 수를 합산한다', () async {
    final repo = ProgressRepository(prefs);
    final a = _curriculum('a', stagesPerNode: 2);
    final b = _curriculum('b', stagesPerNode: 2);

    await repo.markStageCompleted('a', 'a-n0-s0');
    await repo.markStageCompleted('a', 'a-n0-s1');
    await repo.markStageCompleted('b', 'b-n0-s0');

    expect(repo.totalCompletedStages, 3);
    expect(repo.totalCompletedNodes([a, b]), 1);
  });

  test('진행률은 앱을 다시 켜도 복원된다', () async {
    final first = ProgressRepository(prefs);
    await first.setActiveCurriculum('a');
    await first.markStageCompleted('a', 'a-n0-s0');

    // 같은 저장소에서 새 인스턴스를 만드는 것으로 재시작을 흉내 냅니다.
    final restored = ProgressRepository(prefs);
    expect(restored.completedStageIds('a'), {'a-n0-s0'});
    expect(restored.activeCurriculumId, 'a');
  });

  test('clearAll은 진행률과 진행 중 커리큘럼을 모두 비운다', () async {
    final repo = ProgressRepository(prefs);
    await repo.setActiveCurriculum('a');
    await repo.markStageCompleted('a', 'a-n0-s0');

    await repo.clearAll();

    expect(repo.totalCompletedStages, 0);
    expect(repo.activeCurriculumId, isNull);
    expect(ProgressRepository(prefs).totalCompletedStages, 0);
  });

  test('같은 스테이지를 두 번 완료해도 중복 집계되지 않는다', () async {
    final repo = ProgressRepository(prefs);
    await repo.markStageCompleted('a', 'a-n0-s0');
    await repo.markStageCompleted('a', 'a-n0-s0');
    expect(repo.totalCompletedStages, 1);
  });

  test('완료 스테이지 집합은 외부에서 수정할 수 없다', () async {
    final repo = ProgressRepository(prefs);
    await repo.markStageCompleted('a', 'a-n0-s0');
    expect(
      () => repo.completedStageIds('a').add('침입'),
      throwsUnsupportedError,
    );
  });

  test('변경이 있을 때만 리스너에게 알린다', () async {
    final repo = ProgressRepository(prefs);
    var notifications = 0;
    repo.addListener(() => notifications++);

    await repo.markStageCompleted('a', 'a-n0-s0');
    expect(notifications, 1);

    // 이미 완료한 스테이지 → 알림 없음
    await repo.markStageCompleted('a', 'a-n0-s0');
    expect(notifications, 1);
  });
}
