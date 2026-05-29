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

/// Ikki qaror — cheksiz adaptiv reaksiya tezligi + qoida o'zgarishiga moslashish
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
  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(
    rtThreshold: 0.8, // 0.8 soniyadan tez javob = bonus
    maxLatency: 999, // sekin javob jazosi yo'q (timeout alohida)
    alpha: 0.10,
    beta: 0.16,
  );

  late _Stimulus _stim;
  late _Rule _rule;
  bool _finished = false;
  bool? _flashCorrect;
  String? _flashSide;
  DateTime _roundStart = DateTime.now();
  bool _ruleJustChanged = false;
  bool _levelUp = false;

  // Per-round vaqt cheklovi (darajaga qarab qisqaradi)
  int _timeLimitMs = 2400;
  late final AnimationController _timeController;
  _Stimulus? _decoyStim;
  Alignment _decoyAlign = Alignment.topLeft;
  String? _ghostSide; // soxta "noto'g'ri" signal (qisqa flash)

  @override
  void initState() {
    super.initState();
    _timeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _timeLimitMs),
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

  // Darajadan raund vaqt byudjetini hisoblaydi (cheksiz pasayadi, 600ms pol)
  int _timeLimitForLevel() => max(600, 2400 - (_engine.level - 1) * 150);

  void _nextRound() {
    final lvl = _engine.level;
    _timeLimitMs = _timeLimitForLevel();

    // Yuqori darajada qoida tez-tez almashadi (har raund ehtimoli oshadi)
    final ruleSwitchProb = (0.10 + (lvl - 1) * 0.04).clamp(0.0, 0.45);
    final realRuleChange =
        _engine.round > 0 && _rng.nextDouble() < ruleSwitchProb;
    // Soxta "YANGI QOIDA" banneri — 3-darajadan boshlab, qoida o'zgarmaydi
    final fakeBannerProb = lvl >= 3 ? (0.12 + (lvl - 3) * 0.03).clamp(0.0, 0.30) : 0.0;
    if (realRuleChange) {
      _rule = _rule == _Rule.byShape ? _Rule.byColor : _Rule.byShape;
      _ruleJustChanged = true;
    } else if (_rng.nextDouble() < fakeBannerProb) {
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
      _levelUp = false;
      _roundStart = DateTime.now();
      _decoyStim = _rollDecoy(lvl);
      _ghostSide = _rollGhostSignal(lvl);
    });

    _startRoundTimer();
    _scheduleGhostClear();

    if (realRuleChange) {
      HapticFeedback.selectionClick();
    }
  }

  /// Chalg'ituvchi shakl: 2-darajadan boshlab paydo bo'ladi.
  /// Ehtimol = 0.25 + (level - 2) * 0.15, max 0.80.
  _Stimulus? _rollDecoy(int lvl) {
    if (lvl < 2) return null;
    final p = (0.25 + (lvl - 2) * 0.15).clamp(0.0, 0.80);
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
  /// Ehtimol darajaga qarab oshadi; foydalanuvchini noto'g'ri tomonga undaydi.
  String? _rollGhostSignal(int lvl) {
    if (lvl < 4) return null;
    final p = (0.25 + (lvl - 4) * 0.05).clamp(0.0, 0.55);
    if (_rng.nextDouble() >= p) return null;
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
    _timeController.duration = Duration(milliseconds: _timeLimitMs);
    _timeController.reset();
    _timeController.forward();
  }

  void _onTimeout() {
    if (_flashCorrect != null || _finished) return;
    _timeController.stop();
    final prevLevel = _engine.level;
    _engine.registerRound(correct: false);
    setState(() {
      _flashCorrect = false;
      _flashSide = null;
      _levelUp = _engine.level > prevLevel;
    });
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 380), _advance);
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
    final rt = DateTime.now().difference(_roundStart).inMilliseconds / 1000.0;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: rt);
    setState(() {
      _flashSide = side;
      _flashCorrect = correct;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    Future.delayed(const Duration(milliseconds: 380), _advance);
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
    _timeController.stop();
    setState(() => _finished = true);
    final state = context.read<AppState>();
    await state.incrementSessions();
    final coins = (5 + _engine.bestStreak * 2 + _engine.level * 2).clamp(1, 80);
    await state.addCoins(coins);
  }

  void _restart() {
    _timeController.stop();
    _engine.reset();
    setState(() {
      _finished = false;
      _decoyStim = null;
      _ghostSide = null;
      _rule = _Rule.values[_rng.nextInt(_Rule.values.length)];
    });
    _nextRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('dual.title')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [Padding(padding: EdgeInsets.only(right: 14), child: Center(child: BrainMark(size: 22)))],
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
        const SizedBox(height: 20),
        _ruleBanner(),
        Expanded(child: _playArea()),
      ],
    );
  }

  Widget _statusBar() {
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
            child: AnimatedBuilder(
              animation: _timeController,
              builder: (context, _) {
                final timeLeft =
                    (1.0 - _timeController.value).clamp(0.0, 1.0);
                final urgent = _timeController.value > 0.70;
                return LinearProgressIndicator(
                  value: timeLeft,
                  minHeight: 2,
                  backgroundColor: AppColors.cosmicMid,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    urgent ? AppColors.accentRed : AppColors.neuronGreen,
                  ),
                );
              },
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
      children: List.generate(_engine.lives, (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            Icons.favorite,
            size: 14,
            color: AppColors.accentRed,
          ),
        );
      }),
    );
  }

  Widget _ruleBanner() {
    final byShape = _rule == _Rule.byShape;
    final left = byShape ? L10n.t('dual.circle') : L10n.t('dual.warm');
    final right = byShape ? L10n.t('dual.square') : L10n.t('dual.cold');
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
                child: Text(
                  L10n.t('dual.newRule'),
                  style: const TextStyle(
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
              .animate(key: ValueKey('stim-${_engine.round}'))
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
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
