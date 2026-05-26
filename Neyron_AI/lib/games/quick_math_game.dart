import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';

/// Tez hisob — arifmetik chaqqonlik va ishchi xotira
/// Ilmiy asos: parietal cortex (raqamlar bilan ishlash) + prefrontal (qaror)
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
  static const int totalRounds = 15;
  static const int secondsPerRound = 8;

  final Random _rng = Random();
  late _Question _q;
  int _round = 0;
  int _correct = 0;
  int _wrong = 0;
  int? _flashIndex;
  bool? _flashCorrect;
  bool _showAnswer = false;
  bool _finished = false;
  int _timeLeft = secondsPerRound;
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

  void _nextRound() {
    final op = _Op.values[_rng.nextInt(_Op.values.length)];
    int a, b, answer;
    switch (op) {
      case _Op.add:
        a = _rng.nextInt(40) + 10;
        b = _rng.nextInt(40) + 10;
        answer = a + b;
        break;
      case _Op.sub:
        a = _rng.nextInt(60) + 30;
        b = _rng.nextInt(a - 5) + 5;
        answer = a - b;
        break;
      case _Op.mul:
        a = _rng.nextInt(11) + 2;
        b = _rng.nextInt(11) + 2;
        answer = a * b;
        break;
    }
    final options = _buildOptions(answer);
    setState(() {
      _q = _Question(a: a, b: b, op: op, answer: answer, options: options);
      _flashIndex = null;
      _flashCorrect = null;
      _showAnswer = false;
      _timeLeft = secondsPerRound;
    });
    _startTimer();
  }

  List<int> _buildOptions(int answer) {
    final set = <int>{answer};
    while (set.length < 4) {
      final delta = (_rng.nextInt(15) + 1) * (_rng.nextBool() ? 1 : -1);
      final v = answer + delta;
      if (v >= 0) set.add(v);
    }
    final list = set.toList()..shuffle(_rng);
    return list;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        _timer?.cancel();
        _timeout();
      }
    });
  }

  void _timeout() {
    setState(() {
      _wrong++;
      _flashIndex = -1;
      _flashCorrect = false;
      _showAnswer = true;
    });
    Future.delayed(const Duration(milliseconds: 900), _advance);
  }

  void _onTap(int index) {
    if (_flashIndex != null || _finished) return;
    _timer?.cancel();
    final chosen = _q.options[index];
    final correct = chosen == _q.answer;
    setState(() {
      _flashIndex = index;
      _flashCorrect = correct;
      _showAnswer = true;
      if (correct) {
        _correct++;
      } else {
        _wrong++;
      }
    });
    Future.delayed(const Duration(milliseconds: 700), _advance);
  }

  void _advance() {
    if (!mounted) return;
    _round++;
    if (_round >= totalRounds) {
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
    final accuracy = _correct / totalRounds;
    final accBonus = (accuracy * 20).round();
    final coins = (5 + accBonus).clamp(1, 50);
    await state.addCoins(coins);
  }

  void _restart() {
    setState(() {
      _round = 0;
      _correct = 0;
      _wrong = 0;
      _finished = false;
    });
    _nextRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hisob'),
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
    final timeFrac = _timeLeft / secondsPerRound;
    final urgent = _timeLeft <= 3;
    final timeColor = urgent ? AppColors.accentRed : AppColors.neuronGreen;
    return Column(
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
            Text(
              '${_timeLeft}s',
              style: TextStyle(
                color: timeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
                .animate(
                  target: urgent ? 1 : 0,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .fadeIn(begin: 0.5, duration: 500.ms),
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

  Widget _equationDisplay() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        key: ValueKey('q-$_round'),
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
        .animate(key: ValueKey('anim-$_round'))
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
      key: ValueKey('answer-$_round'),
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
    final accuracy = (_correct / totalRounds * 100).round();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'aniqlik',
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
                '$accuracy',
                style: const TextStyle(
                  fontSize: 144,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neuronGreen,
                  letterSpacing: -0.04,
                  height: 1.0,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  fontSize: 56,
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
          _statRow('To\'g\'ri', '$_correct / $totalRounds'),
          const SizedBox(height: 10),
          _statRow('Xato', '$_wrong'),
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
