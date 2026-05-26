import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';

/// Ikki qaror — reaksiya tezligi + qoida o'zgarishiga moslashish
/// Ilmiy asos: choice reaction time + cognitive flexibility (anterior cingulate)
class DualDecisionGame extends StatefulWidget {
  const DualDecisionGame({super.key});

  @override
  State<DualDecisionGame> createState() => _DualDecisionGameState();
}

enum _Shape { circle, square }

enum _Rule { byShape, byColor }

class _Stimulus {
  final _Shape shape;
  final bool isWarm;
  const _Stimulus({required this.shape, required this.isWarm});
}

class _DualDecisionGameState extends State<DualDecisionGame>
    with SingleTickerProviderStateMixin {
  static const int totalRounds = 20;
  static const int rulesChangeEvery = 5;

  // Progressive difficulty constants
  static const Duration _baseTimeLimit = Duration(milliseconds: 2400);
  static const Duration _minTimeLimit = Duration(milliseconds: 700);
  static const double _decayPerLevel = 0.9; // 10% qisqarish har darajada
  static const int _scoreStepPerLevel = 5; // har 5 to'g'ri javobda +1 daraja
  static const double _fakeBannerProb = 0.18;

  final Random _rng = Random();
  late _Stimulus _stim;
  late _Rule _rule;
  int _round = 0;
  int _correct = 0;
  int _wrong = 0;
  Duration _totalReaction = Duration.zero;
  bool _finished = false;
  bool? _flashCorrect;
  String? _flashSide;
  DateTime _roundStart = DateTime.now();
  bool _ruleJustChanged = false;

  // Progressive difficulty state
  int _level = 1;
  Duration _currentTimeLimit = _baseTimeLimit;
  late final AnimationController _timeController;
  _Stimulus? _decoyStim;
  Alignment _decoyAlign = Alignment.topLeft;
  String? _ghostSide; // soxta "noto'g'ri" signal (qisqa flash)
  int _timeoutCount = 0;

  @override
  void initState() {
    super.initState();
    _timeController = AnimationController(
      vsync: this,
      duration: _baseTimeLimit,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            _flashCorrect == null &&
            !_finished &&
            mounted) {
          _onTimeout();
        }
      });
    _rule = _Rule.values[_rng.nextInt(_Rule.values.length)];
    _nextRound();
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  void _nextRound() {
    _recomputeDifficulty();

    final isScheduledRuleChange =
        _round > 0 && _round % rulesChangeEvery == 0;
    if (isScheduledRuleChange) {
      _rule = _rule == _Rule.byShape ? _Rule.byColor : _Rule.byShape;
      _ruleJustChanged = true;
    } else if (_level >= 3 && _rng.nextDouble() < _fakeBannerProb) {
      // Yuqori darajada: soxta "YANGI QOIDA" banneri — qoida o'zgarmaydi
      _ruleJustChanged = true;
    } else {
      _ruleJustChanged = false;
    }

    setState(() {
      _stim = _Stimulus(
        shape: _Shape.values[_rng.nextInt(_Shape.values.length)],
        isWarm: _rng.nextBool(),
      );
      _flashCorrect = null;
      _flashSide = null;
      _roundStart = DateTime.now();
      _decoyStim = _rollDecoy();
      _ghostSide = _rollGhostSignal();
    });

    _startRoundTimer();
    _scheduleGhostClear();
  }

  /// Daraja va vaqt cheklovini qayta hisoblaydi.
  /// Daraja = 1 + (to'g'ri javoblar / 5).
  /// Vaqt = base * 0.9^(level-1), [_minTimeLimit, _baseTimeLimit] ga clamp.
  void _recomputeDifficulty() {
    _level = 1 + (_correct ~/ _scoreStepPerLevel);
    final ms = (_baseTimeLimit.inMilliseconds *
            pow(_decayPerLevel, _level - 1))
        .round();
    _currentTimeLimit = Duration(
      milliseconds: ms.clamp(
        _minTimeLimit.inMilliseconds,
        _baseTimeLimit.inMilliseconds,
      ),
    );
  }

  /// Chalg'ituvchi shakl: 2-darajadan boshlab paydo bo'ladi.
  /// Ehtimol = 0.25 + (level - 2) * 0.15, max 0.80.
  _Stimulus? _rollDecoy() {
    if (_level < 2) return null;
    final p = (0.25 + (_level - 2) * 0.15).clamp(0.0, 0.80);
    if (_rng.nextDouble() >= p) return null;
    _decoyAlign = const [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.bottomRight,
    ][_rng.nextInt(4)];
    return _Stimulus(
      shape: _Shape.values[_rng.nextInt(2)],
      isWarm: _rng.nextBool(),
    );
  }

  /// Soxta "to'g'ri javob shu tomonda" signali — 4-darajadan boshlab.
  /// Foydalanuvchini noto'g'ri tomonga undashga urinadi.
  String? _rollGhostSignal() {
    if (_level < 4) return null;
    if (_rng.nextDouble() >= 0.30) return null;
    // Aniq noto'g'ri tomonni tanlaymiz
    return _correctSide() == 'L' ? 'R' : 'L';
  }

  void _scheduleGhostClear() {
    if (_ghostSide == null) return;
    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() => _ghostSide = null);
    });
  }

  void _startRoundTimer() {
    _timeController.stop();
    _timeController.duration = _currentTimeLimit;
    _timeController.reset();
    _timeController.forward();
  }

  void _onTimeout() {
    if (_flashCorrect != null || _finished) return;
    _timeController.stop();
    _totalReaction += _currentTimeLimit;
    setState(() {
      _flashCorrect = false;
      _flashSide = null;
      _wrong++;
      _timeoutCount++;
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      _round++;
      if (_round >= totalRounds) {
        _finish();
      } else {
        _nextRound();
      }
    });
  }

  String _correctSide() {
    if (_rule == _Rule.byShape) {
      return _stim.shape == _Shape.circle ? 'L' : 'R';
    } else {
      return _stim.isWarm ? 'L' : 'R';
    }
  }

  void _onTap(String side) {
    if (_flashCorrect != null || _finished) return;
    _timeController.stop();
    final correct = side == _correctSide();
    _totalReaction += DateTime.now().difference(_roundStart);
    setState(() {
      _flashSide = side;
      _flashCorrect = correct;
      if (correct) {
        _correct++;
      } else {
        _wrong++;
      }
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      _round++;
      if (_round >= totalRounds) {
        _finish();
      } else {
        _nextRound();
      }
    });
  }

  Future<void> _finish() async {
    _timeController.stop();
    setState(() => _finished = true);
    final state = context.read<AppState>();
    await state.incrementSessions();
    final avgMs = totalRounds > 0
        ? _totalReaction.inMilliseconds / totalRounds
        : 0;
    final accuracy = _correct / totalRounds;
    final accBonus = (accuracy * 15).round();
    final speedBonus = avgMs < 800
        ? 15
        : avgMs < 1200
            ? 10
            : avgMs < 1800
                ? 5
                : 0;
    // Yuqori darajaga yetib borgan o'yinchi qo'shimcha mukofot oladi
    final levelBonus = (_level - 1) * 3;
    final coins =
        (5 + accBonus + speedBonus + levelBonus).clamp(1, 60);
    await state.addCoins(coins);
  }

  void _restart() {
    _timeController.stop();
    setState(() {
      _round = 0;
      _correct = 0;
      _wrong = 0;
      _totalReaction = Duration.zero;
      _finished = false;
      _level = 1;
      _currentTimeLimit = _baseTimeLimit;
      _decoyStim = null;
      _ghostSide = null;
      _timeoutCount = 0;
      _rule = _Rule.values[_rng.nextInt(_Rule.values.length)];
    });
    _nextRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qaror'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
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
            child: _finished ? _resultView() : _playView(),
          ),
        ],
      ),
    );
  }

  Widget _playView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _statusBar(),
        const SizedBox(height: 20),
        _ruleBanner(),
        Expanded(child: _playArea()),
      ],
    );
  }

  Widget _statusBar() {
    final progress = _round / totalRounds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_round + 1).toString().padLeft(2, '0')} / $totalRounds',
                style: TextStyle(
                  color: AppColors.pureWhite.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Row(
                children: [
                  Text(
                    '$_correct',
                    style: const TextStyle(
                      color: AppColors.neuronGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    ' · $_wrong',
                    style: const TextStyle(
                      color: AppColors.accentRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: AnimatedBuilder(
              animation: _timeController,
              builder: (context, _) {
                // Round progress (qatlam 1) — past, statik
                // Time remaining (qatlam 2) — yuqori, har raundda yangilanadi
                final timeLeft =
                    (1.0 - _timeController.value).clamp(0.0, 1.0);
                final urgent = _timeController.value > 0.70;
                return Stack(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 2,
                      backgroundColor: AppColors.cosmicMid,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.pureWhite.withValues(alpha: 0.18),
                      ),
                    ),
                    LinearProgressIndicator(
                      value: timeLeft,
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        urgent ? AppColors.accentRed : AppColors.neuronGreen,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleBanner() {
    final byShape = _rule == _Rule.byShape;
    final left = byShape ? 'DOIRA' : 'ILIQ';
    final right = byShape ? 'KVADRAT' : 'SOVUQ';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (_ruleJustChanged)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.plasmaYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'YANGI QOIDA',
                  style: TextStyle(
                    color: AppColors.plasmaYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ).animate().fadeIn(duration: 200.ms).scale(
                  begin: const Offset(0.85, 0.85), curve: Curves.easeOutQuart),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                left,
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '←',
                style: TextStyle(
                  color: AppColors.pureWhite.withValues(alpha: 0.5),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '|',
                style: TextStyle(
                  color: AppColors.pureWhite.withValues(alpha: 0.25),
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 20),
              Text(
                '→',
                style: TextStyle(
                  color: AppColors.pureWhite.withValues(alpha: 0.5),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                right,
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playArea() {
    final stimColor =
        _stim.isWarm ? AppColors.plasmaYellow : AppColors.neuronGreen;
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: _tapZone('L')),
            Container(
              width: 0.5,
              color: AppColors.pureWhite.withValues(alpha: 0.08),
            ),
            Expanded(child: _tapZone('R')),
          ],
        ),
        if (_decoyStim != null)
          Align(
            alignment: _decoyAlign,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Opacity(
                opacity: 0.30,
                child: _decoyShapeView(_decoyStim!),
              ),
            ),
          ),
        Center(
          child: _shapeView(stimColor)
              .animate(key: ValueKey('stim-$_round'))
              .fadeIn(duration: 180.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                duration: 240.ms,
                curve: Curves.easeOutQuart,
              ),
        ),
      ],
    );
  }

  Widget _decoyShapeView(_Stimulus s) {
    const size = 52.0;
    final color = s.isWarm ? AppColors.plasmaYellow : AppColors.neuronGreen;
    if (s.shape == _Shape.circle) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _shapeView(Color color) {
    const size = 220.0;
    if (_stim.shape == _Shape.circle) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
  }

  Widget _tapZone(String side) {
    final isFlash = _flashSide == side;
    final flashColor = _flashCorrect == true
        ? AppColors.neuronGreen
        : AppColors.accentRed;
    // Ghost (soxta) signal — qisqa fursat noto'g'ri tomonni "yoritadi"
    final isGhost = _ghostSide == side && !isFlash;
    return GestureDetector(
      onTap: () => _onTap(side),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isFlash
              ? flashColor.withValues(alpha: 0.18)
              : isGhost
                  ? AppColors.pureWhite.withValues(alpha: 0.05)
                  : Colors.transparent,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _resultView() {
    final accuracy = (_correct / totalRounds * 100).round();
    final avgMs = totalRounds > 0
        ? (_totalReaction.inMilliseconds / totalRounds).round()
        : 0;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'reaksiya',
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$avgMs',
                style: const TextStyle(
                  fontSize: 128,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neuronGreen,
                  letterSpacing: -0.04,
                  height: 1.0,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'ms',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neuronGreen.withValues(alpha: 0.6),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutQuart),
          const SizedBox(height: 48),
          _statRow('Aniqlik', '$accuracy%'),
          const SizedBox(height: 10),
          _statRow('To\'g\'ri', '$_correct / $totalRounds'),
          const SizedBox(height: 10),
          _statRow('Xato', '$_wrong'),
          const SizedBox(height: 10),
          _statRow('Eng yuqori daraja', '$_level'),
          if (_timeoutCount > 0) ...[
            const SizedBox(height: 10),
            _statRow('Vaqt tugagan', '$_timeoutCount'),
          ],
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _restart,
                child: const Text('Yana'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.pureWhite,
                  side: BorderSide(
                      color: AppColors.pureWhite.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Chiqish'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.pureWhite.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.55),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.pureWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
