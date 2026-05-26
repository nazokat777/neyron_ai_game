import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
/// Shulte jadvali — vizual diqqat va periferik ko'rish mashqi
/// Ilmiy asos: Walter Schulte (1920), 47% diqqat yaxshilanishi (8 hafta mashq)
class ShulteGame extends StatefulWidget {
  const ShulteGame({super.key});

  @override
  State<ShulteGame> createState() => _ShulteGameState();
}

class _ShulteGameState extends State<ShulteGame> {
  static const int gridSize = 5; // 5x5
  static const int totalCells = gridSize * gridSize;

  late List<int> _numbers;
  int _nextNumber = 1;
  DateTime? _startTime;
  Duration? _elapsedTime;
  bool _finished = false;
  int _mistakes = 0;
  int _lastWrongIndex = -1;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _numbers = List.generate(totalCells, (i) => i + 1)..shuffle(Random());
    _nextNumber = 1;
    _startTime = null;
    _elapsedTime = null;
    _finished = false;
    _mistakes = 0;
    _lastWrongIndex = -1;
    setState(() {});
  }

  void _onTap(int number, int index) {
    if (_finished) return;
    _startTime ??= DateTime.now();

    if (number == _nextNumber) {
      setState(() {
        _nextNumber++;
        if (_nextNumber > totalCells) {
          _finished = true;
          _elapsedTime = DateTime.now().difference(_startTime!);
          _awardXp();
        }
      });
    } else {
      setState(() {
        _mistakes++;
        _lastWrongIndex = index;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _lastWrongIndex = -1);
      });
    }
  }

  Future<void> _awardXp() async {
    final state = context.read<AppState>();
    await state.incrementSessions();

    // XP hisoblash: tezroq + kam xato = ko'proq tanga
    final seconds = _elapsedTime!.inSeconds;
    final baseCoins = 10;
    final speedBonus = (60 - seconds).clamp(0, 60) ~/ 6;
    final mistakePenalty = _mistakes * 2;
    final coins = (baseCoins + speedBonus - mistakePenalty).clamp(1, 50);
    await state.addCoins(coins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shulte'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              _heroTarget(),
              const SizedBox(height: 12),
              Expanded(child: _buildGrid()),
              if (_finished) _resultCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroTarget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPING',
                style: TextStyle(
                  color: AppColors.pureWhite.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              Text(
                _mistakes == 0 ? 'TOZA' : '$_mistakes XATO',
                style: TextStyle(
                  color: _mistakes == 0
                      ? AppColors.pureWhite.withValues(alpha: 0.5)
                      : AppColors.accentRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _finished ? '✓' : '$_nextNumber',
            key: ValueKey('target-$_nextNumber'),
            style: const TextStyle(
              fontSize: 88,
              fontWeight: FontWeight.w600,
              color: AppColors.neuronGreen,
              letterSpacing: -0.04,
              height: 1.0,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
              .animate(key: ValueKey('target-anim-$_nextNumber'))
              .fadeIn(duration: 180.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1, 1),
                duration: 240.ms,
                curve: Curves.easeOutQuart,
              ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridSize,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: totalCells,
          itemBuilder: (_, i) => _buildCell(i),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final number = _numbers[index];
    final isFound = number < _nextNumber;
    final isWrong = index == _lastWrongIndex;

    Color bg = AppColors.cosmicMid;
    if (isFound) bg = AppColors.neuronGreen.withValues(alpha: 0.18);
    if (isWrong) bg = AppColors.accentRed.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: () => _onTap(number, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            isFound ? '·' : '$number',
            style: TextStyle(
              fontSize: isFound ? 22 : 30,
              fontWeight: FontWeight.w600,
              color: isFound
                  ? AppColors.neuronGreen.withValues(alpha: 0.7)
                  : AppColors.pureWhite,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -0.02,
            ),
          ),
        ),
      )
          .animate(target: isWrong ? 1 : 0)
          .shake(hz: 6, curve: Curves.easeInOut, duration: 280.ms),
    );
  }

  Widget _resultCard() {
    final seconds = _elapsedTime!.inSeconds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Text(
            'vaqt',
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$seconds',
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neuronGreen,
                  letterSpacing: -0.04,
                  height: 1.0,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                's',
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
          const SizedBox(height: 18),
          Text(
            _mistakes == 0 ? 'xatosiz' : '$_mistakes xato',
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.6),
              fontSize: 14,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _reset,
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
}
