import 'package:flutter/material.dart';
import '../models/content.dart';
import '../services/content_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

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
      barrierColor: AppColors.scrim,
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
            padding: const EdgeInsets.all(AppSpacing.md),
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
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s20, AppSpacing.s20, AppSpacing.s14),
      decoration: headerDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('컨텐츠', style: AppTextStyles.displayMedium),
          SizedBox(height: AppSpacing.xs),
          Text('전체 학습 컨텐츠를 확인하세요', style: AppTextStyles.bodySmallMuted(context)),
        ],
      ),
    );
  }

  Widget _buildSubjectTabs() {
    return Container(
      height: AppSpacing.tabHeight,
      color: AppColors.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.s7),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.s18),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.blue : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.s20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.blue
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Center(
                  child: Text(
                    _subjects[index].name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
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

// ── Chapter card ─────────────────────────────────────────────

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
        margin: const EdgeInsets.only(bottom: AppSpacing.s12),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: card3D(context),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.blue900,
                borderRadius: BorderRadius.circular(AppSpacing.rMd),
                border: Border.all(color: AppColors.blue700),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: AppSpacing.md,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    chapter.description,
                    style: AppTextStyles.bodySmallMuted(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: AppColors.textDimmed),
          ],
        ),
      ),
    );
  }
}

// ── Chapter popup ────────────────────────────────────────────

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
      insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.s40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.rXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20, AppSpacing.s20, AppSpacing.sm, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.chapter.title,
                      style: AppTextStyles.headingMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    constraints: const BoxConstraints(
                        minWidth: AppSpacing.s40, minHeight: AppSpacing.s40),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20, AppSpacing.xs, AppSpacing.s20, AppSpacing.s14),
              child: Text(
                widget.chapter.description,
                style: AppTextStyles.bodySmallMuted(context),
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.s14),
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

// ── Section card ─────────────────────────────────────────────

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
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s14, AppSpacing.s12, AppSpacing.sm, AppSpacing.s12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.title, style: AppTextStyles.titleSmall),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        section.description,
                        style: AppTextStyles.captionMuted(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s10, vertical: AppSpacing.s5),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? AppColors.blue900
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.rSm),
                      border: Border.all(
                        color: isExpanded
                            ? AppColors.blue300
                            : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      isExpanded ? '접기' : '펼치기',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isExpanded
                            ? AppColors.blue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: section.stages
                    .map(
                      (stage) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s14, vertical: AppSpacing.s6),
                        child: Row(
                          children: [
                            Container(
                              width: AppSpacing.s6,
                              height: AppSpacing.s6,
                              decoration: BoxDecoration(
                                color: AppColors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            Text(
                              stage.title,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textPrimary),
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
