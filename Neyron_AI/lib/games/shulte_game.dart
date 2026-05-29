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

/// Shulte jadvali — cheksiz adaptiv vizual diqqat va periferik ko'rish mashqi
/// Ilmiy asos: Walter Schulte (1920), 47% diqqat yaxshilanishi (8 hafta mashq)
/// Bir "raund" = bitta to'liq jadvalni 1..N tartibda topish.
class ShulteGame extends StatefulWidget {
  const ShulteGame({super.key});

  @override
  State<ShulteGame> createState() => _ShulteGameState();
}

class _ShulteGameState extends State<ShulteGame> {
  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(
    rtThreshold: 6.0, // 6 soniyadan tez jadval = tezlik bonusi
    maxLatency: 999, // jadval uchun qattiq timeout yo'q — sekinlik faqat bonusni yo'qotadi
    alpha: 0.12,
    beta: 0.18,
  );

  late int _side; // jadval tomoni (3..7)
  late List<int> _numbers;
  int _nextNumber = 1;
  int _mistakes = 0;
  int _lastWrongIndex = -1;
  DateTime _boardStart = DateTime.now();
  bool _finished = false;
  bool _levelUp = false;

  @override
  void initState() {
    super.initState();
    _newBoard();
  }

  // engine.level dan jadval tomonini hisoblaydi: 3x3 (1-daraja) → 7x7
  int _sideForLevel() => (3 + (_engine.level - 1) ~/ 2).clamp(3, 7);

  int get _totalCells => _side * _side;

  void _newBoard() {
    _side = _sideForLevel();
    setState(() {
      _numbers = List.generate(_totalCells, (i) => i + 1)..shuffle(_rng);
      _nextNumber = 1;
      _mistakes = 0;
      _lastWrongIndex = -1;
      _levelUp = false;
      _boardStart = DateTime.now();
    });
  }

  void _onTap(int number, int index) {
    if (_finished) return;

    if (number == _nextNumber) {
      HapticFeedback.selectionClick();
      _nextNumber++;
      if (_nextNumber > _totalCells) {
        _completeBoard();
      } else {
        setState(() {});
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _mistakes++;
        _lastWrongIndex = index;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _lastWrongIndex = -1);
      });
    }
  }

  void _completeBoard() {
    final boardTime =
        DateTime.now().difference(_boardStart).inMilliseconds / 1000.0;
    final correct = _mistakes <= 2;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: boardTime);
    final levelUp = _engine.level > prevLevel;

    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() => _levelUp = levelUp);

    Future.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      if (_engine.isGameOver) {
        _finish();
      } else {
        _newBoard();
      }
    });
  }

  Future<void> _finish() async {
    setState(() => _finished = true);
    final state = context.read<AppState>();
    await state.incrementSessions();
    final coins =
        (5 + _engine.bestStreak * 2 + _engine.level * 2).clamp(1, 80);
    await state.addCoins(coins);
  }

  void _restart() {
    _engine.reset();
    setState(() => _finished = false);
    _newBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('shulte.title')),
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
          const SizedBox(height: 24),
          _heroTarget(),
          const SizedBox(height: 16),
          Expanded(child: Center(child: _buildGrid())),
          const SizedBox(height: 24),
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

  Widget _heroTarget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              L10n.t('shulte.find'),
              style: TextStyle(
                color: AppColors.pureWhite.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            Text(
              _mistakes == 0
                  ? L10n.t('shulte.clean')
                  : '$_mistakes ${L10n.t('shulte.mistakes')}',
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
          '$_nextNumber',
          key: ValueKey('target-$_nextNumber'),
          style: const TextStyle(
            fontSize: 76,
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
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _side,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: _totalCells,
        itemBuilder: (_, i) => _buildCell(i),
      ),
    );
  }

  Widget _buildCell(int index) {
    final number = _numbers[index];
    final isFound = number < _nextNumber;
    final isWrong = index == _lastWrongIndex;
    // Katta jadvalda raqamlar kichikroq bo'lib mos kelsin
    final fontSize = (160 / _side).clamp(18.0, 34.0);

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
              fontSize: isFound ? fontSize * 0.7 : fontSize,
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
