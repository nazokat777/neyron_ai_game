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

/// Raqamlar qatori — ishchi xotira (working memory span)
/// Ilmiy asos: fonologik halqa (Baddeley) + prefrontal korteks
/// Cheksiz adaptiv rejim: daraja oshgani sayin qator uzayadi.
class NumberSpanGame extends StatefulWidget {
  const NumberSpanGame({super.key});

  @override
  State<NumberSpanGame> createState() => _NumberSpanGameState();
}

enum _Phase { showing, input, feedback }

class _NumberSpanGameState extends State<NumberSpanGame> {
  static const int minSpan = 3;

  final Random _rng = Random();
  // Sof xotira o'yini — vaqt o'lchanmaydi, alpha yuqoriroq.
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(alpha: 0.16, beta: 0.20);

  int _maxSpan = minSpan;
  bool _levelUp = false;

  List<int> _sequence = [];
  List<int> _input = [];
  int _showIndex = -1;
  bool? _lastCorrect;
  _Phase _phase = _Phase.showing;
  bool _finished = false;
  Timer? _timer;

  // D dan qator uzunligini hisoblaydi (minimum 3, cheksiz o'sadi)
  int get _spanLength => minSpan + (_engine.level - 1);

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int? get _visibleDigit =>
      (_showIndex >= 0 && _showIndex < _sequence.length)
          ? _sequence[_showIndex]
          : null;

  void _startRound() {
    _input = [];
    _lastCorrect = null;
    final span = max(minSpan, _spanLength);
    if (span > _maxSpan) _maxSpan = span;
    _sequence = List.generate(span, (_) => _rng.nextInt(10));
    setState(() {
      _phase = _Phase.showing;
      _showIndex = -1;
      _levelUp = false;
    });
    _showStep(0);
  }

  // Har raqam 700ms ko'rsatiladi, 250ms tanaffus bilan ketma-ket
  void _showStep(int i) {
    if (!mounted) return;
    if (i >= _sequence.length) {
      setState(() {
        _showIndex = -1;
        _phase = _Phase.input;
      });
      return;
    }
    setState(() => _showIndex = i);
    _timer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _showIndex = -1);
      _timer = Timer(const Duration(milliseconds: 250), () => _showStep(i + 1));
    });
  }

  void _tapDigit(int d) {
    if (_phase != _Phase.input) return;
    HapticFeedback.selectionClick();
    setState(() => _input.add(d));
    if (_input.length >= _sequence.length) _evaluate();
  }

  void _backspace() {
    if (_phase != _Phase.input || _input.isEmpty) return;
    setState(() => _input.removeLast());
  }

  void _evaluate() {
    final correct = _seqEquals(_input, _sequence);
    final prevLevel = _engine.level;
    // Sof xotira o'yini — vaqt o'lchanmaydi (reactionTime: null).
    _engine.registerRound(correct: correct, reactionTime: null);
    setState(() {
      _lastCorrect = correct;
      _phase = _Phase.feedback;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_engine.isGameOver) {
        _finish();
      } else {
        _startRound();
      }
    });
  }

  bool _seqEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
    setState(() {
      _maxSpan = minSpan;
      _input = [];
      _levelUp = false;
      _finished = false;
    });
    _startRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('numspan.title')),
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
          const SizedBox(height: 32),
          Expanded(child: _stage()),
          const SizedBox(height: 20),
          _numberPad(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statusBar() {
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
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${L10n.t('numspan.length')} ${max(minSpan, _spanLength).toString().padLeft(2, '0')}',
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
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

  Widget _stage() {
    Color fill = AppColors.cosmicMid.withValues(alpha: 0.4);
    Color border = AppColors.pureWhite.withValues(alpha: 0.06);
    Widget content;

    switch (_phase) {
      case _Phase.showing:
        content = AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            _visibleDigit?.toString() ?? '',
            key: ValueKey('show-$_showIndex'),
            style: const TextStyle(
              fontSize: 140,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
              letterSpacing: -0.04,
              height: 1.0,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
        break;
      case _Phase.input:
        content = _inputSlots();
        break;
      case _Phase.feedback:
        final ok = _lastCorrect == true;
        final color = ok ? AppColors.neuronGreen : AppColors.accentRed;
        fill = color.withValues(alpha: 0.14);
        border = color.withValues(alpha: 0.7);
        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ok ? L10n.t('game.correct') : L10n.t('game.wrong'),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _sequence.join('  '),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: AppColors.pureWhite,
                letterSpacing: 2,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Center(child: content),
    );
  }

  Widget _inputSlots() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_sequence.length, (i) {
        final filled = i < _input.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 42,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cosmicMid,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled
                  ? AppColors.neuronGreen
                  : AppColors.pureWhite.withValues(alpha: 0.08),
              width: filled ? 2 : 1,
            ),
          ),
          child: Text(
            filled ? _input[i].toString() : '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      }),
    );
  }

  Widget _numberPad() {
    final enabled = _phase == _Phase.input;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        for (var d = 1; d <= 9; d++)
          _key('$d', enabled ? () => _tapDigit(d) : null),
        _key('⌫', enabled && _input.isNotEmpty ? _backspace : null),
        _key('0', enabled ? () => _tapDigit(0) : null),
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _key(String label, VoidCallback? onTap) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: active ? 1 : 0.3,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cosmicMid,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.pureWhite.withValues(alpha: 0.06),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppColors.pureWhite,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
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
          _statRow(L10n.t('numspan.bestSpan'), '$_maxSpan'),
          const SizedBox(height: 10),
          _statRow(L10n.t('game.bestStreak'), '${_engine.bestStreak}'),
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
