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

/// Tez hisob — cheksiz adaptiv arifmetik chaqqonlik
/// Ilmiy asos: parietal cortex (raqamlar) + prefrontal (qaror)
class QuickMathGame extends StatefulWidget {
  const QuickMathGame({super.key});

  @override
  State<QuickMathGame> createState() => _QuickMathGameState();
}

enum _Op { add, sub, mul }

extension _OpSym on _Op {
  String get symbol => switch (this) {
        _Op.add => '+',
        _Op.sub => '−',
        _Op.mul => '×',
      };
}

class _Question {
  final int a, b;
  final _Op op;
  final int answer;
  final List<int> options;
  const _Question({
    required this.a,
    required this.b,
    required this.op,
    required this.answer,
    required this.options,
  });
}

class _QuickMathGameState extends State<QuickMathGame> {
  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(
    rtThreshold: 2.0, // 2 soniyadan tez javob = bonus
    maxLatency: 999, // sekin javob jazosi yo'q (timeout alohida)
    alpha: 0.10,
    beta: 0.16,
  );

  late _Question _q;
  int? _flashIndex;
  bool? _flashCorrect;
  bool _showAnswer = false;
  bool _finished = false;
  bool _levelUp = false;

  double _roundSeconds = 8;
  double _timeLeft = 8;
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

  // D dan raund vaqt byudjetini hisoblaydi (cheksiz pasayadi, 2s pol)
  double _secondsForD() => max(2.0, 8.0 - (_engine.d - 1) * 0.5);

  void _nextRound() {
    final lvl = _engine.level;
    final op = _Op.values[_rng.nextInt(_Op.values.length)];
    int a, b, answer;
    switch (op) {
      case _Op.add:
        a = _rng.nextInt(20 + lvl * 15) + 10;
        b = _rng.nextInt(20 + lvl * 15) + 10;
        answer = a + b;
        break;
      case _Op.sub:
        a = _rng.nextInt(40 + lvl * 20) + 30;
        b = _rng.nextInt(a - 5) + 5;
        answer = a - b;
        break;
      case _Op.mul:
        a = _rng.nextInt(6 + lvl * 2) + 2;
        b = _rng.nextInt(9 + lvl) + 2;
        answer = a * b;
        break;
    }
    final options = _buildOptions(answer, lvl);
    _roundSeconds = _secondsForD();
    setState(() {
      _q = _Question(a: a, b: b, op: op, answer: answer, options: options);
      _flashIndex = null;
      _flashCorrect = null;
      _showAnswer = false;
      _levelUp = false;
      _timeLeft = _roundSeconds;
      _roundStart = DateTime.now();
    });
    _startTimer();
  }

  List<int> _buildOptions(int answer, int lvl) {
    // Yuqori darajada chalg'ituvchilar javobga yaqinroq
    final maxDelta = max(3, 15 - lvl * 2);
    final set = <int>{answer};
    while (set.length < 4) {
      final delta = (_rng.nextInt(maxDelta) + 1) * (_rng.nextBool() ? 1 : -1);
      final v = answer + delta;
      if (v >= 0) set.add(v);
    }
    return set.toList()..shuffle(_rng);
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
      _showAnswer = true;
      _levelUp = _engine.level > prevLevel;
    });
    HapticFeedback.heavyImpact();
    _timer = Timer(const Duration(milliseconds: 900), _advance);
  }

  void _onTap(int index) {
    if (_flashIndex != null || _finished) return;
    _timer?.cancel();
    final chosen = _q.options[index];
    final correct = chosen == _q.answer;
    final rt = DateTime.now().difference(_roundStart).inMilliseconds / 1000.0;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: rt);
    setState(() {
      _flashIndex = index;
      _flashCorrect = correct;
      _showAnswer = true;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _timer = Timer(const Duration(milliseconds: 650), _advance);
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
        title: Text(L10n.t('math.title')),
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
          const SizedBox(height: 40),
          Expanded(child: Center(child: _equationDisplay())),
          _answerGrid(),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _statusBar() {
    final timeFrac = _roundSeconds > 0 ? (_timeLeft / _roundSeconds).clamp(0.0, 1.0) : 0.0;
    final urgent = _timeLeft <= 2;
    final timeColor = urgent ? AppColors.accentRed : AppColors.neuronGreen;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _levelChip(),
            _livesRow(),
            Text(
              '$_engineScore',
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

  int get _engineScore => _engine.score;

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

  Widget _equationDisplay() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        key: ValueKey('q-${_engine.round}'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          _digit('${_q.a}'),
          const SizedBox(width: 20),
          Text(
            _q.op.symbol,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w400,
              color: AppColors.pureWhite.withValues(alpha: 0.35),
              height: 1.0,
            ),
          ),
          const SizedBox(width: 20),
          _digit('${_q.b}'),
          const SizedBox(width: 20),
          Text(
            '=',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w400,
              color: AppColors.pureWhite.withValues(alpha: 0.35),
              height: 1.0,
            ),
          ),
          const SizedBox(width: 20),
          _answerSlot(),
        ],
      ),
    )
        .animate(key: ValueKey('anim-${_engine.round}'))
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.04, end: 0, duration: 260.ms, curve: Curves.easeOut);
  }

  Widget _digit(String s) {
    return Text(
      s,
      style: const TextStyle(
        fontSize: 88,
        fontWeight: FontWeight.w600,
        color: AppColors.pureWhite,
        letterSpacing: -0.03,
        height: 1.0,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _answerSlot() {
    if (!_showAnswer) {
      return Text(
        '?',
        style: TextStyle(
          fontSize: 88,
          fontWeight: FontWeight.w600,
          color: AppColors.neuronGreen.withValues(alpha: 0.75),
          height: 1.0,
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(begin: 0.6, duration: 900.ms);
    }
    return Text(
      '${_q.answer}',
      key: ValueKey('answer-${_engine.round}'),
      style: const TextStyle(
        fontSize: 88,
        fontWeight: FontWeight.w600,
        color: AppColors.neuronGreen,
        letterSpacing: -0.03,
        height: 1.0,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 280.ms,
          curve: Curves.easeOutQuart,
        );
  }

  Widget _answerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.3,
      ),
      itemCount: _q.options.length,
      itemBuilder: (_, i) => _answerCard(i),
    );
  }

  Widget _answerCard(int i) {
    final value = _q.options[i];
    final isFlash = _flashIndex == i;
    final isCorrectAnswer = value == _q.answer;
    final showCorrect = _flashIndex != null && isCorrectAnswer;

    Color bg = AppColors.cosmicMid;
    Color border = AppColors.pureWhite.withValues(alpha: 0.06);
    Color text = AppColors.pureWhite;
    double borderWidth = 1;

    if (isFlash && _flashCorrect == true) {
      bg = AppColors.neuronGreen.withValues(alpha: 0.2);
      border = AppColors.neuronGreen;
      text = AppColors.neuronGreen;
      borderWidth = 2;
    } else if (isFlash && _flashCorrect == false) {
      bg = AppColors.accentRed.withValues(alpha: 0.2);
      border = AppColors.accentRed;
      text = AppColors.accentRed;
      borderWidth = 2;
    } else if (showCorrect) {
      border = AppColors.neuronGreen.withValues(alpha: 0.6);
      text = AppColors.neuronGreen;
      borderWidth = 2;
    }

    return GestureDetector(
      onTap: () => _onTap(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: borderWidth),
        ),
        child: Center(
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: text,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.01,
            ),
          ),
        ),
      ).animate(target: isFlash ? 1 : 0).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: 180.ms,
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
