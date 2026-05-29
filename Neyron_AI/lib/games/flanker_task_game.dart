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

/// Oqimni boshqarish (Flanker Task) — cheksiz adaptiv selektiv diqqat
/// Ilmiy asos: response inhibition + interference control (anterior cingulate)
class FlankerTaskGame extends StatefulWidget {
  const FlankerTaskGame({super.key});

  @override
  State<FlankerTaskGame> createState() => _FlankerTaskGameState();
}

class _FlankerTaskGameState extends State<FlankerTaskGame> {
  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(
    rtThreshold: 0.7, // 0.7 soniyadan tez = bonus
    maxLatency: 999,
    alpha: 0.10,
    beta: 0.16,
  );

  String _target = 'L'; // markaziy strelka yo'nalishi
  List<String> _arrows = const ['L', 'L', 'L', 'L', 'L'];
  String? _flashSide;
  bool? _flashCorrect;
  bool _showResult = false;
  bool _finished = false;
  bool _levelUp = false;

  double _roundMs = 2000;
  double _timeLeft = 2000;
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

  // Darajadan raund vaqt byudjetini hisoblaydi (cheksiz pasayadi, 700ms pol)
  double _msForLevel() => max(700, 2000 - (_engine.level - 1) * 120).toDouble();

  void _nextRound() {
    final lvl = _engine.level;
    _target = _rng.nextBool() ? 'L' : 'R';
    // Inkongruent (chalg'ituvchi) holat ehtimoli darajaga qarab oshadi
    final incongruentProb = (0.30 + (lvl - 1) * 0.06).clamp(0.0, 0.85);
    final incongruent = _rng.nextDouble() < incongruentProb;
    final flanker = incongruent ? (_target == 'L' ? 'R' : 'L') : _target;
    _arrows = [flanker, flanker, _target, flanker, flanker];
    _roundMs = _msForLevel();
    setState(() {
      _flashSide = null;
      _flashCorrect = null;
      _showResult = false;
      _levelUp = false;
      _timeLeft = _roundMs;
      _roundStart = DateTime.now();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) return;
      setState(() => _timeLeft -= 100);
      if (_timeLeft <= 0) {
        t.cancel();
        _onTimeout();
      }
    });
  }

  void _onTimeout() {
    if (_flashCorrect != null || _finished) return;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: false);
    setState(() {
      _flashCorrect = false;
      _flashSide = null;
      _showResult = true;
      _levelUp = _engine.level > prevLevel;
    });
    HapticFeedback.heavyImpact();
    _timer = Timer(const Duration(milliseconds: 600), _advance);
  }

  void _onTap(String side) {
    if (_flashCorrect != null || _finished) return;
    _timer?.cancel();
    final correct = side == _target;
    final rt = DateTime.now().difference(_roundStart).inMilliseconds / 1000.0;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: rt);
    setState(() {
      _flashSide = side;
      _flashCorrect = correct;
      _showResult = true;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _timer = Timer(const Duration(milliseconds: 450), _advance);
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
    final coins =
        (5 + _engine.bestStreak * 2 + _engine.level * 2).clamp(1, 80);
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
        title: Text(L10n.t('flanker.title')),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _statusBar(),
          Expanded(child: Center(child: _arrowRow())),
          _buttons(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _statusBar() {
    final timeFrac = _roundMs > 0 ? (_timeLeft / _roundMs).clamp(0.0, 1.0) : 0.0;
    final urgent = _timeLeft <= 600;
    final timeColor = urgent ? AppColors.accentRed : AppColors.neuronGreen;
    return Column(
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
      children: List.generate(
        _engine.lives,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(Icons.favorite, size: 14, color: AppColors.accentRed),
        ),
      ),
    );
  }

  Widget _arrowRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_arrows.length, (i) {
        final isCenter = i == 2;
        // Natija ko'rsatilganda markaziy strelka neuron-yashil bo'ladi
        Color color = AppColors.pureWhite;
        if (_showResult && isCenter) color = AppColors.neuronGreen;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            _arrows[i] == 'L' ? Icons.arrow_back : Icons.arrow_forward,
            size: 52,
            color: color,
          ),
        );
      }),
    )
        .animate(key: ValueKey('arrows-${_engine.round}'))
        .fadeIn(duration: 160.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOutQuart,
        );
  }

  Widget _buttons() {
    return Row(
      children: [
        Expanded(child: _dirButton('L', L10n.t('flanker.left'), Icons.arrow_back)),
        const SizedBox(width: 12),
        Expanded(child: _dirButton('R', L10n.t('flanker.right'), Icons.arrow_forward)),
      ],
    );
  }

  Widget _dirButton(String side, String label, IconData icon) {
    final isFlash = _flashSide == side;
    Color bg = AppColors.cosmicMid;
    Color border = AppColors.pureWhite.withValues(alpha: 0.08);
    Color fg = AppColors.pureWhite;
    double borderWidth = 1;
    if (isFlash && _flashCorrect == true) {
      bg = AppColors.neuronGreen.withValues(alpha: 0.2);
      border = AppColors.neuronGreen;
      fg = AppColors.neuronGreen;
      borderWidth = 2;
    } else if (isFlash && _flashCorrect == false) {
      bg = AppColors.accentRed.withValues(alpha: 0.2);
      border = AppColors.accentRed;
      fg = AppColors.accentRed;
      borderWidth = 2;
    }
    return GestureDetector(
      onTap: () => _onTap(side),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: borderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: fg),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: fg,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
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
