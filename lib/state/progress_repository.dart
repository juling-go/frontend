import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/curriculum.dart';

/// 학습 진행률을 커리큘럼 단위로 보관하고 기기에 영속화합니다.
///
/// 진행률은 커리큘럼별로 분리되어 있으므로 커리큘럼을 바꿔도
/// 기존 기록이 사라지지 않습니다.
class ProgressRepository extends ChangeNotifier {
  static const _completedKey = 'progress.completedStages.v1';
  static const _activeKey = 'progress.activeCurriculumId.v1';

  final SharedPreferences _prefs;

  /// key: curriculumId, value: 완료한 stageId 집합
  final Map<String, Set<String>> _completed = {};
  String? _activeCurriculumId;

  ProgressRepository(this._prefs) {
    _restore();
  }

  // ── 조회 ─────────────────────────────────────────────────────

  String? get activeCurriculumId => _activeCurriculumId;

  /// 해당 커리큘럼에서 완료한 스테이지 id 집합 (읽기 전용).
  Set<String> completedStageIds(String curriculumId) {
    return UnmodifiableSetView(_completed[curriculumId] ?? const <String>{});
  }

  bool isStageCompleted(String curriculumId, String stageId) {
    return _completed[curriculumId]?.contains(stageId) ?? false;
  }

  /// 모든 스테이지가 완료된 노드(=섹션)의 id 집합.
  Set<String> completedNodeIds(Curriculum curriculum) {
    final done = _completed[curriculum.id];
    if (done == null || done.isEmpty) return const <String>{};
    return curriculum.nodes
        .where((n) =>
            n.stages.isNotEmpty && n.stages.every((s) => done.contains(s.id)))
        .map((n) => n.id)
        .toSet();
  }

  /// 전체 커리큘럼을 통틀어 완료한 스테이지 수.
  int get totalCompletedStages =>
      _completed.values.fold(0, (sum, set) => sum + set.length);

  /// 전체 커리큘럼을 통틀어 완료한 섹션(노드) 수.
  int totalCompletedNodes(List<Curriculum> curriculums) {
    return curriculums.fold(
      0,
      (sum, c) => sum + completedNodeIds(c).length,
    );
  }

  // ── 변경 ─────────────────────────────────────────────────────

  /// 진행 중인 커리큘럼을 지정합니다. 기존 진행률은 유지됩니다.
  Future<void> setActiveCurriculum(String curriculumId) async {
    if (_activeCurriculumId == curriculumId) return;
    _activeCurriculumId = curriculumId;
    notifyListeners();
    await _prefs.setString(_activeKey, curriculumId);
  }

  Future<void> markStageCompleted(String curriculumId, String stageId) async {
    final set = _completed.putIfAbsent(curriculumId, () => <String>{});
    if (!set.add(stageId)) return;
    notifyListeners();
    await _persistCompleted();
  }

  /// 로그아웃·회원탈퇴 시 모든 진행률을 삭제합니다.
  Future<void> clearAll() async {
    _completed.clear();
    _activeCurriculumId = null;
    notifyListeners();
    await _prefs.remove(_completedKey);
    await _prefs.remove(_activeKey);
  }

  // ── 영속화 ───────────────────────────────────────────────────

  void _restore() {
    _activeCurriculumId = _prefs.getString(_activeKey);

    final raw = _prefs.getString(_completedKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((curriculumId, stageIds) {
        _completed[curriculumId] = (stageIds as List<dynamic>)
            .map((e) => e as String)
            .toSet();
      });
    } catch (_) {
      // 저장 형식이 깨진 경우 진행률만 버리고 앱은 계속 동작시킵니다.
      _completed.clear();
    }
  }

  Future<void> _persistCompleted() {
    final encoded = jsonEncode(
      _completed.map((k, v) => MapEntry(k, v.toList())),
    );
    return _prefs.setString(_completedKey, encoded);
  }
}
