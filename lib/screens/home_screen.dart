import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../models/section.dart';
import '../models/stage.dart';
import '../services/section_service.dart';
import 'content_screen.dart';
import 'curriculum_screen.dart';
import 'level_assessment_screen.dart';
import 'profile_screen.dart';
import 'stage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── 탭 상태 ─────────────────────────────────────────────────
  int _selectedTabIndex = 0;

  // ── 커리큘럼 상태 ─────────────────────────────────────────────
  Curriculum? _activeCurriculum;
  Set<String> _completedStageIds = {};

  // 완료된 노드: 해당 노드의 모든 스테이지가 완료된 경우
  Set<String> get _completedNodeIds {
    if (_activeCurriculum == null) return {};
    return _activeCurriculum!.nodes
        .where((n) => n.stages.every((s) => _completedStageIds.contains(s.id)))
        .map((n) => n.id)
        .toSet();
  }

  // 현재 진행할 노드: 잠금 해제됐지만 완료되지 않은 첫 번째 노드
  CurriculumNode? get _currentNode {
    if (_activeCurriculum == null) return null;
    final completed = _completedNodeIds;
    for (final node in _activeCurriculum!.nodes) {
      final isUnlocked =
          node.prereqIds.isEmpty || node.prereqIds.every(completed.contains);
      if (isUnlocked && !completed.contains(node.id)) return node;
    }
    return _activeCurriculum!.nodes.last;
  }

  // 현재 노드에서 진행할 스테이지 인덱스
  int get _currentStageIndex {
    final node = _currentNode;
    if (node == null) return 0;
    final idx =
        node.stages.indexWhere((s) => !_completedStageIds.contains(s.id));
    return idx < 0 ? node.stages.length - 1 : idx;
  }

  // ── 폴백 섹션 (커리큘럼 미선택 시) ───────────────────────────
  final _sectionService = SectionService();
  Section? _fallbackSection;
  bool _fallbackLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFallbackSection();
  }

  Future<void> _loadFallbackSection() async {
    try {
      final s = await _sectionService.getSection();
      setState(() {
        _fallbackSection = s;
        _fallbackLoading = false;
      });
    } catch (_) {
      setState(() => _fallbackLoading = false);
    }
  }

  // ── 콜백 ─────────────────────────────────────────────────────
  void _onCurriculumSelected(Curriculum c) {
    setState(() {
      _activeCurriculum = c;
      _completedStageIds = {};
    });
  }

  void _onTabSelected(int index) => setState(() => _selectedTabIndex = index);

  Future<void> _onStageTap(Stage stage, String nodeId) async {
    await _showStagePopup(stage, nodeId);
  }

  Future<void> _showStagePopup(Stage stage, String nodeId) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(stage.subtitle,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text('예상 시간: ${stage.estimatedMinutes}분',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
                ],
              ),
              if (stage.learningObjective.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text('학습 목표',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(stage.learningObjective,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4)),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final completed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => StageScreen(stage: stage),
                        ),
                      );
                      if (completed == true && mounted) {
                        setState(() {
                          _completedStageIds.add(stage.id);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('시작하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 빌드 ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeView(),
      CurriculumScreen(
        activeCurriculum: _activeCurriculum,
        completedNodeIds: _completedNodeIds,
        onCurriculumSelected: _onCurriculumSelected,
      ),
      const ContentScreen(),
      const LevelAssessmentScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_selectedTabIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: Colors.grey.shade300),
          BottomNavigationBar(
            currentIndex: _selectedTabIndex,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                activeIcon: Icon(Icons.library_books),
                label: '커리큘럼',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: '컨텐츠',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assessment_outlined),
                activeIcon: Icon(Icons.assessment),
                label: '수준평가',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '프로필',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 홈 탭 전체 뷰 ────────────────────────────────────────────

  Widget _buildHomeView() {
    return Column(
      children: [
        // 커리큘럼 배너 (진행 중일 때만 표시)
        if (_activeCurriculum != null) _buildCurriculumBanner(),
        // 섹션 정보 + 스테이지 목록
        Expanded(child: _buildSectionBody()),
      ],
    );
  }

  Widget _buildCurriculumBanner() {
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = 1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.blue.shade600,
        child: Row(
          children: [
            const Icon(Icons.school_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _activeCurriculum!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionBody() {
    // 커리큘럼 진행 중
    if (_activeCurriculum != null) {
      final node = _currentNode;
      if (node == null) {
        return const Center(child: Text('모든 섹션을 완료했습니다! 🎉'));
      }
      return _buildSectionFromNode(node);
    }

    // 폴백 (커리큘럼 미선택)
    if (_fallbackLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_fallbackSection == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('커리큘럼을 선택하면 학습을 시작할 수 있습니다.',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _selectedTabIndex = 1),
              child: const Text('커리큘럼 선택하기'),
            ),
          ],
        ),
      );
    }
    return _buildSectionFromFallback(_fallbackSection!);
  }

  // ── 커리큘럼 기반 섹션 뷰 ─────────────────────────────────────

  Widget _buildSectionFromNode(CurriculumNode node) {
    final currentIdx = _currentStageIndex;
    return Column(
      children: [
        _buildSectionInfoCard(
          subject: node.subject,
          chapter: node.chapter,
          sectionName: node.title,
          description: node.description,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: node.stages.length,
            itemBuilder: (context, index) {
              final stage = node.stages[index];
              final isCompleted = _completedStageIds.contains(stage.id);
              final isCurrent = !isCompleted && index == currentIdx;
              final isLocked = !isCompleted && index > currentIdx;
              return _buildStageCard(
                stage: stage,
                index: index,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLocked: isLocked,
                onTap: isLocked
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('이전 스테이지를 먼저 완료하세요.')),
                        )
                    : () => _onStageTap(stage, node.id),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 폴백 섹션 뷰 ─────────────────────────────────────────────

  Widget _buildSectionFromFallback(Section section) {
    final currentIdx =
        section.stages.indexWhere((s) => !s.isCompleted);
    final effectiveCurrent =
        currentIdx < 0 ? section.stages.length - 1 : currentIdx;

    return Column(
      children: [
        _buildSectionInfoCard(
          subject: section.subject,
          chapter: section.chapter,
          sectionName: section.sectionName,
          description: section.description,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: section.stages.length,
            itemBuilder: (context, index) {
              final stage = section.stages[index];
              return _buildStageCard(
                stage: stage,
                index: index,
                isCompleted: stage.isCompleted,
                isCurrent: index == effectiveCurrent && !stage.isCompleted,
                isLocked: index > effectiveCurrent,
                onTap: index > effectiveCurrent
                    ? () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('이전 스테이지를 먼저 완료하세요.')),
                        )
                    : () => _onStageTap(stage, ''),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 공통 위젯 ────────────────────────────────────────────────

  Widget _buildSectionInfoCard({
    required String subject,
    required String chapter,
    required String sectionName,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$subject  >  $chapter',
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 6),
          Text(
            sectionName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
                fontSize: 13, color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard({
    required Stage stage,
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    final Color dotColor = isCompleted
        ? Colors.green
        : isCurrent
            ? Colors.blue
            : Colors.grey.shade300;

    final Color borderColor = isCompleted
        ? Colors.green.shade100
        : isCurrent
            ? Colors.blue.shade100
            : Colors.grey.shade200;

    final Color bgColor = isLocked ? Colors.grey.shade50 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isLocked
              ? null
              : const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // 상태 원형 표시
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 20)
                    : isLocked
                        ? Icon(Icons.lock_outline,
                            color: Colors.grey.shade400, size: 18)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? Colors.black38 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stage.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Colors.black26 : Colors.black45,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isLocked) ...[
              const SizedBox(width: 8),
              Icon(
                isCompleted ? Icons.replay_outlined : Icons.play_circle_outline,
                color: isCompleted
                    ? Colors.green.shade400
                    : Colors.blue.shade400,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
