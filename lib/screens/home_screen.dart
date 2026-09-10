import 'package:flutter/material.dart';
import '../models/curriculum.dart';
import '../theme/app_transitions.dart';
import 'content_screen.dart';
import 'curriculum_screen.dart';
import 'level_assessment_screen.dart';
import 'profile_screen.dart';
import 'section_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;

  Curriculum? _activeCurriculum;
  Set<String> _completedStageIds = {};

  Set<String> get _completedNodeIds {
    if (_activeCurriculum == null) return {};
    return _activeCurriculum!.nodes
        .where((n) => n.stages.every((s) => _completedStageIds.contains(s.id)))
        .map((n) => n.id)
        .toSet();
  }

  void _onCurriculumSelected(Curriculum c) {
    setState(() {
      _activeCurriculum = c;
      _completedStageIds = {};
    });
  }

  void _onTabSelected(int index) => setState(() => _selectedTabIndex = index);

  void _onNodeTap(Curriculum curriculum, CurriculumNode node) {
    Navigator.push(
      context,
      fadeRoute(SectionScreen(
        node: node,
        curriculumName: curriculum.name,
        completedStageIds: _completedStageIds,
        onStageCompleted: (id) => setState(() => _completedStageIds.add(id)),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CurriculumScreen(
        activeCurriculum: _activeCurriculum,
        completedNodeIds: _completedNodeIds,
        onCurriculumSelected: _onCurriculumSelected,
        onNodeTap: _onNodeTap,
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
}
