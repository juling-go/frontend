import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class LevelAssessmentScreen extends StatelessWidget {
  const LevelAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '수준평가 뷰\nPlaceholder',
        textAlign: TextAlign.center,
        style: AppTextStyles.headingMedium,
      ),
    );
  }
}
