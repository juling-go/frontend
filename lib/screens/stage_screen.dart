import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/stage.dart';
import '../models/stage_result.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class _ConfettiParticle {
  final Color color;
  final double startX;
  final double vy;
  final double vx;
  final double size;
  final double rotation;
  final double rotationSpeed;

  const _ConfettiParticle({
    required this.color,
    required this.startX,
    required this.vy,
    required this.vx,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = p.startX * size.width + p.vx * progress;
      final y = -20 + p.vy * progress * size.height + 180 * progress * progress;
      final alpha = (1 - progress * 0.85).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * p.rotationSpeed);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class StageScreen extends StatefulWidget {
  final Stage stage;

  const StageScreen({super.key, required this.stage});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen>
    with TickerProviderStateMixin {
  int _qIndex = 0;
  final Map<int, Set<String>> _selected = {};
  final Map<int, bool> _submitted = {};

  /// 문항 index → 정답 여부. 채점 결과의 근거가 됩니다.
  final Map<int, bool> _results = {};

  bool _showHint = false;
  bool? _lastCorrect;

  late final AnimationController _resultController;
  late final AnimationController _shakeController;
  late final AnimationController _flashController;
  late final AnimationController _confettiController;
  late List<_ConfettiParticle> _confettiParticles;

  final _rng = Random();

  List<Question> get _questions => widget.stage.questions;
  Question get _current => _questions[_qIndex];
  bool get _isSubmitted => _submitted[_qIndex] ?? false;
  Set<String> get _currentSelected => _selected[_qIndex] ?? {};
  bool get _isLast => _qIndex == _questions.length - 1;

  bool get _isCorrect {
    final correct = Set.of(_current.correctIds);
    return _currentSelected.length == correct.length &&
        _currentSelected.every(correct.contains);
  }

  /// 지금까지 맞힌 문항 수.
  int get _correctCount => _results.values.where((c) => c).length;

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _flashController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _confettiController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _confettiParticles = _buildParticles();
  }

  List<_ConfettiParticle> _buildParticles() {
    return List.generate(
      50,
      (_) => _ConfettiParticle(
        color: AppColors.confetti[_rng.nextInt(AppColors.confetti.length)],
        startX: _rng.nextDouble(),
        vy: _rng.nextDouble() * 0.6 + 0.4,
        vx: (_rng.nextDouble() - 0.5) * 60,
        size: _rng.nextDouble() * 10 + 5,
        rotation: _rng.nextDouble() * pi * 2,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
      ),
    );
  }

  @override
  void dispose() {
    _resultController.dispose();
    _shakeController.dispose();
    _flashController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleSelect(String id) {
    if (_isSubmitted) return;
    setState(() {
      final sel = Set.of(_currentSelected);
      if (_current.type == QuestionType.multipleChoice) {
        sel.contains(id) ? sel.remove(id) : sel.add(id);
      } else {
        sel
          ..clear()
          ..add(id);
      }
      _selected[_qIndex] = sel;
    });
  }

  void _submit() {
    final correct = _isCorrect;
    setState(() {
      _submitted[_qIndex] = true;
      _results[_qIndex] = correct;
      _showHint = false;
      _lastCorrect = correct;
    });
    _resultController.forward(from: 0);
    _flashController.forward(from: 0);
    if (correct) {
      _confettiParticles = _buildParticles();
      _confettiController.forward(from: 0);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      setState(() {
        _qIndex++;
        _showHint = false;
        _lastCorrect = null;
      });
      _resetAnimations();
    }
  }

  void _resetAnimations() {
    _resultController.reset();
    _shakeController.reset();
    _flashController.reset();
    _confettiController.reset();
  }

  /// 마지막 문항을 제출한 뒤 채점 결과를 보여주고 화면을 닫습니다.
  ///
  /// 합격 여부 판정은 이 결과를 받은 SectionScreen이 [StageResult]로 수행합니다.
  Future<void> _finish() async {
    final result = StageResult(
      total: _questions.length,
      correct: _correctCount,
    );

    final action = await showDialog<_FinishAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(result: result),
    );

    if (!mounted) return;

    if (action == _FinishAction.retry) {
      setState(() {
        _qIndex = 0;
        _selected.clear();
        _submitted.clear();
        _results.clear();
        _showHint = false;
        _lastCorrect = null;
      });
      _resetAnimations();
      return;
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.stage.title),
        ),
        body: const Center(child: Text('문제가 아직 준비되지 않았습니다.')),
      );
    }

    final progress =
        (_qIndex + (_isSubmitted ? 1 : 0)) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.stage.title, style: AppTextStyles.titleMedium),
        actions: [
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Text(
                  '$_correctCount / ${_results.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.green300,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
            minHeight: 4,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_qIndex + 1} / ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.blue600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      _buildTypeBadge(_current.type),
                      const SizedBox(height: AppSpacing.s14),
                      Text(_current.content, style: AppTextStyles.question),
                      const SizedBox(height: AppSpacing.s28),
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) {
                          final t = _shakeController.value;
                          final offset = sin(t * pi * 6) * (1 - t) * 14;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child!,
                          );
                        },
                        child: _buildChoices(),
                      ),
                      if (_showHint && _current.hint != null) ...[
                        const SizedBox(height: AppSpacing.s20),
                        _buildHintBox(_current.hint!),
                      ],
                      if (_isSubmitted) ...[
                        const SizedBox(height: AppSpacing.s20),
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _resultController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _resultController,
                              curve: const Interval(0.0, 0.5),
                            ),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.85, end: 1.0)
                                  .animate(CurvedAnimation(
                                parent: _resultController,
                                curve: _lastCorrect == true
                                    ? Curves.elasticOut
                                    : Curves.easeOutBack,
                              )),
                              child: _buildResultMessage(),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
          AnimatedBuilder(
            animation: _flashController,
            builder: (ctx, _) {
              final alpha = (1 - _flashController.value) * 0.28;
              if (alpha <= 0 || _lastCorrect == null) {
                return const SizedBox.shrink();
              }
              final color = _lastCorrect! ? Colors.green : Colors.red;
              return IgnorePointer(
                child: Container(color: color.withValues(alpha: alpha)),
              );
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (ctx, _) {
                  if (_confettiController.value == 0) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      _confettiParticles,
                      _confettiController.value,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(QuestionType type) {
    final (label, color) = switch (type) {
      QuestionType.ox             => ('O / X', Colors.purple),
      QuestionType.singleChoice   => ('단일 선택', AppColors.blue),
      QuestionType.multipleChoice => ('복수 선택', Colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.rXs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChoices() {
    return switch (_current.type) {
      QuestionType.ox => _buildOxChoices(),
      QuestionType.singleChoice || QuestionType.multipleChoice =>
        _buildOptionList(),
    };
  }

  Widget _buildOxChoices() {
    return Row(
      children: [
        Expanded(child: _buildOxButton('O')),
        const SizedBox(width: AppSpacing.s12),
        Expanded(child: _buildOxButton('X')),
      ],
    );
  }

  Widget _buildOxButton(String value) {
    final isSelected = _currentSelected.contains(value);
    final isCorrect = _current.correctIds.contains(value);
    final Color bgColor;
    final Color borderColor;
    final Color textColor;

    if (_isSubmitted) {
      if (isCorrect) {
        bgColor = AppColors.green900;
        borderColor = AppColors.green;
        textColor = AppColors.green300;
      } else if (isSelected) {
        bgColor = Colors.red.shade900;
        borderColor = Colors.red;
        textColor = Colors.red.shade300;
      } else {
        bgColor = AppColors.surface;
        borderColor = AppColors.border;
        textColor = AppColors.textDimmed;
      }
    } else if (isSelected) {
      bgColor = AppColors.blue900;
      borderColor = AppColors.blue;
      textColor = AppColors.blue300;
    } else {
      bgColor = AppColors.surface;
      borderColor = AppColors.border;
      textColor = AppColors.textSecondary;
    }

    return GestureDetector(
      onTap: () => _toggleSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: AppSpacing.loginIcon,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.rLg),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            value,
            style: AppTextStyles.oxButton.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionList() {
    return Column(
      children: _current.choices.asMap().entries.map((entry) {
        final i = entry.key;
        final choice = entry.value;
        final isSelected = _currentSelected.contains(choice.id);
        final isCorrect = _current.correctIds.contains(choice.id);
        final isMultiple = _current.type == QuestionType.multipleChoice;

        final Color bgColor;
        final Color borderColor;
        final Color textColor;
        Widget? trailingIcon;

        if (_isSubmitted) {
          if (isCorrect) {
            bgColor = AppColors.green900;
            borderColor = AppColors.green;
            textColor = AppColors.green300;
            trailingIcon = const Icon(Icons.check_circle,
                color: AppColors.green, size: AppSpacing.iconMd);
          } else if (isSelected) {
            bgColor = Colors.red.shade900;
            borderColor = Colors.red;
            textColor = Colors.red.shade300;
            trailingIcon = Icon(Icons.cancel,
                color: Colors.red, size: AppSpacing.iconMd);
          } else {
            bgColor = AppColors.surface;
            borderColor = AppColors.border;
            textColor = AppColors.textDimmed;
          }
        } else if (isSelected) {
          bgColor = AppColors.blue900;
          borderColor = AppColors.blue;
          textColor = AppColors.blue300;
          trailingIcon = Icon(
            isMultiple ? Icons.check_box : Icons.radio_button_checked,
            color: AppColors.blue,
            size: AppSpacing.iconMd,
          );
        } else {
          bgColor = AppColors.surface;
          borderColor = AppColors.border;
          textColor = AppColors.textPrimary;
          trailingIcon = const Icon(Icons.radio_button_unchecked,
              color: AppColors.textDimmed, size: AppSpacing.iconMd);
        }

        const labels = ['①', '②', '③', '④', '⑤'];

        return GestureDetector(
          onTap: () => _toggleSelect(choice.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.only(bottom: AppSpacing.s10),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.s14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.rMd),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Text(
                  labels[i],
                  style: AppTextStyles.titleSmall.copyWith(color: textColor),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    choice.text,
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                ),
                ?trailingIcon,
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHintBox(String hint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: AppColors.hintBg,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
        border: Border.all(color: AppColors.amber200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline,
              color: AppColors.amber700, size: AppSpacing.icon18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(fontSize: 13, color: AppColors.amber900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMessage() {
    final correct = _isCorrect;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s14),
      decoration: BoxDecoration(
        color: correct ? AppColors.green900 : Colors.red.shade900,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
        border: Border.all(
          color: correct ? AppColors.green300 : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: (correct ? AppColors.green : Colors.red)
                .withValues(alpha: 0.3),
            blurRadius: AppSpacing.s12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_outline : Icons.highlight_off,
            color: correct ? AppColors.green : Colors.red,
            size: AppSpacing.icon22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            correct ? '정답입니다!' : '오답입니다.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: correct ? AppColors.green300 : Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.s12, AppSpacing.md, AppSpacing.s28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: AppSpacing.sm,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_current.hint != null)
            TextButton.icon(
              onPressed: () => setState(() => _showHint = !_showHint),
              icon: Icon(
                _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                size: AppSpacing.icon18,
              ),
              label: const Text('힌트'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.amber700),
            ),
          const Spacer(),
          if (!_isSubmitted)
            ElevatedButton(
              onPressed: _currentSelected.isNotEmpty ? _submit : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.s14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.rMd)),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 15)),
            )
          else
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isLast ? AppColors.green : AppColors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.s14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.rMd)),
              ),
              child: Text(
                _isLast ? '완료' : '다음',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 스테이지 채점 결과 ─────────────────────────────────────────

enum _FinishAction { retry, exit }

class _ResultDialog extends StatelessWidget {
  final StageResult result;

  const _ResultDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final accent = passed ? AppColors.green : AppColors.amber700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradDialog,
          borderRadius: BorderRadius.circular(AppSpacing.rXl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: AppSpacing.s20,
              offset: const Offset(6, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events : Icons.replay_circle_filled_outlined,
              color: accent,
              size: AppSpacing.icon48,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              passed ? '스테이지 완료!' : '조금만 더!',
              style: AppTextStyles.headingLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${result.total}문제 중 ${result.correct}문제 정답',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.rXs),
              child: LinearProgressIndicator(
                value: result.ratio,
                backgroundColor: AppColors.borderDark,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                minHeight: AppSpacing.sm,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '정답률 ${result.percent}%'
              '${passed ? '' : ' (완료 기준 ${(kStagePassRatio * 100).round()}%)'}',
              style: AppTextStyles.captionMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pop(context, _FinishAction.retry),
                    child: const Text('다시 풀기'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _FinishAction.exit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.r10),
                      ),
                    ),
                    child: Text(passed ? '완료' : '나가기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
