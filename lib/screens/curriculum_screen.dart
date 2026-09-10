import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../services/curriculum_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

const _kNodeRadius  = AppSpacing.graphNodeRadius;
const _kLevelHeight = AppSpacing.graphLevelHeight;
const _kLabelExtra  = AppSpacing.graphLabelExtra;
const _kTopPad      = AppSpacing.graphTopPad;

class CurriculumScreen extends StatefulWidget {
  final Curriculum? activeCurriculum;
  final Set<String> completedNodeIds;
  final void Function(Curriculum) onCurriculumSelected;
  final void Function(Curriculum, CurriculumNode)? onNodeTap;
  final CurriculumService service;

  const CurriculumScreen({
    super.key,
    required this.activeCurriculum,
    required this.completedNodeIds,
    required this.onCurriculumSelected,
    this.onNodeTap,
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
        onStart: () => _selectCurriculum(_viewing!),
        onSectionTap: (node) => widget.onNodeTap?.call(_viewing!, node),
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
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _curriculums.length,
              itemBuilder: (context, index) => _CurriculumCard(
                curriculum: _curriculums[index],
                isActive:
                    widget.activeCurriculum?.id == _curriculums[index].id,
                onTap: () => setState(() => _viewing = _curriculums[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s20, AppSpacing.s20, AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.gradHeader,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: AppSpacing.s12,
              offset: const Offset(0, 5)),
          const BoxShadow(
              color: AppColors.borderHighlightDim,
              blurRadius: AppSpacing.xs,
              offset: Offset(-1, -1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('커리큘럼', style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.activeCurriculum != null
                ? '진행 중: ${widget.activeCurriculum!.name}'
                : '학습할 커리큘럼을 선택하세요',
            style: TextStyle(
              fontSize: 13,
              color: widget.activeCurriculum != null
                  ? AppColors.blue400
                  : AppColors.textSecondary,
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
        margin: const EdgeInsets.only(bottom: AppSpacing.s14),
        padding: const EdgeInsets.all(AppSpacing.s18),
        decoration: card3D(
          border: Border.all(
            color: isActive ? AppColors.blue : Colors.transparent,
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
                          style: AppTextStyles.headingSmall,
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: AppSpacing.s3),
                          decoration: BoxDecoration(
                            color: AppColors.blue900,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.rSm),
                            border:
                                Border.all(color: AppColors.blue700),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withValues(alpha: 0.25),
                                blurRadius: AppSpacing.s6,
                              ),
                            ],
                          ),
                          child: const Text(
                            '진행 중',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.blue300,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    curriculum.description,
                    style: AppTextStyles.bodySmallMuted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Text(
                    '섹션 ${curriculum.nodes.length}개',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.blue400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.textDimmed),
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
  final void Function(CurriculumNode)? onSectionTap;

  const _CurriculumDetailView({
    required this.curriculum,
    required this.completedNodeIds,
    required this.isActive,
    required this.onBack,
    required this.onStart,
    this.onSectionTap,
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
    widget.onSectionTap?.call(node);
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
              final positions =
                  _computePositions(constraints.maxWidth);
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.s20, AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppColors.gradHeader,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: AppSpacing.s12,
              offset: const Offset(0, 5)),
          const BoxShadow(
              color: AppColors.borderHighlightDim,
              blurRadius: AppSpacing.xs,
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: AppSpacing.icon18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: AppSpacing.s36, minHeight: AppSpacing.s36),
                tooltip: '커리큘럼 목록',
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  widget.curriculum.name,
                  style: AppTextStyles.headingMedium,
                ),
              ),
              if (!widget.isActive)
                raised3DButton(
                  onTap: widget.onStart,
                  shadowColor: AppColors.blue900,
                  faceColor: AppColors.blue600,
                  borderRadius: BorderRadius.circular(AppSpacing.r10),
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s40),
            child: Text(
              widget.curriculum.description,
              style: AppTextStyles.bodySmallMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s40),
            child: Row(
              children: [
                _buildLegendItem(AppColors.green400, '완료'),
                const SizedBox(width: AppSpacing.md),
                _buildLegendItem(AppColors.blue300, '학습 가능'),
                const SizedBox(width: AppSpacing.md),
                _buildLegendItem(AppColors.borderSubtle, '잠금'),
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
          width: AppSpacing.s10,
          height: AppSpacing.s10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: AppSpacing.xs,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.captionSmallMuted),
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
    final subjectColor = AppColors.subjectAccent(subject);

    final Color rimTop;
    final Color rimBottom;
    final List<Color> sphereColors;
    final Color glowColor;

    if (isCompleted) {
      rimTop = AppColors.green300;
      rimBottom = AppColors.green900;
      sphereColors = [AppColors.green300, AppColors.green600, AppColors.green900];
      glowColor = AppColors.green;
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
      rimTop = AppColors.nodeLockedRimTop;
      rimBottom = AppColors.nodeLockedRimBottom;
      sphereColors = [
        AppColors.nodeLockedSphereLight,
        AppColors.nodeLockedSphereMid,
        AppColors.nodeLockedSphereDark,
      ];
      glowColor = Colors.transparent;
    }

    final Widget innerWidget;
    if (isCompleted) {
      innerWidget = const Icon(Icons.check_rounded,
          color: Colors.white, size: AppSpacing.lg);
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
          color: AppColors.textDimmed, size: AppSpacing.iconMd);
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: (_kNodeRadius + _kLabelExtra) * 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                      blurRadius: AppSpacing.md,
                      spreadRadius: AppSpacing.s3,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: AppSpacing.s10,
                    offset: const Offset(4, 5),
                  ),
                ],
              ),
              child: Center(
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
            const SizedBox(height: AppSpacing.s6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: (isCompleted || isUnlocked)
                    ? AppColors.textPrimary
                    : AppColors.textLocked,
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

        if (isActive) {
          final glowPaint = Paint()
            ..color = AppColors.green.withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = AppSpacing.s6
            ..strokeCap = StrokeCap.round;

          final from =
              Offset(fromCenter.dx, fromCenter.dy + _kNodeRadius);
          final to = Offset(toCenter.dx, toCenter.dy - _kNodeRadius);
          final midY = (from.dy + to.dy) / 2;

          canvas.drawPath(
            Path()
              ..moveTo(from.dx, from.dy)
              ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy),
            glowPaint,
          );
        }

        final paint = Paint()
          ..color = isActive ? AppColors.green400 : AppColors.edgeLocked
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

        final from =
            Offset(fromCenter.dx, fromCenter.dy + _kNodeRadius);
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
