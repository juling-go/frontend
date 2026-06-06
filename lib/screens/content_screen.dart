import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/content_service.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({
    super.key,
    this.service = const MockContentService(),
  });

  final ContentService service;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<ContentSubject> _subjects = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final subjects = await widget.service.fetchSubjects();
      setState(() {
        _subjects = subjects;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('컨텐츠를 불러오는데 실패했습니다')),
        );
      }
    }
  }

  void _openChapterPopup(ContentChapter chapter) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ChapterPopup(chapter: chapter),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_subjects.isEmpty) {
      return const Center(child: Text('표시할 컨텐츠가 없습니다'));
    }

    final chapters = _subjects[_selectedIndex].chapters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSubjectTabs(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            itemBuilder: (context, index) => _ChapterCard(
              chapter: chapters[index],
              index: index + 1,
              onTap: () => _openChapterPopup(chapters[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('컨텐츠', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('전체 학습 컨텐츠를 확인하세요',
              style: TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildSubjectTabs() {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    _subjects[index].name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Chapter card ---

class _ChapterCard extends StatelessWidget {
  final ContentChapter chapter;
  final int index;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.07),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chapter.description,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// --- Chapter popup ---

class _ChapterPopup extends StatefulWidget {
  final ContentChapter chapter;
  const _ChapterPopup({required this.chapter});

  @override
  State<_ChapterPopup> createState() => _ChapterPopupState();
}

class _ChapterPopupState extends State<_ChapterPopup> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.chapter.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: const EdgeInsets.all(8),
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Text(
                widget.chapter.description,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(14),
                shrinkWrap: true,
                itemCount: widget.chapter.sections.length,
                itemBuilder: (context, index) {
                  final isExpanded = _expanded.contains(index);
                  return _SectionCard(
                    section: widget.chapter.sections[index],
                    isExpanded: isExpanded,
                    onToggle: () => setState(() {
                      isExpanded
                          ? _expanded.remove(index)
                          : _expanded.add(index);
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Section card ---

class _SectionCard extends StatelessWidget {
  final ContentSection section;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SectionCard({
    required this.section,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        section.description,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? Colors.blue.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpanded
                            ? Colors.blue.shade200
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      isExpanded ? '접기' : '펼치기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isExpanded ? Colors.blue : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: section.stages
                    .map(
                      (stage) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              stage.title,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
