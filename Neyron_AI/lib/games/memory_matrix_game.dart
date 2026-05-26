import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';

/// Memory Matrix — naqshni eslab qolish va takrorlash
/// Ilmiy asos: Ishchi xotira (Working Memory), dorsolateral prefrontal cortex
class MemoryMatrixGame extends StatefulWidget {
  const MemoryMatrixGame({super.key});

  @override
  State<MemoryMatrixGame> createState() => _MemoryMatrixGameState();
}

enum _GamePhase { ready, memorize, recall, correct, wrong, finished }

class _MemoryMatrixGameState extends State<MemoryMatrixGame> {
  // Daraja → grid kattaligi va belgilangan kataklar soni
  int _level = 1;
  late int _gridSize;
  late int _targetCount;
  late Set<int> _target;
  Set<int> _selected = {};
  _GamePhase _phase = _GamePhase.ready;
  int _score = 0;
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    final cfg = _configFor(_level);
    _gridSize = cfg.$1;
    _targetCount = cfg.$2;
    _target = _randomCells(_gridSize * _gridSize, _targetCount);
    _selected = {};
    _phase = _GamePhase.ready;
    setState(() {});

    // 1 soniya kutib, memorize fazaga o'tish
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _phase = _GamePhase.memorize);
      // Memorize davomiyligi darajaga qarab
      final memorizeMs = 1500 + (_targetCount * 300);
      Future.delayed(Duration(milliseconds: memorizeMs), () {
        if (!mounted) return;
        setState(() => _phase = _GamePhase.recall);
      });
    });
  }

  /// Daraja → (grid, target count)
  (int, int) _configFor(int level) {
    if (level <= 2) return (3, 3 + level);    // 3x3: 4, 5
    if (level <= 5) return (4, 4 + level);    // 4x4: 7, 8, 9
    if (level <= 8) return (5, 6 + level - 5); // 5x5: 7, 8, 9
    return (6, 9 + (level - 8).clamp(0, 9));   // 6x6+
  }

  Set<int> _randomCells(int total, int count) {
    final rng = Random();
    final all = List.generate(total, (i) => i)..shuffle(rng);
    return all.take(count).toSet();
  }

  void _onTap(int index) {
    if (_phase != _GamePhase.recall) return;
    if (_selected.contains(index)) return;

    setState(() {
      _selected.add(index);
    });

    if (_target.contains(index)) {
      // To'g'ri
      if (_selected.length >= _targetCount &&
          _selected.intersection(_target).length == _targetCount) {
        _winLevel();
      }
    } else {
      // Xato
      _loseLevel();
    }
  }

  void _winLevel() {
    setState(() {
      _phase = _GamePhase.correct;
      _score += _targetCount * 10;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _level++;
      _startLevel();
    });
  }

  void _loseLevel() {
    setState(() {
      _phase = _GamePhase.wrong;
      _lives--;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_lives <= 0) {
        _finish();
      } else {
        _startLevel();
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _phase = _GamePhase.finished);
    final state = context.read<AppState>();
    await state.incrementSessions();
    await state.addCoins((_score / 5).round().clamp(1, 100));
  }

  void _restart() {
    setState(() {
      _level = 1;
      _score = 0;
      _lives = 3;
      _selected = {};
    });
    _startLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Matritsa'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 4),
              _heroHeader(),
              const SizedBox(height: 24),
              Expanded(child: Center(child: _buildGrid())),
              if (_phase == _GamePhase.finished) _resultCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroHeader() {
    final phase = _phaseInfo();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('DARAJA', '$_level'),
              _livesIndicator(),
              _miniStat('BALL', '$_score'),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            phase.$1,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: phase.$2,
              letterSpacing: -0.02,
              height: 1.0,
            ),
          )
              .animate(key: ValueKey('phase-$_phase'))
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.1, end: 0, duration: 220.ms),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.pureWhite.withValues(alpha: 0.45),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.02,
            height: 1.0,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _livesIndicator() {
    return Column(
      children: [
        Text(
          'HAYOT',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.pureWhite.withValues(alpha: 0.45),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final lit = i < _lives;
            return Container(
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lit
                    ? AppColors.accentRed
                    : AppColors.pureWhite.withValues(alpha: 0.12),
              ),
            );
          }),
        ),
      ],
    );
  }

  (String, Color) _phaseInfo() {
    switch (_phase) {
      case _GamePhase.ready:
        return ('Tayyor', AppColors.pureWhite.withValues(alpha: 0.55));
      case _GamePhase.memorize:
        return ('Eslab qoling', AppColors.plasmaYellow);
      case _GamePhase.recall:
        return ('Takrorlang', AppColors.neuronGreen);
      case _GamePhase.correct:
        return ('Topildi', AppColors.neuronGreen);
      case _GamePhase.wrong:
        return ('Eslamadingiz', AppColors.accentRed);
      case _GamePhase.finished:
        return ('Tugadi', AppColors.pureWhite);
    }
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _gridSize * _gridSize,
          itemBuilder: (_, i) => _buildCell(i),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final isTarget = _target.contains(index);
    final isSelected = _selected.contains(index);

    Color bg;
    Widget? icon;

    switch (_phase) {
      case _GamePhase.memorize:
        // Naqshni ko'rsatish
        bg = isTarget
            ? AppColors.professorWarmth.withValues(alpha: 0.55)
            : AppColors.cosmicMid;
        if (isTarget) {
          icon = const Icon(Icons.star_rounded, color: AppColors.pureWhite, size: 24);
        }
        break;
      case _GamePhase.recall:
        if (isSelected && isTarget) {
          bg = AppColors.neuronGreen.withValues(alpha: 0.5);
          icon = const Icon(Icons.check_rounded, color: AppColors.pureWhite, size: 22);
        } else if (isSelected && !isTarget) {
          bg = AppColors.accentRed.withValues(alpha: 0.5);
          icon = const Icon(Icons.close_rounded, color: AppColors.pureWhite, size: 22);
        } else {
          bg = AppColors.cosmicMid;
        }
        break;
      case _GamePhase.correct:
        bg = isTarget
            ? AppColors.neuronGreen.withValues(alpha: 0.5)
            : AppColors.cosmicMid;
        if (isTarget) {
          icon = const Icon(Icons.check_rounded, color: AppColors.pureWhite, size: 22);
        }
        break;
      case _GamePhase.wrong:
        if (isTarget) {
          bg = AppColors.professorWarmth.withValues(alpha: 0.4);
          icon = const Icon(Icons.star_rounded, color: AppColors.pureWhite, size: 22);
        } else if (isSelected) {
          bg = AppColors.accentRed.withValues(alpha: 0.5);
          icon = const Icon(Icons.close_rounded, color: AppColors.pureWhite, size: 22);
        } else {
          bg = AppColors.cosmicMid;
        }
        break;
      default:
        bg = AppColors.cosmicMid;
    }

    return GestureDetector(
      onTap: () => _onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.cosmicLight.withValues(alpha: 0.15),
          ),
        ),
        child: Center(child: icon ?? const SizedBox.shrink()),
      ),
    );
  }

  Widget _resultCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          Text(
            'ball',
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_score',
            style: const TextStyle(
              fontSize: 96,
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
          const SizedBox(height: 14),
          Text(
            'Daraja $_level',
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
}
