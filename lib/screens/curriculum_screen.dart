import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../services/curriculum_service.dart';
import '../theme/app_decorations.dart';

const _kNodeRadius = 36.0;
const _kLevelHeight = 150.0;
const _kLabelExtra = 14.0;
const _kTopPad = 24.0;

/// 과목명에서 일관된 강조 색상을 반환합니다.
Color _subjectAccent(String subject) {
  const palette = [
    Color(0xFF64B5F6), // 파란 계열 — 주식
    Color(0xFF81C784), // 초록 계열 — 경제
    Color(0xFFFFB74D), // 앰버 계열 — 투자
    Color(0xFFBA68C8), // 보라 계열
    Color(0xFF4DD0E1), // 청록 계열
    Color(0xFFFF8A65), // 주황 계열
    Color(0xFFF06292), // 분홍 계열
    Color(0xFF9575CD), // 진보라 계열
  ];
  int hash = 0;
  for (final r in subject.runes) {
    hash = (hash * 31 + r) & 0x7FFFFFFF;
  }
  return palette[hash % palette.length];
}

class CurriculumScreen extends StatefulWidget {
  final Curriculum? activeCurriculum;
  final Set<String> completedNodeIds;
  final void Function(Curriculum) onCurriculumSelected;
  final VoidCallback? onNavigateToHome;
  final CurriculumService service;

  const CurriculumScreen({
    super.key,
    required this.activeCurriculum,
    required this.completedNodeIds,
    required this.onCurriculumSelected,
    this.onNavigateToHome,
    this.service = const MockCurriculumService(),
  });

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  List<Curriculum> _curriculums = [];
  bool _isLoading = true;
  Curriculum? _viewing;

  @override
  void initState() {
    super.initState();
    _viewing = widget.activeCurriculum;
    _loadCurriculums();
  }

  @override
  void didUpdateWidget(covariant CurriculumScreen old) {
    super.didUpdateWidget(old);
    if (widget.activeCurriculum != null &&
        old.activeCurriculum == null &&
        _viewing == null) {
      setState(() => _viewing = widget.activeCurriculum);
    }
  }

  Future<void> _loadCurriculums() async {
    try {
      final list = await widget.service.fetchCurriculums();
      setState(() {
        _curriculums = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _selectCurriculum(Curriculum c) {
    widget.onCurriculumSelected(c);
    setState(() => _viewing = c);
  }

  @override
  Widget build(BuildContext context) {
    if (_viewing != null) {
      return _CurriculumDetailView(
        curriculum: _viewing!,
        completedNodeIds: widget.completedNodeIds,
        isActive: widget.activeCurriculum?.id == _viewing!.id,
        onBack: () => setState(() => _viewing = null),
        onStart: () {
          _selectCurriculum(_viewing!);
          widget.onNavigateToHome?.call();
        },
        onNavigateToHome: widget.onNavigateToHome,
      );
    }
    return _buildSelectionView();
  }

  // ── 선택 뷰 ─────────────────────────────────────────────────

  Widget _buildSelectionView() {
    return Column(
      children: [
        _buildHeader(),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_curriculums.isEmpty)
          const Expanded(child: Center(child: Text('커리큘럼이 없습니다.')))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _curriculums.length,
              itemBuilder: (context, index) => _CurriculumCard(
                curriculum: _curriculums[index],
                isActive:
                    widget.activeCurriculum?.id == _curriculums[index].id,
                onTap: () =>
                    setState(() => _viewing = _curriculums[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232323), Color(0xFF161616)],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 12,
              offset: const Offset(0, 5)),
          const BoxShadow(
              color: Color(0xFF3A3A3A),
              blurRadius: 4,
              offset: Offset(-1, -1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('커리큘럼',
              style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            widget.activeCurriculum != null
                ? '진행 중: ${widget.activeCurriculum!.name}'
                : '학습할 커리큘럼을 선택하세요',
            style: TextStyle(
              fontSize: 13,
              color: widget.activeCurriculum != null
                  ? Colors.blue.shade400
                  : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 커리큘럼 카드 ──────────────────────────────────────────────

class _CurriculumCard extends StatelessWidget {
  final Curriculum curriculum;
  final bool isActive;
  final VoidCallback onTap;

  const _CurriculumCard({
    required this.curriculum,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: card3D(
          border: Border.all(
            color: isActive
                ? Colors.blue.shade500
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          curriculum.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.blue.shade700, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.blue.withValues(alpha: 0.25),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '진행 중',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade300,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    curriculum.description,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '섹션 ${curriculum.nodes.length}개',
                    style:
                        TextStyle(fontSize: 12, color: Colors.blue.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF686868)),
          ],
        ),
      ),
    );
  }
}

// ── 개별 커리큘럼 상세 뷰 ─────────────────────────────────────

class _CurriculumDetailView extends StatefulWidget {
  final Curriculum curriculum;
  final Set<String> completedNodeIds;
  final bool isActive;
  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback? onNavigateToHome;

  const _CurriculumDetailView({
    required this.curriculum,
    required this.completedNodeIds,
    required this.isActive,
    required this.onBack,
    required this.onStart,
    this.onNavigateToHome,
  });

  @override
  State<_CurriculumDetailView> createState() =>
      _CurriculumDetailViewState();
}

class _CurriculumDetailViewState extends State<_CurriculumDetailView> {
  bool _isDone(String id) => widget.completedNodeIds.contains(id);

  bool _isOpen(CurriculumNode node) =>
      node.prereqIds.isEmpty || node.prereqIds.every(_isDone);

  Map<String, Offset> _computePositions(double width) {
    final Map<int, List<CurriculumNode>> byLevel = {};
    for (final node in widget.curriculum.nodes) {
      byLevel.putIfAbsent(node.level, () => []).add(node);
    }
    final result = <String, Offset>{};
    byLevel.forEach((level, nodes) {
      final count = nodes.length;
      for (int i = 0; i < count; i++) {
        final x = width * (i + 1) / (count + 1);
        final y = _kTopPad + _kNodeRadius + level * _kLevelHeight;
        result[nodes[i].id] = Offset(x, y);
      }
    });
    return result;
  }

  void _onNodeTap(CurriculumNode node) {
    if (!_isOpen(node)) {
      final blockers = node.prereqIds
          .where((id) => !_isDone(id))
          .map((id) =>
              widget.curriculum.nodes.firstWhere((n) => n.id == id).title)
          .join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('먼저 완료해야 합니다: $blockers')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(node.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(node.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Text(
              '${node.subject} > ${node.chapter}',
              style:
                  const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
            ),
            const SizedBox(height: 10),
            Text(
              '스테이지 ${node.stages.length}개',
              style:
                  TextStyle(fontSize: 13, color: Colors.blue.shade400),
            ),
            if (node.prereqIds.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text('선수 조건',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              ...node.prereqIds.map((id) {
                final prereq = widget.curriculum.nodes
                    .firstWhere((n) => n.id == id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        _isDone(id)
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 16,
                        color: _isDone(id) ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(prereq.title,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDetailHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final nodes = widget.curriculum.nodes;
              final positions = _computePositions(constraints.maxWidth);
              final maxLevel = nodes
                  .map((n) => n.level)
                  .reduce((a, b) => a > b ? a : b);
              final totalHeight = _kTopPad +
                  _kNodeRadius * 2 +
                  maxLevel * _kLevelHeight +
                  60;

              return SingleChildScrollView(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: totalHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _EdgePainter(
                            nodes: nodes,
                            positions: positions,
                            completedIds: widget.completedNodeIds,
                          ),
                        ),
                      ),
                      ...nodes.map((node) {
                        final pos = positions[node.id]!;
                        return Positioned(
                          left: pos.dx - _kNodeRadius - _kLabelExtra,
                          top: pos.dy - _kNodeRadius,
                          child: _NodeWidget(
                            title: node.title,
                            subject: node.subject,
                            isCompleted: _isDone(node.id),
                            isUnlocked: _isOpen(node),
                            onTap: () => _onNodeTap(node),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232323), Color(0xFF161616)],
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 12,
              offset: const Offset(0, 5)),
          const BoxShadow(
              color: Color(0xFF3A3A3A),
              blurRadius: 4,
              offset: Offset(-1, -1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: '커리큘럼 목록',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.curriculum.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (!widget.isActive)
                raised3DButton(
                  onTap: widget.onStart,
                  shadowColor: Colors.blue.shade900,
                  faceColor: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(10),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                raised3DButton(
                  onTap: widget.onNavigateToHome,
                  shadowColor: Colors.green.shade900,
                  faceColor: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '이어하기',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              widget.curriculum.description,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF9E9E9E)),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Row(
              children: [
                _buildLegendItem(Colors.green.shade400, '완료'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.blue.shade300, '학습 가능'),
                const SizedBox(width: 16),
                _buildLegendItem(
                    const Color(0xFF484848), '잠금'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Color(0xFF9E9E9E))),
      ],
    );
  }
}

// ── 그래프 노드 위젯 ───────────────────────────────────────────

class _NodeWidget extends StatelessWidget {
  final String title;
  final String subject;
  final bool isCompleted;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _NodeWidget({
    required this.title,
    required this.subject,
    required this.isCompleted,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = _subjectAccent(subject);

    // ── 상태별 색상 계산 ──────────────────────────────────────
    final Color rimTop;
    final Color rimBottom;
    final List<Color> sphereColors;
    final Color glowColor;

    if (isCompleted) {
      rimTop = Colors.green.shade300;
      rimBottom = Colors.green.shade900;
      sphereColors = [
        Colors.green.shade300,
        Colors.green.shade600,
        Colors.green.shade900,
      ];
      glowColor = Colors.green;
    } else if (isUnlocked) {
      rimTop = Color.lerp(subjectColor, Colors.white, 0.55)!;
      rimBottom = Color.lerp(subjectColor, Colors.black, 0.5)!;
      sphereColors = [
        Color.lerp(subjectColor, Colors.white, 0.42)!,
        subjectColor,
        Color.lerp(subjectColor, Colors.black, 0.42)!,
      ];
      glowColor = subjectColor;
    } else {
      rimTop = const Color(0xFF4A4A4A);
      rimBottom = const Color(0xFF181818);
      sphereColors = [
        const Color(0xFF3C3C3C),
        const Color(0xFF262626),
        const Color(0xFF141414),
      ];
      glowColor = Colors.transparent;
    }

    // ── 내부 아이콘/텍스트 ────────────────────────────────────
    final Widget innerWidget;
    if (isCompleted) {
      innerWidget =
          const Icon(Icons.check_rounded, color: Colors.white, size: 24);
    } else if (isUnlocked) {
      innerWidget = Text(
        title.length > 2 ? title.substring(0, 2) : title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold),
      );
    } else {
      innerWidget = const Icon(Icons.lock_outline,
          color: Color(0xFF686868), size: 20);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: (_kNodeRadius + _kLabelExtra) * 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 외부 림 (그라데이션 테두리 + 그림자)
            Container(
              width: _kNodeRadius * 2,
              height: _kNodeRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [rimTop, rimBottom],
                ),
                boxShadow: [
                  if (isCompleted || isUnlocked)
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.55),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 10,
                    offset: const Offset(4, 5),
                  ),
                ],
              ),
              child: Center(
                // 내부 구체 (방사형 그라데이션으로 3D 볼 효과)
                child: Container(
                  width: _kNodeRadius * 2 - 7,
                  height: _kNodeRadius * 2 - 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.35, -0.45),
                      radius: 0.8,
                      colors: sphereColors,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Center(child: innerWidget),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: (isCompleted || isUnlocked)
                    ? const Color(0xFFEEEEEE)
                    : const Color(0xFF707070),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 엣지 페인터 ───────────────────────────────────────────────

class _EdgePainter extends CustomPainter {
  final List<CurriculumNode> nodes;
  final Map<String, Offset> positions;
  final Set<String> completedIds;

  _EdgePainter({
    required this.nodes,
    required this.positions,
    required this.completedIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in nodes) {
      final toCenter = positions[node.id];
      if (toCenter == null) continue;

      for (final prereqId in node.prereqIds) {
        final fromCenter = positions[prereqId];
        if (fromCenter == null) continue;

        final isActive = completedIds.contains(prereqId);

        // 글로우 레이어 (완료된 엣지에만)
        if (isActive) {
          final glowPaint = Paint()
            ..color = Colors.green.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round;

          final from = Offset(fromCenter.dx, fromCenter.dy + _kNodeRadius);
          final to = Offset(toCenter.dx, toCenter.dy - _kNodeRadius);
          final midY = (from.dy + to.dy) / 2;

          canvas.drawPath(
            Path()
              ..moveTo(from.dx, from.dy)
              ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy),
            glowPaint,
          );
        }

        // 메인 엣지
        final paint = Paint()
          ..color = isActive
              ? Colors.green.shade400
              : const Color(0xFF484848)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

        final from = Offset(fromCenter.dx, fromCenter.dy + _kNodeRadius);
        final to = Offset(toCenter.dx, toCenter.dy - _kNodeRadius);
        final midY = (from.dy + to.dy) / 2;

        canvas.drawPath(
          Path()
            ..moveTo(from.dx, from.dy)
            ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) {
    if (old.completedIds.length != completedIds.length) return true;
    return !old.completedIds.containsAll(completedIds);
  }
}
