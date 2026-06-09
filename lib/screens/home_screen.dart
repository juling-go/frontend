import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../models/section.dart';
import '../models/stage.dart';
import '../services/section_service.dart';
import '../theme/app_decorations.dart';
import '../theme/app_transitions.dart';
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF282828), Color(0xFF181818)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(color: Color(0xFF3D3D3D), blurRadius: 4, offset: Offset(-2, -2)),
              BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 20, offset: const Offset(6, 10)),
            ],
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
                      fontSize: 14, color: Color(0xFF9E9E9E))),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 16, color: Color(0xFF686868)),
                  const SizedBox(width: 6),
                  Text('예상 시간: ${stage.estimatedMinutes}분',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9E9E9E))),
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
                        color: Color(0xFF9E9E9E),
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
                      final completed = await pushWithLoadingOverlay<bool>(
                        context: context,
                        destination: StageScreen(stage: stage),
                        title: stage.title,
                        subtitle: stage.subtitle,
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
        onNavigateToHome: () => setState(() => _selectedTabIndex = 0),
      ),
      const ContentScreen(),
      const LevelAssessmentScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: kTabTransitionDuration,
        transitionBuilder: tabTransitionBuilder,
        child: KeyedSubtree(
          key: ValueKey(_selectedTabIndex),
          child: pages[_selectedTabIndex],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1, color: const Color(0xFF2E2E2E)),
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
        Expanded(child: _buildSectionBody()),
      ],
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
                style: TextStyle(color: Color(0xFF9E9E9E))),
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
        _buildCurriculumSectionHeader(node),
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

  Widget _buildCurriculumSectionHeader(CurriculumNode node) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = 1),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: card3D(radius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: Colors.blue, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _activeCurriculum!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF686868), size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF232323), Color(0xFF141414)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF383838)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${node.subject}  >  ${node.chapter}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    node.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.description,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF9E9E9E), height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionInfoCard({
    required String subject,
    required String chapter,
    required String sectionName,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: card3D(radius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$subject  >  $chapter',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
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
                fontSize: 13, color: Color(0xFF9E9E9E), height: 1.4),
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
    final Color borderColor = isCompleted
        ? Colors.green.shade900
        : isCurrent
            ? Colors.blue.shade900
            : const Color(0xFF2E2E2E);

    final List<Color> bgGradient = isLocked
        ? [const Color(0xFF1C1C1C), const Color(0xFF111111)]
        : isCompleted
            ? [const Color(0xFF1A2A1A), const Color(0xFF101810)]
            : isCurrent
                ? [const Color(0xFF1A1F2A), const Color(0xFF10141A)]
                : [const Color(0xFF252525), const Color(0xFF161616)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradient,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isLocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0xFF3A3A3A),
                    blurRadius: 3,
                    offset: Offset(-1, -1),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 10,
                    offset: const Offset(4, 5),
                  ),
                ],
        ),
        child: Row(
          children: [
            // 동전 모양 상태 표시
            _buildCoinWidget(
              index: index,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stage',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? Color(0xFF565656)
                          : isCompleted
                              ? Colors.green.shade600
                              : Colors.blue.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stage.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLocked ? Color(0xFF707070) : Color(0xFFEEEEEE),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stage.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Color(0xFF565656) : Color(0xFF8A8A8A),
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

  Widget _buildCoinWidget({
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    final Color faceColor = isCompleted
        ? Colors.green
        : isCurrent
            ? Colors.blue
            : const Color(0xFF3A3A3A);

    final Color rimColor = isCompleted
        ? Colors.green.shade700
        : isCurrent
            ? Colors.blue.shade700
            : const Color(0xFF505050);

    final Color shadowColor = isCompleted
        ? Colors.green.shade900
        : isCurrent
            ? Colors.blue.shade900
            : const Color(0xFF282828);

    final Widget face = isCompleted
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
        : isLocked
            ? const Icon(Icons.lock_outline, color: Color(0xFF686868), size: 16)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shadowColor,
        // 하단 그림자로 동전의 두께감 표현
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: faceColor,
            border: Border.all(color: rimColor, width: 2),
          ),
          child: Center(child: face),
        ),
      ),
    );
  }
}
