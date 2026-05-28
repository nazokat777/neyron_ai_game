import 'dart:ui';

/// Oddiy lokalizatsiya — keyinroq to'liq intl bilan almashtiriladi
class I18n {
  /// Foydalanuvchi tanlagan til (AppState o'rnatadi). null bo'lsa — qurilma tili.
  static String? _override;
  static set override(String? code) => _override = code;

  /// Qurilma tili (override yo'q paytda fallback)
  static String get deviceLanguage {
    final code = PlatformDispatcher.instance.locale.languageCode;
    if (code == 'ru') return 'ru';
    if (code == 'en') return 'en';
    return 'uz';
  }

  static String get currentLanguage {
    final o = _override;
    if (o == 'uz' || o == 'ru' || o == 'en') return o!;
    return deviceLanguage;
  }

  /// Maryam — Professorning yosh shogirdi
  static String get maryamName {
    switch (currentLanguage) {
      case 'ru':
        return 'Мария';
      default:
        return 'Maryam';
    }
  }

  /// Professor — neyroshunoslik mutaxassisi
  static String get professorName {
    switch (currentLanguage) {
      case 'ru':
        return 'Профессор';
      default:
        return 'Professor';
    }
  }
}
