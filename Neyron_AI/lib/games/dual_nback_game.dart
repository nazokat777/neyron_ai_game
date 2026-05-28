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

/// Dual N-Back — cheksiz adaptiv ishchi xotira (eng kuchli kognitiv mashq)
/// Ilmiy asos: prefrontal + parietal yangilanuvchi ishchi xotira (updating)
/// N darajasi moslashadi: yaxshi blok → N+1, yomon blok → jon−1 va N−1.
class DualNBackGame extends StatefulWidget {
  const DualNBackGame({super.key});

  @override
  State<DualNBackGame> createState() => _DualNBackGameState();
}

enum _Phase { intro, playing, blockEnd }

class _DualNBackGameState extends State<DualNBackGame> {
  static const List<String> _letters = ['Q', 'K', 'L', 'M', 'R', 'T', 'S', 'H'];
  static const Duration _trialDuration = Duration(milliseconds: 2500);

  final Random _rng = Random();
  // Blokga asoslangan adaptatsiya; har 4 yaxshi blokda bonus jon.
  final AdaptiveFlowEngine _engine =
      AdaptiveFlowEngine(alpha: 0.16, beta: 0.20, streakForBonusLife: 4);

  int _nBack = 2;
  int _maxNBack = 2;
  int _score = 0;
  bool _levelUp = false;
  bool _finished = false;

  _Phase _phase = _Phase.intro;
  int _trialsPerBlock = 14;
  int _trialIndex = -1;
  final List<int> _posHist = [];
  final List<String> _letterHist = [];
  bool _posPressed = false;
  bool _letterPressed = false;
  int _blockErrors = 0;
  bool _lastBlockGood = false;
  Timer? _timer;

  int get _activePos =>
      (_phase == _Phase.playing && _trialIndex >= 0 && _trialIndex < _posHist.length)
          ? _posHist[_trialIndex]
          : -1;
  String get _currentLetter =>
      (_phase == _Phase.playing && _trialIndex >= 0 && _trialIndex < _letterHist.length)
          ? _letterHist[_trialIndex]
          : '';

  @override
  void initState() {
    super.initState();
    _startBlock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startBlock() {
    _trialsPerBlock = 12 + _nBack;
    _posHist.clear();
    _letterHist.clear();
    _trialIndex = -1;
    _blockErrors = 0;
    setState(() => _phase = _Phase.intro);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1300), _beginTrials);
  }

  void _beginTrials() {
    if (!mounted) return;
    setState(() => _phase = _Phase.playing);
    _spawnTrial();
    _timer = Timer.periodic(_trialDuration, (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    _commitTrial();
    if (_trialIndex + 1 >= _trialsPerBlock) {
      _endBlock();
    } else {
      _spawnTrial();
    }
  }

  void _spawnTrial() {
    _trialIndex++;
    int pos;
    String letter;
    // ~30% holatda N-back moslik majburan yaratiladi (nishonlar paydo bo'lishi uchun)
    if (_trialIndex >= _nBack && _rng.nextDouble() < 0.3) {
      pos = _posHist[_trialIndex - _nBack];
    } else {
      pos = _rng.nextInt(9);
    }
    if (_trialIndex >= _nBack && _rng.nextDouble() < 0.3) {
      letter = _letterHist[_trialIndex - _nBack];
    } else {
      letter = _letters[_rng.nextInt(_letters.length)];
    }
    _posHist.add(pos);
    _letterHist.add(letter);
    setState(() {
      _posPressed = false;
      _letterPressed = false;
    });
  }

  void _commitTrial() {
    if (_trialIndex < _nBack) {
      // Moslik bo'lishi mumkin emas — har qanday bosish noto'g'ri (false alarm)
      if (_posPressed) _blockErrors++;
      if (_letterPressed) _blockErrors++;
      return;
    }
    final posMatch = _posHist[_trialIndex] == _posHist[_trialIndex - _nBack];
    final letterMatch =
        _letterHist[_trialIndex] == _letterHist[_trialIndex - _nBack];

    if (posMatch && _posPressed) {
      _score += 10 * _nBack;
    } else if (posMatch != _posPressed) {
      _blockErrors++; // miss yoki false alarm
    }

    if (letterMatch && _letterPressed) {
      _score += 10 * _nBack;
    } else if (letterMatch != _letterPressed) {
      _blockErrors++;
    }
  }

  void _endBlock() {
    _timer?.cancel();
    final blockGood = _blockErrors <= 2;
    final prevN = _nBack;
    _engine.registerRound(correct: blockGood, reactionTime: null);
    if (blockGood) {
      _nBack++;
    } else {
      _nBack = max(2, _nBack - 1);
    }
    if (_nBack > _maxNBack) _maxNBack = _nBack;
    setState(() {
      _lastBlockGood = blockGood;
      _levelUp = _nBack > prevN;
      _phase = _Phase.blockEnd;
    });
    if (blockGood) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _timer = Timer(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      if (_engine.isGameOver) {
        _finish();
      } else {
        _startBlock();
      }
    });
  }

  void _press(bool position) {
    if (_phase != _Phase.playing) return;
    setState(() {
      if (position) {
        _posPressed = true;
      } else {
        _letterPressed = true;
      }
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _finish() async {
    _timer?.cancel();
    setState(() => _finished = true);
    final state = context.read<AppState>();
    await state.incrementSessions();
    final coins =
        (5 + _maxNBack * 3 + _engine.bestStreak * 2).clamp(1, 80);
    await state.addCoins(coins);
  }

  void _restart() {
    _timer?.cancel();
    _engine.reset();
    setState(() {
      _nBack = 2;
      _maxNBack = 2;
      _score = 0;
      _levelUp = false;
      _finished = false;
    });
    _startBlock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('nback.title')),
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
          const SizedBox(height: 8),
          Expanded(child: _stage()),
          const SizedBox(height: 16),
          _buttons(),
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
          '$_score',
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
      '$_nBack-BACK',
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
        .animate(key: ValueKey('n-$_nBack'))
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

  Widget _stage() {
    if (_phase == _Phase.intro) {
      return Center(
        child: Text(
          '$_nBack-BACK',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.02,
          ),
        ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.85, 0.85), curve: Curves.easeOutQuart),
      );
    }
    if (_phase == _Phase.blockEnd) {
      final color = _lastBlockGood ? AppColors.neuronGreen : AppColors.accentRed;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _lastBlockGood
                  ? L10n.t('nback.goodBlock')
                  : L10n.t('nback.tooManyErrors'),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _lastBlockGood ? '$_nBack-BACK' : '$_nBack-BACK',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w600,
                color: AppColors.pureWhite,
              ),
            ),
          ],
        ),
      );
    }
    // playing
    return Column(
      children: [
        const Spacer(),
        Text(
          _currentLetter,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 24),
        _grid(),
        const Spacer(),
      ],
    );
  }

  Widget _grid() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          final active = i == _activePos;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: AppColors.cosmicMid,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.06),
              ),
            ),
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: active ? 1 : 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gameBlue,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        Expanded(
          child: _matchButton(
            label: L10n.t('nback.positionMatch'),
            pressed: _posPressed,
            onTap: () => _press(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _matchButton(
            label: L10n.t('nback.letterMatch'),
            pressed: _letterPressed,
            onTap: () => _press(false),
          ),
        ),
      ],
    );
  }

  Widget _matchButton({
    required String label,
    required bool pressed,
    required VoidCallback onTap,
  }) {
    final enabled = _phase == _Phase.playing;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: pressed
              ? AppColors.gameBlue.withValues(alpha: 0.25)
              : AppColors.cosmicMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: pressed
                ? AppColors.gameBlue
                : AppColors.pureWhite.withValues(alpha: 0.08),
            width: pressed ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? AppColors.pureWhite
                  : AppColors.pureWhite.withValues(alpha: 0.35),
            ),
          ),
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
            '$_score',
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
          _statRow(L10n.t('game.bestLevel'), '$_maxNBack-BACK'),
          const SizedBox(height: 10),
          _statRow(L10n.t('game.bestStreak'), '${_engine.bestStreak}'),
          const SizedBox(height: 10),
          _statRow(L10n.t('nback.blocks'), '${_engine.round}'),
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
