import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';
import 'adaptive_flow_engine.dart';

/// Stroop testi — so'z va uning rangi o'rtasidagi ziddiyatni yengish
/// Ilmiy asos: J.R. Stroop (1935), prefrontal cortex inhibition
/// Cheksiz adaptiv rejim: daraja oshgani sayin vaqt qisqaradi va ziddiyat kuchayadi
class StroopGame extends StatefulWidget {
  const StroopGame({super.key});

  @override
  State<StroopGame> createState() => _StroopGameState();
}

class _GameColor {
  /// Lokalizatsiya kaliti (masalan 'stroop.red'). Solishtirish uchun ham
  /// ishlatiladi (har rang uchun noyob), ekranda L10n.t orqali tarjima qilinadi.
  final String nameKey;
  final Color value;
  const _GameColor(this.nameKey, this.value);
}

class _Round {
  final _GameColor word;
  final _GameColor ink;
  const _Round({required this.word, required this.ink});
}

class _StroopGameState extends State<StroopGame> {
  static const List<_GameColor> palette = [
    _GameColor('stroop.red', AppColors.gameRed),
    _GameColor('stroop.blue', AppColors.gameBlue),
    _GameColor('stroop.green', AppColors.gameGreen),
    _GameColor('stroop.yellow', AppColors.gameYellow),
  ];

  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(
    rtThreshold: 0.9,
    maxLatency: 999,
    alpha: 0.10,
    beta: 0.16,
  );

  late _Round _current;
  int? _flashIndex;
  bool? _flashCorrect;
  bool _finished = false;
  bool _levelUp = false;

  double _roundSeconds = 2.5;
  double _timeLeft = 2.5;
  DateTime _roundStart = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // D dan (daraja) raund vaqt byudjetini hisoblaydi (cheksiz qisqaradi, 700ms pol)
  int get _timeLimitMs => max(700, 2500 - (_engine.level - 1) * 150);

  // Daraja oshgani sayin ink ≠ so'z ehtimoli oshadi
  double get _conflictProbability =>
      min(0.92, 0.55 + (_engine.level - 1) * 0.05);

  void _nextRound() {
    final word = palette[_rng.nextInt(palette.length)];
    final shouldDiffer = _rng.nextDouble() < _conflictProbability;
    _GameColor ink;
    if (shouldDiffer) {
      do {
        ink = palette[_rng.nextInt(palette.length)];
      } while (ink.nameKey == word.nameKey);
    } else {
      ink = word;
    }
    _roundSeconds = _timeLimitMs / 1000.0;
    setState(() {
      _current = _Round(word: word, ink: ink);
      _flashIndex = null;
      _flashCorrect = null;
      _levelUp = false;
      _timeLeft = _roundSeconds;
      _roundStart = DateTime.now();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      setState(() => _timeLeft -= 0.1);
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (_flashIndex != null || _finished) return;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: false);
    setState(() {
      _flashIndex = -1;
      _flashCorrect = false;
      _levelUp = _engine.level > prevLevel;
    });
    HapticFeedback.heavyImpact();
    _timer = Timer(const Duration(milliseconds: 600), _advance);
  }

  void _onTap(int index) {
    if (_flashIndex != null || _finished) return;
    _timer?.cancel();
    final chosen = palette[index];
    final correct = chosen.nameKey == _current.ink.nameKey;
    final rt = DateTime.now().difference(_roundStart).inMilliseconds / 1000.0;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: rt);
    setState(() {
      _flashIndex = index;
      _flashCorrect = correct;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _timer = Timer(const Duration(milliseconds: 480), _advance);
  }

  void _advance() {
    if (!mounted) return;
    if (_engine.isGameOver) {
      _finish();
    } else {
      _nextRound();
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    setState(() => _finished = true);
    final state = context.read<AppState>();
    await state.incrementSessions();
    final coins = (5 + _engine.bestStreak * 2 + _engine.level * 2).clamp(1, 80);
    await state.addCoins(coins);
  }

  void _restart() {
    _timer?.cancel();
    _engine.reset();
    setState(() => _finished = false);
    _nextRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('stroop.title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 14), child: Center(child: BrainMark(size: 22)))],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
          ),
          const Positioned.fill(child: NeuralBackdrop(intensity: 0.45)),
          // Full-screen flash overlay on feedback
          if (_flashCorrect != null)
            AnimatedOpacity(
              opacity: 0.12,
              duration: const Duration(milliseconds: 150),
              child: ColoredBox(
                color: _flashCorrect == true
                    ? AppColors.neuronGreen
                    : AppColors.accentRed,
                child: const SizedBox.expand(),
              ),
            ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: _finished ? _resultView() : _playView(),
              ),
            ),
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
        Expanded(child: Center(child: _wordDisplay())),
        _colorButtons(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _statusBar() {
    final timeFrac =
        _roundSeconds > 0 ? (_timeLeft / _roundSeconds).clamp(0.0, 1.0) : 0.0;
    final urgent = _timeLeft <= 1;
    final timeColor = urgent ? AppColors.accentRed : AppColors.neuronGreen;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _levelChip(),
              _livesRow(),
              Text(
                '${_engine.score}',
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: timeFrac,
              minHeight: 2,
              backgroundColor: AppColors.cosmicMid,
              valueColor: AlwaysStoppedAnimation<Color>(timeColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelChip() {
    final chip = Text(
      '${L10n.t('game.level')} ${_engine.level.toString().padLeft(2, '0')}',
      style: TextStyle(
        color: _levelUp
            ? AppColors.plasmaYellow
            : AppColors.pureWhite.withValues(alpha: 0.45),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    if (!_levelUp) return chip;
    return chip
        .animate(key: ValueKey('lvl-${_engine.level}'))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 260.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .tint(color: AppColors.plasmaYellow, duration: 200.ms);
  }

  Widget _livesRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_engine.lives, (i) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            Icons.favorite,
            size: 14,
            color: AppColors.accentRed,
          ),
        );
      }),
    );
  }

  Widget _wordDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            L10n.t('stroop.prompt'),
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 28),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              L10n.t(_current.word.nameKey),
              key: ValueKey(
                  '${_current.word.nameKey}-${_current.ink.value}-${_engine.round}'),
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w600,
                color: _current.ink.value,
                letterSpacing: -0.03,
                height: 1.0,
              ),
            ).animate().fadeIn(duration: 200.ms).scale(
                  begin: const Offset(0.94, 0.94),
                  end: const Offset(1, 1),
                  duration: 280.ms,
                  curve: Curves.easeOutQuart,
                ),
          ),
        ],
      ),
    );
  }

  Widget _colorButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(palette.length, (i) {
          final c = palette[i];
          final isFlash = _flashIndex == i;
          final correctAnswer =
              _flashIndex != null && c.nameKey == _current.ink.nameKey && !isFlash;
          return GestureDetector(
            onTap: () => _onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.value,
                border: Border.all(
                  color: isFlash
                      ? (_flashCorrect == true
                          ? AppColors.pureWhite
                          : AppColors.cosmicDeep)
                      : correctAnswer
                          ? AppColors.pureWhite.withValues(alpha: 0.7)
                          : AppColors.cosmicDeep.withValues(alpha: 0.4),
                  width: isFlash ? 4 : (correctAnswer ? 3 : 1),
                ),
              ),
            )
                .animate(target: isFlash ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.18, 1.18),
                  duration: 200.ms,
                  curve: Curves.easeOutQuart,
                ),
          );
        }),
      ),
    );
  }

  Widget _resultView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            L10n.t('game.over'),
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_engine.score}',
            style: const TextStyle(
              fontSize: 128,
              fontWeight: FontWeight.w600,
              color: AppColors.neuronGreen,
              letterSpacing: -0.04,
              height: 1.0,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutQuart),
          Text(
            L10n.t('game.score'),
            style: TextStyle(
              color: AppColors.neuronGreen.withValues(alpha: 0.6),
              fontSize: 13,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          _statRow(L10n.t('game.bestLevel'), '${_engine.level}'),
          const SizedBox(height: 10),
          _statRow(L10n.t('game.bestStreak'), '${_engine.bestStreak}'),
          const SizedBox(height: 10),
          _statRow(L10n.t('game.rounds'), '${_engine.round}'),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _restart,
                child: Text(L10n.t('game.again')),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.pureWhite,
                  side: BorderSide(
                      color: AppColors.pureWhite.withValues(alpha: 0.3)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(L10n.t('game.exit')),
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
