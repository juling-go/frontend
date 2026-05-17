import 'package:flutter/material.dart';
import '../models/section.dart';
import '../models/stage.dart';
import '../services/section_service.dart';
import 'curriculum_screen.dart';
import 'level_assessment_screen.dart';
import 'problem_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sectionService = SectionService();
  final ScrollController _scrollController = ScrollController();
  Section? _section;
  bool _isLoading = true;
  int _currentStageIndex = 0;
  int _selectedTabIndex = 0;

  static const double _stageRowHeight = 120.0;

  @override
  void initState() {
    super.initState();
    _loadSection();
  }

  Future<void> _loadSection() async {
    try {
      final section = await _sectionService.getSection();
      final currentStage = section.stages.indexWhere((stage) => !stage.isCompleted);
      setState(() {
        _section = section;
        _currentStageIndex = currentStage < 0 ? section.stages.length - 1 : currentStage;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentStage();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('섹션 데이터를 불러오는데 실패했습니다')),
        );
      }
    }
  }

  void _scrollToCurrentStage() {
    if (!_scrollController.hasClients || _section == null) return;
    final targetOffset = (_currentStageIndex * _stageRowHeight) - (MediaQuery.of(context).size.height / 4);
    final clampOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.jumpTo(clampOffset);
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _onStageTap(int index) {
    if (_section == null) return;
    if (index > _currentStageIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 이전 스테이지를 클리어하세요')),
      );
      return;
    }

    final stage = _section!.stages[index];
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProblemScreen(stage: stage)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildSectionView(),
      const CurriculumScreen(),
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

  Widget _buildSectionView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_section == null) {
      return const Center(child: Text('섹션 정보를 불러올 수 없습니다.'));
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_section!.subject} > ${_section!.chapter} > ${_section!.sectionName}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _section!.description,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: ScrollConfiguration(
              behavior: _NoOverscrollBehavior(),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: false,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _RoadmapPainter(stageCount: _section!.stages.length),
                      ),
                    ),
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: List.generate(_section!.stages.length, (index) {
                          final stage = _section!.stages[index];
                          final isLocked = index > _currentStageIndex;
                          final isCurrent = index == _currentStageIndex;
                          return _buildStageRow(stage, index, isCurrent, isLocked);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageRow(Stage stage, int index, bool isCurrent, bool isLocked) {
    final color = isLocked
        ? Colors.grey.shade300
        : isCurrent
            ? Colors.blue
            : Colors.green;

    return GestureDetector(
      onTap: () => _onStageTap(index),
      child: Container(
        height: _stageRowHeight,
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isLocked ? Colors.black45 : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isLocked ? Colors.grey.shade200 : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stage.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.black45 : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stage.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked ? Colors.black38 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLocked
                          ? '잠금 상태: 이전 스테이지 완료 후 오픈'
                          : isCurrent
                              ? '현재 학습 중인 스테이지'
                              : '완료된 스테이지',
                      style: TextStyle(
                        fontSize: 13,
                        color: isLocked ? Colors.black38 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapPainter extends CustomPainter {
  final int stageCount;

  _RoadmapPainter({required this.stageCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const centerX = 50.0;
    const startY = 40.0;
    const stepY = _HomeScreenState._stageRowHeight;

    path.moveTo(centerX, startY);
    for (var i = 0; i < stageCount; i++) {
      final currentY = startY + i * stepY;
      final controlX = centerX + (i.isEven ? 40 : -40);
      final controlY = currentY - 20;
      path.quadraticBezierTo(controlX, controlY, centerX, currentY + 20);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RoadmapPainter oldDelegate) {
    return oldDelegate.stageCount != stageCount;
  }
}

class _NoOverscrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
