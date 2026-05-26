import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';

/// Stroop testi — so'z va uning rangi o'rtasidagi ziddiyatni yengish
/// Ilmiy asos: J.R. Stroop (1935), prefrontal cortex inhibition
class StroopGame extends StatefulWidget {
  const StroopGame({super.key});

  @override
  State<StroopGame> createState() => _StroopGameState();
}

class _GameColor {
  final String name;
  final Color value;
  const _GameColor(this.name, this.value);
}

class _Round {
  final _GameColor word;
  final _GameColor ink;
  const _Round({required this.word, required this.ink});
}

class _StroopGameState extends State<StroopGame> {
  static const int totalRounds = 20;
  static const List<_GameColor> palette = [
    _GameColor('QIZIL', AppColors.gameRed),
    _GameColor('KO\'K', AppColors.gameBlue),
    _GameColor('YASHIL', AppColors.gameGreen),
    _GameColor('SARIQ', AppColors.gameYellow),
  ];

  final Random _rng = Random();
  late _Round _current;
  int _round = 0;
  int _correct = 0;
  int _wrong = 0;
  bool _finished = false;
  int? _flashIndex;
  bool? _flashCorrect;
  DateTime _roundStart = DateTime.now();
  Duration _totalReaction = Duration.zero;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    final word = palette[_rng.nextInt(palette.length)];
    final shouldDiffer = _rng.nextDouble() < 0.75;
    _GameColor ink;
    if (shouldDiffer) {
      do {
        ink = palette[_rng.nextInt(palette.length)];
      } while (ink.name == word.name);
    } else {
      ink = word;
    }
    setState(() {
      _current = _Round(word: word, ink: ink);
      _flashIndex = null;
      _flashCorrect = null;
      _roundStart = DateTime.now();
    });
  }

  void _onTap(int index) {
    if (_flashIndex != null || _finished) return;
    final chosen = palette[index];
    final correct = chosen.name == _current.ink.name;
    _totalReaction += DateTime.now().difference(_roundStart);

    setState(() {
      _flashIndex = index;
      _flashCorrect = correct;
      if (correct) {
        _correct++;
      } else {
        _wrong++;
      }
    });

    Future.delayed(const Duration(milliseconds: 480), () {
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
    setState(() => _finished = true);
    final state = context.read<AppState>();
    await state.incrementSessions();
    final avgMs = totalRounds > 0
        ? _totalReaction.inMilliseconds / totalRounds
        : 0;
    final accuracy = _correct / totalRounds;
    final accBonus = (accuracy * 15).round();
    final speedBonus = avgMs < 1500
        ? 10
        : avgMs < 2500
            ? 5
            : 0;
    final coins = (5 + accBonus + speedBonus).clamp(1, 50);
    await state.addCoins(coins);
  }

  void _restart() {
    setState(() {
      _round = 0;
      _correct = 0;
      _wrong = 0;
      _finished = false;
      _totalReaction = Duration.zero;
    });
    _nextRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroop'),
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
        Expanded(child: Center(child: _wordDisplay())),
        _colorButtons(),
        const SizedBox(height: 32),
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
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 2,
              backgroundColor: AppColors.cosmicMid,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.neuronGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'RANGI',
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
              _current.word.name,
              key: ValueKey(
                  '${_current.word.name}-${_current.ink.value}-$_round'),
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
          final correctAnswer = _flashIndex != null &&
              c.name == _current.ink.name &&
              !isFlash;
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
    final accuracy = (_correct / totalRounds * 100).round();
    final avgSec = totalRounds > 0
        ? (_totalReaction.inMilliseconds / totalRounds / 1000).toStringAsFixed(1)
        : '0.0';
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
          _statRow('O\'rtacha vaqt', '$avgSec s'),
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
