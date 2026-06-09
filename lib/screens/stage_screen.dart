import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/stage.dart';

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
    const colors = [
      Color(0xFFFFD700), Color(0xFF64B5F6), Color(0xFF81C784),
      Color(0xFFF06292), Color(0xFFFFB74D), Color(0xFFBA68C8),
      Color(0xFF4DD0E1), Color(0xFFFF8A65),
    ];
    return List.generate(50, (_) => _ConfettiParticle(
      color: colors[_rng.nextInt(colors.length)],
      startX: _rng.nextDouble(),
      vy: _rng.nextDouble() * 0.6 + 0.4,
      vx: (_rng.nextDouble() - 0.5) * 60,
      size: _rng.nextDouble() * 10 + 5,
      rotation: _rng.nextDouble() * pi * 2,
      rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
    ));
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
      Navigator.pop(context, true);
    } else {
      setState(() {
        _qIndex++;
        _showHint = false;
        _lastCorrect = null;
      });
      _resultController.reset();
      _shakeController.reset();
      _flashController.reset();
      _confettiController.reset();
    }
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

    final progress = (_qIndex + (_isSubmitted ? 1 : 0)) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.stage.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2E2E2E),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_qIndex + 1} / ${_questions.length}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTypeBadge(_current.type),
                      const SizedBox(height: 14),
                      Text(
                        _current.content,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Shake wrapper for wrong answer
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
                        const SizedBox(height: 20),
                        _buildHintBox(_current.hint!),
                      ],
                      if (_isSubmitted) ...[
                        const SizedBox(height: 20),
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
                              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _resultController,
                                  curve: _lastCorrect == true
                                      ? Curves.elasticOut
                                      : Curves.easeOutBack,
                                ),
                              ),
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
          // Green/red flash overlay
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
          // Confetti for correct answers
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
      QuestionType.ox => ('O / X', Colors.purple),
      QuestionType.singleChoice => ('단일 선택', Colors.blue),
      QuestionType.multipleChoice => ('복수 선택', Colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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
        const SizedBox(width: 12),
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
        bgColor = Colors.green.shade900;
        borderColor = Colors.green;
        textColor = Colors.green.shade300;
      } else if (isSelected) {
        bgColor = Colors.red.shade900;
        borderColor = Colors.red;
        textColor = Colors.red.shade300;
      } else {
        bgColor = const Color(0xFF1E1E1E);
        borderColor = const Color(0xFF383838);
        textColor = const Color(0xFF686868);
      }
    } else if (isSelected) {
      bgColor = Colors.blue.shade900;
      borderColor = Colors.blue;
      textColor = Colors.blue.shade300;
    } else {
      bgColor = const Color(0xFF1E1E1E);
      borderColor = const Color(0xFF383838);
      textColor = const Color(0xFF9E9E9E);
    }

    return GestureDetector(
      onTap: () => _toggleSelect(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
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
            bgColor = Colors.green.shade900;
            borderColor = Colors.green;
            textColor = Colors.green.shade300;
            trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
          } else if (isSelected) {
            bgColor = Colors.red.shade900;
            borderColor = Colors.red;
            textColor = Colors.red.shade300;
            trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
          } else {
            bgColor = const Color(0xFF1E1E1E);
            borderColor = const Color(0xFF383838);
            textColor = const Color(0xFF686868);
          }
        } else if (isSelected) {
          bgColor = Colors.blue.shade900;
          borderColor = Colors.blue;
          textColor = Colors.blue.shade300;
          trailingIcon = Icon(
            isMultiple ? Icons.check_box : Icons.radio_button_checked,
            color: Colors.blue,
            size: 20,
          );
        } else {
          bgColor = const Color(0xFF1E1E1E);
          borderColor = const Color(0xFF383838);
          textColor = const Color(0xFFEEEEEE);
          trailingIcon = const Icon(
            Icons.radio_button_unchecked,
            color: Color(0xFF686868),
            size: 20,
          );
        }

        final labels = ['①', '②', '③', '④', '⑤'];

        return GestureDetector(
          onTap: () => _toggleSelect(choice.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? Colors.green.shade900 : Colors.red.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: correct ? Colors.green.shade200 : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: (correct ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_outline : Icons.highlight_off,
            color: correct ? Colors.green : Colors.red,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            correct ? '정답입니다!' : '오답입니다.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: correct ? Colors.green.shade300 : Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
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
                size: 18,
              ),
              label: const Text('힌트'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber.shade700,
              ),
            ),
          const Spacer(),
          if (!_isSubmitted)
            ElevatedButton(
              onPressed: _currentSelected.isNotEmpty ? _submit : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('확인', style: TextStyle(fontSize: 15)),
            )
          else
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLast ? Colors.green : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
