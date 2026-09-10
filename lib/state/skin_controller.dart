import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_palette.dart';

/// 어떤 디자인으로 그릴지 보관하고 기기에 영속화합니다.
///
/// [SharedPreferences]를 넘기지 않으면 저장 없이 메모리에서만 동작합니다
/// (테스트·프리뷰용).
class SkinController extends ChangeNotifier {
  static const _key = 'settings.skin.v1';

  final SharedPreferences? _prefs;
  AppSkin _skin;

  SkinController([SharedPreferences? prefs])
      : _prefs = prefs,
        _skin = _read(prefs);

  AppSkin get skin => _skin;

  Future<void> setSkin(AppSkin skin) async {
    if (_skin == skin) return;
    _skin = skin;
    notifyListeners();
    await _prefs?.setString(_key, skin.name);
  }

  static AppSkin _read(SharedPreferences? prefs) {
    final raw = prefs?.getString(_key);
    if (raw == null || raw.isEmpty) return AppSkin.neo;
    for (final skin in AppSkin.values) {
      if (skin.name == raw) return skin;
    }
    // 저장 형식이 깨진 경우 기본 디자인으로 시작합니다.
    return AppSkin.neo;
  }
}
