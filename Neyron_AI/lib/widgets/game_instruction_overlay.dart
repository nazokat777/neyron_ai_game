import 'package:flutter/material.dart';
import '../services/i18n.dart';
import '../theme/app_colors.dart';
import 'editorial.dart';

/// O'yin instruksiyalari — 3 tilli baza (uz/ru/en).
/// Kalitlar `lib/games/` fayllariga mos: shulte, memory_matrix, ...
final Map<String, Map<String, Map<String, String>>> gameLocalization = {
  'uz': {
    'shulte': {
      'title': 'Shulte jadvali',
      'basis': 'Vizual diqqat va periferik ko\'rishni rivojlantiradi.',
      'rules': 'Raqamlarni 1 dan boshlab o\'sish tartibida iloji boricha tez toping.',
    },
    'memory_matrix': {
      'title': 'Xotira matritsasi',
      'basis': 'Ishchi xotira va naqsh esda saqlashni mashq qiladi.',
      'rules': 'Yorigan kataklarni eslab qoling, so\'ng ularni aynan takrorlang.',
    },
    'dual_decision': {
      'title': 'Ikki qaror',
      'basis': 'Reaksiya tezligi va qoidaga moslashuvni rivojlantiradi.',
      'rules': 'Joriy qoidaga ko\'ra (shakl yoki rang) chap yoki o\'ng tomonni tanlang.',
    },
    'stroop': {
      'title': 'Stroop testi',
      'basis': 'Diqqat va interferensiyani yengishni mashq qiladi.',
      'rules': 'So\'zning ma\'nosiga emas, yozilgan RANGiga mos tugmani bosing.',
    },
    'quick_math': {
      'title': 'Tez hisob',
      'basis': 'Arifmetik chaqqonlik va ishchi xotirani rivojlantiradi.',
      'rules': 'Misobni vaqt tugashidan oldin yeching va to\'g\'ri javobni tanlang.',
    },
    'number_span': {
      'title': 'Raqamlar qatori',
      'basis': 'Ishchi xotira hajmini (span) rivojlantiradi.',
      'rules': 'Ko\'rsatilgan raqamlar qatorini aynan o\'sha tartibda kiriting.',
    },
    'face_match': {
      'title': 'Yuzlar',
      'basis': 'Vizual xotira — ism va yuzni bog\'lashni mashq qiladi.',
      'rules': 'Yuz va ismlarni eslab qoling, so\'ng berilgan ismga to\'g\'ri yuzni tanlang.',
    },
    'word_chain': {
      'title': 'So\'zlar zanjiri',
      'basis': 'Ketma-ketlik xotirasini rivojlantiradi.',
      'rules': 'Ekranda ketma-ket chiqqan so\'zlarni aynan o\'sha tartibda tanlang.',
    },
    'dual_nback': {
      'title': 'N-Back',
      'basis': 'Ishchi xotirani yangilashni (updating) mashq qiladi.',
      'rules': 'Hozirgi pozitsiya yoki harf N qadam oldingi bilan mos kelsa, mos tugmani bosing.',
    },
    'flanker': {
      'title': 'Oqim',
      'basis': 'Selektiv diqqat va to\'siqlarni yengishni rivojlantiradi.',
      'rules': 'Chetdagi chalg\'ituvchilarga qaramay, faqat markaziy strelka tomonini tanlang.',
    },
  },
  'ru': {
    'shulte': {
      'title': 'Таблица Шульте',
      'basis': 'Развивает зрительное внимание и периферическое зрение.',
      'rules': 'Находите числа по порядку, начиная с 1, как можно быстрее.',
    },
    'memory_matrix': {
      'title': 'Матрица памяти',
      'basis': 'Тренирует рабочую память и запоминание паттернов.',
      'rules': 'Запомните загоревшиеся клетки, затем точно повторите их.',
    },
    'dual_decision': {
      'title': 'Два решения',
      'basis': 'Развивает скорость реакции и когнитивную гибкость.',
      'rules': 'По текущему правилу (форма или цвет) выбирайте левую или правую сторону.',
    },
    'stroop': {
      'title': 'Тест Струпа',
      'basis': 'Тренирует внимание и преодоление интерференции.',
      'rules': 'Нажимайте кнопку, соответствующую ЦВЕТУ слова, а не его значению.',
    },
    'quick_math': {
      'title': 'Быстрый счёт',
      'basis': 'Развивает арифметическую беглость и рабочую память.',
      'rules': 'Решите пример до истечения времени и выберите верный ответ.',
    },
    'number_span': {
      'title': 'Ряд чисел',
      'basis': 'Развивает объём рабочей памяти (span).',
      'rules': 'Введите показанный ряд чисел точно в том же порядке.',
    },
    'face_match': {
      'title': 'Лица',
      'basis': 'Зрительная память — связывание имени и лица.',
      'rules': 'Запомните лица и имена, затем выберите лицо для заданного имени.',
    },
    'word_chain': {
      'title': 'Цепочка слов',
      'basis': 'Развивает память на последовательности.',
      'rules': 'Выберите слова в том порядке, в котором они появились на экране.',
    },
    'dual_nback': {
      'title': 'N-Back',
      'basis': 'Тренирует обновление рабочей памяти (updating).',
      'rules': 'Если позиция или буква совпадает с той, что была N шагов назад, нажмите нужную кнопку.',
    },
    'flanker': {
      'title': 'Поток',
      'basis': 'Развивает избирательное внимание и подавление помех.',
      'rules': 'Не обращая внимания на боковые стрелки, выберите направление центральной.',
    },
  },
  'en': {
    'shulte': {
      'title': 'Schulte Table',
      'basis': 'Develops visual attention and peripheral vision.',
      'rules': 'Find the numbers in ascending order starting from 1, as fast as you can.',
    },
    'memory_matrix': {
      'title': 'Memory Matrix',
      'basis': 'Trains working memory and pattern recall.',
      'rules': 'Memorize the lit cells, then reproduce them exactly.',
    },
    'dual_decision': {
      'title': 'Dual Decision',
      'basis': 'Develops reaction speed and cognitive flexibility.',
      'rules': 'Following the current rule (shape or color), choose the left or right side.',
    },
    'stroop': {
      'title': 'Stroop Test',
      'basis': 'Trains attention and interference control.',
      'rules': 'Tap the button matching the COLOR of the word, not its meaning.',
    },
    'quick_math': {
      'title': 'Quick Math',
      'basis': 'Develops arithmetic fluency and working memory.',
      'rules': 'Solve the problem before time runs out and pick the correct answer.',
    },
    'number_span': {
      'title': 'Number Span',
      'basis': 'Develops working memory span.',
      'rules': 'Enter the shown sequence of digits in the exact same order.',
    },
    'face_match': {
      'title': 'Faces',
      'basis': 'Visual memory — binding names to faces.',
      'rules': 'Memorize the faces and names, then pick the correct face for the given name.',
    },
    'word_chain': {
      'title': 'Word Chain',
      'basis': 'Develops memory for sequences.',
      'rules': 'Select the words in the exact order they appeared on the screen.',
    },
    'dual_nback': {
      'title': 'N-Back',
      'basis': 'Trains working-memory updating.',
      'rules': 'If the current position or letter matches the one N steps back, press the matching button.',
    },
    'flanker': {
      'title': 'Flow',
      'basis': 'Develops selective attention and distractor suppression.',
      'rules': 'Ignoring the flanking arrows, choose the direction of the central arrow only.',
    },
  },
};

const Map<String, String> _startLabels = {
  'uz': 'BOSHLASH',
  'ru': 'НАЧАТЬ',
  'en': 'START',
};

const Map<String, String> _howToLabels = {
  'uz': 'QOIDA',
  'ru': 'ПРАВИЛА',
  'en': 'HOW TO PLAY',
};

/// Universal o'yin-instruksiya overlay'i. Har o'yin boshlanishidan oldin
/// ko'rsatiladi; "START" bosilmaguncha o'yin jarayoni boshlanmaydi.
class GameInstructionOverlay extends StatelessWidget {
  final String gameKey;
  final VoidCallback onStart;
  final String? langCode; // berilmasa joriy til (I18n) ishlatiladi

  const GameInstructionOverlay({
    super.key,
    required this.gameKey,
    required this.onStart,
    this.langCode,
  });

  @override
  Widget build(BuildContext context) {
    final lang = langCode ?? I18n.currentLanguage;
    final data = gameLocalization[lang]?[gameKey] ??
        gameLocalization['uz']?[gameKey] ??
        const {};
    final title = data['title'] ?? '';
    final basis = data['basis'] ?? '';
    final rules = data['rules'] ?? '';
    final startLabel = _startLabels[lang] ?? 'START';
    final howTo = _howToLabels[lang] ?? 'HOW TO PLAY';

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        ),
        const Positioned.fill(
          child: DotGridBackdrop(
            spacing: 28,
            dotSize: 1.0,
            alpha: 0.06,
            child: SizedBox.expand(),
          ),
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AccentTag(label: howTo, color: AppColors.neuronGreen),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pureWhite,
                        letterSpacing: -0.025,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      basis,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.pureWhite.withValues(alpha: 0.55),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 0.5,
                      color: AppColors.pureWhite.withValues(alpha: 0.12),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      rules,
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.pureWhite,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neuronGreen,
                          foregroundColor: AppColors.cosmicDeep,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          startLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
