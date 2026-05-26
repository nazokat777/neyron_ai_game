import 'dart:ui';

/// Oddiy lokalizatsiya — keyinroq to'liq intl bilan almashtiriladi
class I18n {
  static String get currentLanguage {
    final code = PlatformDispatcher.instance.locale.languageCode;
    if (code == 'ru') return 'ru';
    if (code == 'en') return 'en';
    return 'uz';
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
