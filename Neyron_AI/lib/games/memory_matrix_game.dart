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

/// Memory Matrix — naqshni eslab qolish va takrorlash
/// Cheksiz adaptiv ishchi xotira (Working Memory), dorsolateral prefrontal cortex
class MemoryMatrixGame extends StatefulWidget {
  const MemoryMatrixGame({super.key});

  @override
  State<MemoryMatrixGame> createState() => _MemoryMatrixGameState();
}

enum _GamePhase { ready, memorize, recall, correct, wrong }

class _MemoryMatrixGameState extends State<MemoryMatrixGame> {
  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(alpha: 0.16, beta: 0.20);

  late int _gridSize;
  late int _targetCount;
  late Set<int> _target;
  Set<int> _selected = {};
  _GamePhase _phase = _GamePhase.ready;
  bool _finished = false;
  bool _levelUp = false;
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
    final lvl = _engine.level;
    _gridSize = (3 + (lvl - 1) ~/ 2).clamp(3, 6);
    final cells = _gridSize * _gridSize;
    _targetCount = (3 + (lvl - 1)).clamp(3, cells - 1);
    _target = _randomCells(cells, _targetCount);
    setState(() {
      _selected = {};
      _phase = _GamePhase.ready;
      _levelUp = false;
    });

    // 1 soniya kutib, memorize fazaga o'tish
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _phase = _GamePhase.memorize);
      // Memorize davomiyligi naqsh uzunligiga qarab
      final memorizeMs = 1500 + (_targetCount * 300);
      _timer = Timer(Duration(milliseconds: memorizeMs), () {
        if (!mounted) return;
        setState(() => _phase = _GamePhase.recall);
      });
    });
  }

  Set<int> _randomCells(int total, int count) {
    final all = List.generate(total, (i) => i)..shuffle(_rng);
    return all.take(count).toSet();
  }

  void _onTap(int index) {
    if (_phase != _GamePhase.recall) return;
    if (_selected.contains(index)) return;

    setState(() => _selected.add(index));

    if (_target.contains(index)) {
      // To'g'ri katak — butun naqsh topilganini tekshiramiz
      if (_selected.intersection(_target).length == _targetCount) {
        _evaluate(true);
      }
    } else {
      // Bitta xato katak = raund muvaffaqiyatsiz
      _evaluate(false);
    }
  }

  void _evaluate(bool correct) {
    _timer?.cancel();
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: null);
    setState(() {
      _phase = correct ? _GamePhase.correct : _GamePhase.wrong;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _timer = Timer(const Duration(milliseconds: 1200), _advance);
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
        title: Text(L10n.t('matrix.title')),
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
          const SizedBox(height: 22),
          _phaseLabel(),
          Expanded(child: Center(child: _buildGrid())),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _statusBar() {
    return Row(
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

  Widget _phaseLabel() {
    final info = _phaseInfo();
    return Text(
      info.$1,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: info.$2,
        letterSpacing: -0.02,
        height: 1.0,
      ),
    )
        .animate(key: ValueKey('phase-$_phase'))
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.1, end: 0, duration: 220.ms);
  }

  (String, Color) _phaseInfo() {
    switch (_phase) {
      case _GamePhase.ready:
        return (L10n.t('game.ready'), AppColors.pureWhite.withValues(alpha: 0.55));
      case _GamePhase.memorize:
        return (L10n.t('matrix.memorize'), AppColors.plasmaYellow);
      case _GamePhase.recall:
        return (L10n.t('matrix.recall'), AppColors.neuronGreen);
      case _GamePhase.correct:
        return (L10n.t('matrix.found'), AppColors.neuronGreen);
      case _GamePhase.wrong:
        return (L10n.t('matrix.missed'), AppColors.accentRed);
    }
  }

  Widget _buildGrid() {
    return AspectRatio(
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
    );
  }

  Widget _buildCell(int index) {
    final isTarget = _target.contains(index);
    final isSelected = _selected.contains(index);

    Color bg;
    Widget? icon;

    switch (_phase) {
      case _GamePhase.memorize:
        bg = isTarget
            ? AppColors.professorWarmth.withValues(alpha: 0.55)
            : AppColors.cosmicMid;
        if (isTarget) {
          icon = const Icon(Icons.star_rounded,
              color: AppColors.pureWhite, size: 24);
        }
        break;
      case _GamePhase.recall:
        if (isSelected && isTarget) {
          bg = AppColors.neuronGreen.withValues(alpha: 0.5);
          icon = const Icon(Icons.check_rounded,
              color: AppColors.pureWhite, size: 22);
        } else if (isSelected && !isTarget) {
          bg = AppColors.accentRed.withValues(alpha: 0.5);
          icon = const Icon(Icons.close_rounded,
              color: AppColors.pureWhite, size: 22);
        } else {
          bg = AppColors.cosmicMid;
        }
        break;
      case _GamePhase.correct:
        bg = isTarget
            ? AppColors.neuronGreen.withValues(alpha: 0.5)
            : AppColors.cosmicMid;
        if (isTarget) {
          icon = const Icon(Icons.check_rounded,
              color: AppColors.pureWhite, size: 22);
        }
        break;
      case _GamePhase.wrong:
        if (isTarget) {
          bg = AppColors.professorWarmth.withValues(alpha: 0.4);
          icon = const Icon(Icons.star_rounded,
              color: AppColors.pureWhite, size: 22);
        } else if (isSelected) {
          bg = AppColors.accentRed.withValues(alpha: 0.5);
          icon = const Icon(Icons.close_rounded,
              color: AppColors.pureWhite, size: 22);
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
