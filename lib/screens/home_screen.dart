import 'package:flutter/material.dart';

import '../models/curriculum.dart';
import '../services/curriculum_service.dart';
import '../state/app_scope.dart';
import '../state/progress_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_transitions.dart';
import 'content_screen.dart';
import 'curriculum_screen.dart';
import 'level_assessment_screen.dart';
import 'profile_screen.dart';
import 'section_screen.dart';

class HomeScreen extends StatefulWidget {
  final CurriculumService curriculumService;

  const HomeScreen({
    super.key,
    this.curriculumService = const MockCurriculumService(),
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  List<Curriculum> _curriculums = const [];
  bool _isLoading = true;
  Curriculum? _activeCurriculum;

  late ProgressRepository _progress;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _progress = AppScope.of(context).progress;
    if (!_initialized) {
      _initialized = true;
      _loadCurriculums();
    }
  }

  Future<void> _loadCurriculums() async {
    try {
      final list = await widget.curriculumService.fetchCurriculums();
      if (!mounted) return;
      // 마지막으로 진행하던 커리큘럼을 복원합니다.
      final savedId = _progress.activeCurriculumId;
      final index = list.indexWhere((c) => c.id == savedId);
      setState(() {
        _curriculums = list;
        _activeCurriculum = index >= 0 ? list[index] : null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('커리큘럼을 불러오지 못했습니다')),
      );
    }
  }

  /// 진행 중인 커리큘럼을 바꿉니다.
  ///
  /// 진행률은 커리큘럼별로 따로 보관되므로 여기서 초기화하지 않습니다.
  void _onCurriculumSelected(Curriculum curriculum) {
    setState(() => _activeCurriculum = curriculum);
    _progress.setActiveCurriculum(curriculum.id);
  }

  void _onTabSelected(int index) => setState(() => _selectedTabIndex = index);

  void _onNodeTap(Curriculum curriculum, CurriculumNode node) {
    Navigator.push(
      context,
      fadeRoute(SectionScreen(
        curriculumId: curriculum.id,
        curriculumName: curriculum.name,
        node: node,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _progress,
      builder: (context, _) {
        final pages = [
          CurriculumScreen(
            curriculums: _curriculums,
            isLoading: _isLoading,
            activeCurriculum: _activeCurriculum,
            completedNodeIdsOf: _progress.completedNodeIds,
            onCurriculumSelected: _onCurriculumSelected,
            onNodeTap: _onNodeTap,
          ),
          const ContentScreen(),
          const LevelAssessmentScreen(),
          ProfileScreen(curriculums: _curriculums),
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
              Container(height: 1, color: AppColors.borderDark),
              BottomNavigationBar(
                currentIndex: _selectedTabIndex,
                onTap: _onTabSelected,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: const [
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
      },
    );
  }
}
