import 'i18n.dart';
import 'l10n_games.dart';
import 'l10n_screens.dart';

/// Markaziy lokalizatsiya lug'ati (uz/ru/en).
/// Foydalanish: `L10n.t('game.score')` — joriy tilga qarab matn qaytaradi.
/// Joriy til [I18n.currentLanguage] orqali aniqlanadi (AppState o'rnatadi).
/// Qo'shimcha lug'atlar: [gameStrings] (l10n_games.dart), [screenStrings]
/// (l10n_screens.dart) — to'qnashuvsiz parallel to'ldirish uchun ajratilgan.
class L10n {
  static String t(String key) {
    final lang = I18n.currentLanguage;
    return _strings[lang]?[key] ??
        gameStrings[lang]?[key] ??
        screenStrings[lang]?[key] ??
        _strings['uz']?[key] ??
        gameStrings['uz']?[key] ??
        screenStrings['uz']?[key] ??
        key;
  }

  static const Map<String, Map<String, String>> _strings = {
    'uz': {
      // Til nomlari
      'lang.uz': 'O\'zbekcha',
      'lang.ru': 'Ruscha',
      'lang.en': 'Inglizcha',
      'lang.title': 'Til',
      'lang.choose': 'Tilni tanlang',
      // Onboarding
      'onb.step.intro': 'Tanishuv',
      'onb.step.name': 'Ism',
      'onb.step.age': 'Yosh',
      'onb.step.ready': 'Tayyor',
      'onb.greeting': 'Men kamina\n{prof}\nva {maryam}.',
      'onb.question': 'Siz aqliy barkamollikka tayyormisiz?',
      'onb.start': 'Boshlash',
      'onb.nameQ': 'Ismingiz?',
      'onb.nameHint': 'sizning ismingiz',
      'onb.continue': 'Davom etish',
      'onb.ageQ': 'Yoshingiz,',
      'onb.ready': 'Tayyor,\n{name}.',
      'onb.cabinetOpen': 'KABINET OCHIQ',
      'onb.enter': 'Kirish',
      // Umumiy o'yin UI
      'game.over': 'o\'yin tugadi',
      'game.score': 'BALL',
      'game.again': 'Yana',
      'game.exit': 'Chiqish',
      'game.ready': 'Tayyor',
      'game.retry': 'Qayta urinish',
      'game.level': 'DARAJA',
      'game.bestLevel': 'Eng yuqori daraja',
      'game.bestStreak': 'Eng uzun ketma-ketlik',
      'game.rounds': 'Raundlar',
      'game.accuracy': 'Aniqlik',
      'game.correct': 'To\'g\'ri',
      'game.wrong': 'Xato',
      'game.timeout': 'Vaqt tugagan',
      // Navigatsiya / bo'limlar
      'nav.lab': 'Mashqlar',
      'nav.planet': 'Sayyora',
      'nav.chat': 'Suhbat',
      'nav.garden': 'Bog\'',
      'nav.academy': 'Akademiya',
      'nav.profile': 'Profil',
      // Maryam — yordamchi
      'profile.sec.assistant': 'Yordamchi',
      'maryam.role': 'Yordamchingiz',
      'maryam.tip1':
          'Har kuni 5 daqiqa muntazam mashq — haftada bir martalik uzun mashqdan foydaliroq.',
      'maryam.tip2':
          'Charchasangiz, biroz dam oling — tetik miya tezroq o\'rganadi.',
      'maryam.tip3':
          'Xato qilsangiz xafa bo\'lmang — miya aynan xatolardan o\'sadi.',
      'maryam.tip4':
          'Yangi narsa o\'rganish neyron bog\'lanishlarni mustahkamlaydi.',
      'maryam.tip5': 'Yetarli uyqu — xotira mustahkamlanishining asosi.',
      'maryam.tip6':
          'Avval oson, keyin qiyin — qadamba-qadam oldinga boring.',
    },
    'ru': {
      'lang.uz': 'Узбекский',
      'lang.ru': 'Русский',
      'lang.en': 'Английский',
      'lang.title': 'Язык',
      'lang.choose': 'Выберите язык',
      // Onboarding
      'onb.step.intro': 'Знакомство',
      'onb.step.name': 'Имя',
      'onb.step.age': 'Возраст',
      'onb.step.ready': 'Готово',
      'onb.greeting': 'Я — {prof}\nи {maryam}.',
      'onb.question': 'Готовы ли вы к интеллектуальному совершенству?',
      'onb.start': 'Начать',
      'onb.nameQ': 'Ваше имя?',
      'onb.nameHint': 'ваше имя',
      'onb.continue': 'Продолжить',
      'onb.ageQ': 'Ваш возраст,',
      'onb.ready': 'Готово,\n{name}.',
      'onb.cabinetOpen': 'КАБИНЕТ ОТКРЫТ',
      'onb.enter': 'Войти',
      'game.over': 'игра окончена',
      'game.score': 'ОЧКИ',
      'game.again': 'Ещё раз',
      'game.exit': 'Выход',
      'game.ready': 'Готово',
      'game.retry': 'Повторить',
      'game.level': 'УРОВЕНЬ',
      'game.bestLevel': 'Высший уровень',
      'game.bestStreak': 'Лучшая серия',
      'game.rounds': 'Раунды',
      'game.accuracy': 'Точность',
      'game.correct': 'Верно',
      'game.wrong': 'Ошибки',
      'game.timeout': 'Время вышло',
      'nav.lab': 'Упражнения',
      'nav.planet': 'Планета',
      'nav.chat': 'Чат',
      'nav.garden': 'Сад',
      'nav.academy': 'Академия',
      'nav.profile': 'Профиль',
      // Maryam — помощник
      'profile.sec.assistant': 'Помощник',
      'maryam.role': 'Ваш помощник',
      'maryam.tip1':
          'Каждый день по 5 минут полезнее, чем одна длинная тренировка в неделю.',
      'maryam.tip2': 'Устали — немного отдохните: свежий ум учится быстрее.',
      'maryam.tip3':
          'Не расстраивайтесь из-за ошибок — именно на них растёт мозг.',
      'maryam.tip4': 'Изучение нового укрепляет нейронные связи.',
      'maryam.tip5': 'Хороший сон — основа закрепления памяти.',
      'maryam.tip6':
          'Сначала лёгкое, потом сложное — двигайтесь шаг за шагом.',
    },
    'en': {
      'lang.uz': 'Uzbek',
      'lang.ru': 'Russian',
      'lang.en': 'English',
      'lang.title': 'Language',
      'lang.choose': 'Choose language',
      // Onboarding
      'onb.step.intro': 'Intro',
      'onb.step.name': 'Name',
      'onb.step.age': 'Age',
      'onb.step.ready': 'Ready',
      'onb.greeting': 'We are\n{prof}\nand {maryam}.',
      'onb.question': 'Are you ready for mental excellence?',
      'onb.start': 'Start',
      'onb.nameQ': 'Your name?',
      'onb.nameHint': 'your name',
      'onb.continue': 'Continue',
      'onb.ageQ': 'Your age,',
      'onb.ready': 'Ready,\n{name}.',
      'onb.cabinetOpen': 'OFFICE OPEN',
      'onb.enter': 'Enter',
      'game.over': 'game over',
      'game.score': 'SCORE',
      'game.again': 'Again',
      'game.exit': 'Exit',
      'game.ready': 'Ready',
      'game.retry': 'Retry',
      'game.level': 'LEVEL',
      'game.bestLevel': 'Best level',
      'game.bestStreak': 'Best streak',
      'game.rounds': 'Rounds',
      'game.accuracy': 'Accuracy',
      'game.correct': 'Correct',
      'game.wrong': 'Wrong',
      'game.timeout': 'Timed out',
      'nav.lab': 'Exercises',
      'nav.planet': 'Planet',
      'nav.chat': 'Chat',
      'nav.garden': 'Garden',
      'nav.academy': 'Academy',
      'nav.profile': 'Profile',
      // Maryam — assistant
      'profile.sec.assistant': 'Assistant',
      'maryam.role': 'Your assistant',
      'maryam.tip1': 'Five minutes every day beats one long session per week.',
      'maryam.tip2': 'Tired? Take a short break — a fresh mind learns faster.',
      'maryam.tip3':
          'Don\'t worry about mistakes — that\'s exactly how the brain grows.',
      'maryam.tip4': 'Learning something new strengthens neural connections.',
      'maryam.tip5': 'Good sleep is the foundation of memory consolidation.',
      'maryam.tip6': 'Easy first, hard later — progress step by step.',
    },
  };
}
