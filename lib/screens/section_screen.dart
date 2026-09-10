import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../models/stage.dart';
import '../models/stage_result.dart';
import '../state/app_scope.dart';
import '../state/progress_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_transitions.dart';
import 'stage_screen.dart';

class SectionScreen extends StatefulWidget {
  final String curriculumId;
  final String curriculumName;
  final CurriculumNode node;

  const SectionScreen({
    super.key,
    required this.curriculumId,
    required this.curriculumName,
    required this.node,
  });

  @override
  State<SectionScreen> createState() => _SectionScreenState();
}

class _SectionScreenState extends State<SectionScreen> {
  late ProgressRepository _progress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _progress = AppScope.of(context).progress;
  }

  Set<String> get _completedStageIds =>
      _progress.completedStageIds(widget.curriculumId);

  int get _currentStageIndex {
    final idx = widget.node.stages
        .indexWhere((s) => !_completedStageIds.contains(s.id));
    return idx < 0 ? widget.node.stages.length - 1 : idx;
  }

  Future<void> _showStagePopup(Stage stage) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20, vertical: AppSpacing.s60),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.gradDialog,
            borderRadius: BorderRadius.circular(AppSpacing.rXl),
            boxShadow: [
              const BoxShadow(
                  color: AppColors.borderHighlight,
                  blurRadius: 4,
                  offset: Offset(-2, -2)),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: AppSpacing.s20,
                  offset: const Offset(6, 10)),
            ],
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stage.title, style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.s6),
              Text(stage.subtitle, style: AppTextStyles.bodyMuted),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: AppSpacing.iconXs, color: AppColors.textDimmed),
                  const SizedBox(width: AppSpacing.s6),
                  Text(
                    '예상 시간: ${stage.estimatedMinutes}분',
                    style: AppTextStyles.bodySmallMuted,
                  ),
                ],
              ),
              if (stage.learningObjective.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s14),
                const Text('학습 목표', style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(stage.learningObjective,
                    style: AppTextStyles.bodySmallMuted),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result =
                          await pushWithLoadingOverlay<StageResult>(
                        context: context,
                        destination: StageScreen(stage: stage),
                        title: stage.title,
                        subtitle: stage.subtitle,
                      );
                      if (!mounted || result == null) return;
                      // 합격선(정답률 60%)을 넘겨야 스테이지가 완료됩니다.
                      if (result.passed) {
                        await _progress.markStageCompleted(
                            widget.curriculumId, stage.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '정답률 ${result.percent}% — '
                              '${(kStagePassRatio * 100).round()}% 이상이어야 완료됩니다.',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.r10)),
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _progress,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final node = widget.node;
    final currentIdx = _currentStageIndex;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
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
                      : () => _showStagePopup(stage),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final node = widget.node;
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
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: AppSpacing.icon18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                    minWidth: AppSpacing.s36, minHeight: AppSpacing.s36),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.school_outlined,
                  color: AppColors.blue, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.curriculumName,
                  style: AppTextStyles.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s14),
            decoration: BoxDecoration(
              gradient: AppColors.gradInnerCard,
              borderRadius: BorderRadius.circular(AppSpacing.rMd),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: AppSpacing.s6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${node.subject}  >  ${node.chapter}',
                  style: AppTextStyles.breadcrumb,
                ),
                const SizedBox(height: AppSpacing.s5),
                Text(node.title, style: AppTextStyles.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  node.description,
                  style: AppTextStyles.bodySmallMuted,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
        ? AppColors.green900
        : isCurrent
            ? AppColors.blue900
            : AppColors.borderDark;

    final LinearGradient bgGradient = isLocked
        ? AppColors.gradStageLocked
        : isCompleted
            ? AppColors.gradStageCompleted
            : isCurrent
                ? AppColors.gradStageCurrent
                : AppColors.gradStageDefault;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s10),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(AppSpacing.r14),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isLocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: AppSpacing.s6,
                    offset: const Offset(2, 3),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: AppColors.borderHighlightDim,
                    blurRadius: 3,
                    offset: Offset(-1, -1),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: AppSpacing.s10,
                    offset: const Offset(4, 5),
                  ),
                ],
        ),
        child: Row(
          children: [
            _buildCoinWidget(
              index: index,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLocked: isLocked,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stage',
                    style: AppTextStyles.label.copyWith(
                      color: isLocked
                          ? AppColors.textDisabled
                          : isCompleted
                              ? AppColors.green600
                              : AppColors.blue600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stage.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isLocked
                          ? AppColors.textLocked
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stage.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked
                          ? AppColors.textDisabled
                          : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isLocked) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                isCompleted
                    ? Icons.replay_outlined
                    : Icons.play_circle_outline,
                color: isCompleted ? AppColors.green400 : AppColors.blue400,
                size: AppSpacing.icon22,
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
        ? AppColors.green
        : isCurrent
            ? AppColors.blue
            : AppColors.coinFaceDefault;

    final Color rimColor = isCompleted
        ? AppColors.green700
        : isCurrent
            ? AppColors.blue700
            : AppColors.coinRimDefault;

    final Color shadowColor = isCompleted
        ? AppColors.green900
        : isCurrent
            ? AppColors.blue900
            : AppColors.coinShadowDefault;

    final Widget face = isCompleted
        ? const Icon(Icons.check_rounded,
            color: Colors.white, size: AppSpacing.icon18)
        : isLocked
            ? const Icon(Icons.lock_outline,
                color: AppColors.textDimmed, size: AppSpacing.iconXs)
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );

    return Container(
      width: AppSpacing.coin,
      height: AppSpacing.coin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shadowColor,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.5),
            blurRadius: AppSpacing.xs,
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
