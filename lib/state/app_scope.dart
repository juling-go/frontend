import 'package:flutter/widgets.dart';

import 'auth_repository.dart';
import 'progress_repository.dart';

/// 앱 전역 저장소를 위젯 트리에 노출합니다.
///
/// 저장소 인스턴스 자체는 앱 수명 동안 바뀌지 않으므로, 화면은
/// [AppScope.of]로 저장소를 얻은 뒤 `ListenableBuilder`로 변경을 구독합니다.
///
/// ```dart
/// final progress = AppScope.of(context).progress;
/// return ListenableBuilder(
///   listenable: progress,
///   builder: (context, _) => Text('${progress.totalCompletedStages}'),
/// );
/// ```
class AppScope extends InheritedWidget {
  final AuthRepository auth;
  final ProgressRepository progress;

  const AppScope({
    super.key,
    required this.auth,
    required this.progress,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope를 위젯 트리에서 찾을 수 없습니다.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return auth != oldWidget.auth || progress != oldWidget.progress;
  }
}
