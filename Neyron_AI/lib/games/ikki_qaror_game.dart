import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/user_profile.dart';

enum Difficulty { easy, medium, hard }

enum Language { uz, ru, en }

// Avatar-style Ikki Qaror game screen located in lib/games/
// This file intentionally only reads image assets (Professor/Maryam) and
// does not modify them in any way — images remain perfectly safe on disk.

class IkkiQarorGameScreen extends StatefulWidget {
  const IkkiQarorGameScreen({super.key});

  @override
  State<IkkiQarorGameScreen> createState() => _IkkiQarorGameScreenState();
}

class _IkkiQarorGameScreenState extends State<IkkiQarorGameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;
  final List<Offset> _particles = [];
  final List<double> _speeds = [];
  final Random _random = Random();

  int _currentQuestionIndex = 0;
  // Difficulty and dynamic pools
  Difficulty _difficulty = Difficulty.medium;
  bool _useProfileDifficulty = true; // when true, read from AppState.profile
  // Language (default Uzbek)
  Language _language = Language.uz;

  List<Map<String, Map<String, String>>> get _questions {
    switch (_difficulty) {
      case Difficulty.easy:
        return _easyQuestions;
      case Difficulty.medium:
        return _mediumQuestions;
      case Difficulty.hard:
        return _hardQuestions;
    }
  }

  // Simple curated pools for each difficulty
  // Each question is a map of language -> {question, optionA, optionB}
  final List<Map<String, Map<String, String>>> _easyQuestions = [
    {
      'uz': {
        'question': 'Dars qilish vs Tv ko\'rish',
        'optionA': 'Dars qilish',
        'optionB': 'TV ko\'rish'
      },
      'ru': {
        'question': 'Учиться vs Смотреть ТВ',
        'optionA': 'Учиться',
        'optionB': 'Смотреть ТВ'
      },
      'en': {'question': 'Study vs Watch TV', 'optionA': 'Study', 'optionB': 'Watch TV'},
    },
  ];

  final List<Map<String, Map<String, String>>> _mediumQuestions = [
    {
      'uz': {'question': 'Avtobus vs Taksi', 'optionA': 'Avtobus', 'optionB': 'Taksi'},
      'ru': {'question': 'Автобус vs Такси', 'optionA': 'Автобус', 'optionB': 'Такси'},
      'en': {'question': 'Bus vs Taxi', 'optionA': 'Bus', 'optionB': 'Taxi'},
    },
  ];

  final List<Map<String, Map<String, String>>> _hardQuestions = [
    {
      'uz': {
        'question': 'Kosmik stansiyada kislorod tizimi buzildi. Qaysi qarorni qabul qilasiz?',
        'optionA': 'Zaxira generatorni yoqish (Tavakkal)',
        'optionB': 'Ekipajni evakuatsiya qilish (Xavfsiz)'
      },
      'ru': {
        'question': 'На космической станции отказала система кислорода. Какой вы примете выбор?',
        'optionA': 'Включить резервный генератор (Риск)',
        'optionB': 'Эвакуировать экипаж (Безопасно)'
      },
      'en': {
        'question': 'The space station oxygen system failed. What do you choose?',
        'optionA': 'Start backup generator (Risk)',
        'optionB': 'Evacuate crew (Safe)'
      }
    },
    {
      'uz': {
        'question': "Noma'lum sayyoradan biolyuminessent signal kelmoqda. Nima qilasiz?",
        'optionA': 'Signal manbasini qidirish',
        'optionB': 'Xavfsiz masofaga uzoqlashish'
      },
      'ru': {
        'question': 'С неизвестной планеты поступает биолюминесцентный сигнал. Что вы сделаете?',
        'optionA': 'Исследовать источник сигнала',
        'optionB': 'Отойти на безопасное расстояние'
      },
      'en': {
        'question': 'A bioluminescent signal is coming from an unknown planet. What do you do?',
        'optionA': 'Investigate the signal source',
        'optionB': 'Move to a safe distance'
      }
    },
  ];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();

    // Optimized: modest particle count with depth speeds
    for (int i = 0; i < 28; i++) {
      _particles.add(Offset(_random.nextDouble(), _random.nextDouble()));
      _speeds.add(0.3 + _random.nextDouble() * 1.4);
    }
    // default difficulty remains medium; will be overridden in didChangeDependencies if profile exists
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.profile != null && _useProfileDifficulty) {
      final ageGroup = appState.profile!.ageGroup;
      // Map age groups to difficulty
      setState(() {
        if (ageGroup == AgeGroup.child || ageGroup == AgeGroup.youngTeen) {
          _difficulty = Difficulty.easy;
        } else if (ageGroup == AgeGroup.teen || ageGroup == AgeGroup.adult) {
          _difficulty = Difficulty.medium;
        } else {
          _difficulty = Difficulty.hard;
        }
        _currentQuestionIndex = 0;
      });
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _nextQuestion() => setState(() => _currentQuestionIndex = (_currentQuestionIndex + 1) % _questions.length);

  void _setDifficulty(Difficulty d, {bool useProfile = false}) {
    setState(() {
      _difficulty = d;
      _useProfileDifficulty = useProfile;
      _currentQuestionIndex = 0;
      _refreshQuestions();
    });
  }

  // Active (shuffled) questions shown to user
  List<Map<String, Map<String, String>>> _activeQuestions = [];

  void _refreshQuestions() {
    _activeQuestions = List.from(_questions);
    _activeQuestions.shuffle(_random);
    if (_currentQuestionIndex >= _activeQuestions.length) _currentQuestionIndex = 0;
  }

  // UI translations
  String get _labelQuestion {
    switch (_language) {
      case Language.uz:
        return 'SAVOL';
      case Language.ru:
        return 'ВОПРОС';
      case Language.en:
      default:
        return 'QUESTION';
    }
  }

  String get _labelAutoDifficulty {
    switch (_language) {
      case Language.uz:
        return 'Avtomatik qiyinchilik';
      case Language.ru:
        return 'Авто сложность';
      case Language.en:
      default:
        return 'Auto difficulty';
    }
  }

  String get _labelMissionStatus {
    switch (_language) {
      case Language.uz:
        return 'MISSIYA HOLATI: FAOL';
      case Language.ru:
        return 'СТАТУС МИССИИ: АКТИВНО';
      case Language.en:
      default:
        return 'MISSION STATUS: ACTIVE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQuestionIndex];
    final loc = q[_language.name]!;

    return Scaffold(
      body: Stack(
        children: [
          // Deep black space with subtle vignette
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.2, -0.4),
                radius: 1.2,
                colors: [Color(0xFF000005), Color(0xFF020914), Color(0xFF001018)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Neon cyan shapes (soft) and optimized particle layer
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) => CustomPaint(
                size: Size.infinite,
                painter: _AvatarCosmicPainter(_particles, _speeds, _particleController.value),
              ),
            ),
          ),

          // UI layer: safe area + content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00F0FF)),
                      ),
                      Text(
                        _labelMissionStatus,
                        style: TextStyle(
                          color: const Color(0xFF00F0FF).withOpacity(0.9),
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Difficulty selector: Auto (profile) switch + segmented control
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Switch(
                              value: _useProfileDifficulty,
                              activeColor: const Color(0xFF00F0FF),
                              onChanged: (v) {
                                setState(() {
                                  _useProfileDifficulty = v;
                                  if (v) {
                                    final appState = Provider.of<AppState>(context, listen: false);
                                    if (appState.profile != null) {
                                      final ag = appState.profile!.ageGroup;
                                      if (ag == AgeGroup.child || ag == AgeGroup.youngTeen) _difficulty = Difficulty.easy;
                                      else if (ag == AgeGroup.teen || ag == AgeGroup.adult) _difficulty = Difficulty.medium;
                                      else _difficulty = Difficulty.hard;
                                    }
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 6),
                            Text(_labelAutoDifficulty, style: const TextStyle(color: Color(0xFF00F0FF), fontFamily: 'Courier')),
                          ],
                        ),
                      ),
                      ToggleButtons(
                        isSelected: [
                          _difficulty == Difficulty.easy,
                          _difficulty == Difficulty.medium,
                          _difficulty == Difficulty.hard,
                        ],
                        onPressed: (i) {
                          // Manual override disables auto
                          setState(() {
                            _useProfileDifficulty = false;
                            _difficulty = Difficulty.values[i];
                            _currentQuestionIndex = 0;
                          });
                        },
                        borderColor: const Color(0xFF00F0FF),
                        selectedBorderColor: const Color(0xFF00F0FF),
                        fillColor: const Color(0xFF00F0FF).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Easy')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Medium')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Hard')),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Top neon arc and protected character images
                  // Language selector + character images
                  Row(
                    children: [
                      // Language selector
                      ToggleButtons(
                        isSelected: [
                          _language == Language.uz,
                          _language == Language.ru,
                          _language == Language.en,
                        ],
                        onPressed: (i) {
                          setState(() {
                            _language = Language.values[i];
                          });
                        },
                        borderColor: const Color(0xFF00F0FF),
                        selectedBorderColor: const Color(0xFF00F0FF),
                        fillColor: const Color(0xFF00F0FF).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('UZ')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('RU')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('EN')),
                        ],
                      ),
                      const Spacer(),
                      // Professor image (if present) - only loaded, not modified
                      _SafeCharacterImage('assets/images/professor.png'),
                      const SizedBox(width: 12),
                      // Maryam image (if present)
                      _SafeCharacterImage('assets/images/maryam.png'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Question card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF001924).withOpacity(0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.36), width: 1.2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_labelQuestion: ${_currentQuestionIndex + 1}/${_questions.length}',
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  color: Color(0xFF00F0FF),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.6,
                                )),
                            const SizedBox(height: 12),
                            // localized question text
                            Text(
                              loc['question']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Buttons
                  _AvatarNeonButton(text: loc['optionA']!, onPressed: _nextQuestion, color: const Color(0xFF00F0FF)),
                  const SizedBox(height: 14),
                  _AvatarNeonButton(text: loc['optionB']!, onPressed: _nextQuestion, color: const Color(0xFF7BFFB2)),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Safe image loader: only displays the asset if it exists; does not modify files.
class _SafeCharacterImage extends StatelessWidget {
  final String assetPath;

  const _SafeCharacterImage(this.assetPath, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: const Color(0xFF00131A),
            child: const Icon(Icons.person, color: Color(0xFF00F0FF)),
          ),
        ),
      ),
    );
  }
}

// Neon button used in games/ folder
class _AvatarNeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _AvatarNeonButton({required this.text, required this.onPressed, required this.color, super.key});

  @override
  State<_AvatarNeonButton> createState() => _AvatarNeonButtonState();
}

class _AvatarNeonButtonState extends State<_AvatarNeonButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(_) => _c.forward();
  void _up(_) {
    _c.reverse();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: () => _c.reverse(),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final v = _c.value;
          return Transform.scale(
            scale: 1 - 0.03 * v,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF001214).withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withOpacity(0.4), width: 1.0),
                boxShadow: [
                  BoxShadow(color: widget.color.withOpacity(0.15 + 0.25 * v), blurRadius: 12 + 12 * v, spreadRadius: 1 * v),
                ],
              ),
              child: Center(
                child: Text(widget.text, style: TextStyle(fontFamily: 'Courier', color: widget.color, fontWeight: FontWeight.w700)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Painter tuned for performance and Avatar-like glow
class _AvatarCosmicPainter extends CustomPainter {
  final List<Offset> points;
  final List<double> speeds;
  final double t;

  _AvatarCosmicPainter(this.points, this.speeds, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final core = Paint()..color = const Color(0xFFBFFBF0)..style = PaintingStyle.fill;
    final glow = Paint()..color = const Color(0xFF00F0FF).withOpacity(0.12)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    final halo = Paint()..color = const Color(0xFF00F0FF).withOpacity(0.06)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final s = speeds[i];
      final dx = (p.dx * size.width + (t * 200 * (p.dx > 0.5 ? 1 : -1) * s)) % size.width;
      final dy = (p.dy * size.height + (t * 260 * s)) % size.height;
      final pos = Offset(dx, dy);

      canvas.drawCircle(pos, 18.0 * (0.6 + 0.6 * s), halo);
      canvas.drawCircle(pos, 8.0 * (0.7 + 0.5 * s), glow);
      canvas.drawCircle(pos, 2.2, core);
    }
  }

  @override
  bool shouldRepaint(covariant _AvatarCosmicPainter old) => old.t != t || old.points.length != points.length;
}
