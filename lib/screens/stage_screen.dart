import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/stage.dart';

class StageScreen extends StatefulWidget {
  final Stage stage;

  const StageScreen({super.key, required this.stage});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  int _qIndex = 0;
  final Map<int, Set<String>> _selected = {};
  final Map<int, bool> _submitted = {};
  bool _showHint = false;

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
    setState(() {
      _submitted[_qIndex] = true;
      _showHint = false;
    });
  }

  void _next() {
    if (_isLast) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _qIndex++;
        _showHint = false;
      });
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 문제 번호
                  Text(
                    '${_qIndex + 1} / ${_questions.length}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 문제 유형 배지
                  _buildTypeBadge(_current.type),
                  const SizedBox(height: 14),
                  // 문제 내용
                  Text(
                    _current.content,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 선택지
                  _buildChoices(),
                  // 힌트
                  if (_showHint && _current.hint != null) ...[
                    const SizedBox(height: 20),
                    _buildHintBox(_current.hint!),
                  ],
                  // 제출 후 결과 메시지
                  if (_isSubmitted) ...[
                    const SizedBox(height: 20),
                    _buildResultMessage(),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // 하단 버튼 영역
          _buildBottomBar(),
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
        bgColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
      } else if (isSelected) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
      } else {
        bgColor = Colors.white;
        borderColor = Colors.grey.shade300;
        textColor = Colors.black45;
      }
    } else if (isSelected) {
      bgColor = Colors.blue.shade50;
      borderColor = Colors.blue;
      textColor = Colors.blue.shade700;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.black54;
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
            bgColor = Colors.green.shade50;
            borderColor = Colors.green;
            textColor = Colors.green.shade800;
            trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
          } else if (isSelected) {
            bgColor = Colors.red.shade50;
            borderColor = Colors.red;
            textColor = Colors.red.shade800;
            trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
          } else {
            bgColor = Colors.white;
            borderColor = Colors.grey.shade200;
            textColor = Colors.black38;
          }
        } else if (isSelected) {
          bgColor = Colors.blue.shade50;
          borderColor = Colors.blue;
          textColor = Colors.blue.shade800;
          trailingIcon = Icon(
            isMultiple ? Icons.check_box : Icons.radio_button_checked,
            color: Colors.blue,
            size: 20,
          );
        } else {
          bgColor = Colors.white;
          borderColor = Colors.grey.shade300;
          textColor = Colors.black87;
          trailingIcon = Icon(
            isMultiple ? Icons.check_box_outline_blank : Icons.radio_button_unchecked,
            color: Colors.grey.shade400,
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
                if (trailingIcon case final icon?) icon,
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
        color: Colors.amber.shade50,
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
        color: correct ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: correct ? Colors.green.shade200 : Colors.red.shade200,
        ),
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
              color: correct ? Colors.green.shade700 : Colors.red.shade700,
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
