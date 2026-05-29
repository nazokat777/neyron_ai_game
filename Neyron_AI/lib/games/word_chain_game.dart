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

/// So'zlar zanjiri (Memory Palace) — cheksiz adaptiv ketma-ketlik xotirasi
/// Ilmiy asos: serial-order working memory + episodik bog'lanish (hippocampus)
class WordChainGame extends StatefulWidget {
  const WordChainGame({super.key});

  @override
  State<WordChainGame> createState() => _WordChainGameState();
}

enum _Phase { showing, recall, feedback }

class _WordChainGameState extends State<WordChainGame> {
  static const int minChain = 3;
  static const List<String> _wordPool = [
    'Olma', 'Mashina', 'Kitob', 'Daraxt', 'Quyosh', 'Stol',
    'Kalit', 'Gul', 'Daryo', 'Tog\'', 'Non', 'Choy',
    'Soat', 'Eshik', 'Oyna', 'Qush', 'Baliq', 'Bulut',
    'Yulduz', 'Qalam', 'Telefon', 'Ko\'prik', 'Bog\'', 'Chiroq',
    'Poyabzal', 'Soyabon', 'Quti', 'Tosh',
  ];

  final Random _rng = Random();
  // Sof xotira o'yini — vaqt o'lchanmaydi, alpha yuqoriroq.
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(alpha: 0.16, beta: 0.20);

  int _maxChain = minChain;
  bool _levelUp = false;

  List<String> _sequence = [];
  List<String> _options = [];
  final List<int> _picked = []; // tanlangan option indekslari (tartibda)
  int _showIndex = -1;
  _Phase _phase = _Phase.showing;
  bool _finished = false;
  Timer? _timer;

  // D dan zanjir uzunligini hisoblaydi (minimum 3, cheksiz o'sadi)
  int get _chainLength => minChain + (_engine.level - 1);

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

  String? get _visibleWord =>
      (_showIndex >= 0 && _showIndex < _sequence.length)
          ? _sequence[_showIndex]
          : null;

  void _startRound() {
    final len = max(minChain, _chainLength);
    if (len > _maxChain) _maxChain = len;
    final pool = List<String>.from(_wordPool)..shuffle(_rng);
    _sequence = pool.take(len).toList();
    // Variantlar: zanjir so'zlari + 2 chalg'ituvchi, aralashtirilgan
    final distractors = pool.skip(len).take(2).toList();
    _options = [..._sequence, ...distractors]..shuffle(_rng);
    _picked.clear();
    setState(() {
      _phase = _Phase.showing;
      _showIndex = -1;
      _levelUp = false;
    });
    _showStep(0);
  }

  // Har so'z 1.5s ko'rsatiladi, 0.3s tanaffus bilan ketma-ket
  void _showStep(int i) {
    if (!mounted) return;
    if (i >= _sequence.length) {
      setState(() {
        _showIndex = -1;
        _phase = _Phase.recall;
      });
      return;
    }
    setState(() => _showIndex = i);
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _showIndex = -1);
      _timer = Timer(const Duration(milliseconds: 300), () => _showStep(i + 1));
    });
  }

  void _pickOption(int optIndex) {
    if (_phase != _Phase.recall || _picked.contains(optIndex)) return;
    HapticFeedback.selectionClick();
    setState(() => _picked.add(optIndex));
    if (_picked.length >= _sequence.length) _evaluate();
  }

  void _undo() {
    if (_phase != _Phase.recall || _picked.isEmpty) return;
    setState(() => _picked.removeLast());
  }

  void _evaluate() {
    final answer = _picked.map((i) => _options[i]).toList();
    final correct = _listEquals(answer, _sequence);
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: null);
    setState(() {
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
    _timer = Timer(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      if (_engine.isGameOver) {
        _finish();
      } else {
        _startRound();
      }
    });
  }

  bool _listEquals(List<String> a, List<String> b) {
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
      _maxChain = minChain;
      _picked.clear();
      _levelUp = false;
      _finished = false;
    });
    _startRound();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('wordchain.title')),
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
          Expanded(
            child: _phase == _Phase.showing ? _showingStage() : _recallStage(),
          ),
          const SizedBox(height: 16),
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
            '${L10n.t('wordchain.chain')} ${max(minChain, _chainLength).toString().padLeft(2, '0')}',
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
      children: List.generate(
        _engine.lives,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(Icons.favorite, size: 14, color: AppColors.accentRed),
        ),
      ),
    );
  }

  Widget _showingStage() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: Text(
          _visibleWord ?? '',
          key: ValueKey('w-$_showIndex'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.02,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _recallStage() {
    final isFeedback = _phase == _Phase.feedback;
    return Column(
      children: [
        Text(
          L10n.t('wordchain.repeatOrder'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        // Tanlangan so'zlar — tartib bilan
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(_sequence.length, (i) {
            final filled = i < _picked.length;
            final word = filled ? _options[_picked[i]] : '';
            Color border = AppColors.pureWhite.withValues(alpha: 0.1);
            Color text = AppColors.pureWhite;
            if (isFeedback && filled) {
              final ok = word == _sequence[i];
              border = ok ? AppColors.neuronGreen : AppColors.accentRed;
              text = ok ? AppColors.neuronGreen : AppColors.accentRed;
            }
            return Container(
              constraints: const BoxConstraints(minWidth: 64),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cosmicMid,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: filled ? border : AppColors.pureWhite.withValues(alpha: 0.06),
                  width: filled ? 1.5 : 1,
                ),
              ),
              child: Text(
                filled ? word : '·',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: filled ? text : AppColors.pureWhite.withValues(alpha: 0.25),
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        // Variantlar
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_options.length, (i) {
            final used = _picked.contains(i);
            return _optionChip(_options[i], used, () => _pickOption(i));
          }),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: (_picked.isEmpty || isFeedback) ? null : _undo,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.pureWhite.withValues(alpha: 0.6),
          ),
          child: Text(L10n.t('wordchain.back')),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _optionChip(String word, bool used, VoidCallback onTap) {
    return GestureDetector(
      onTap: used ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: used ? 0.25 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cosmicMid,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.pureWhite.withValues(alpha: 0.08),
            ),
          ),
          child: Text(
            word,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.pureWhite,
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
          _statRow(L10n.t('wordchain.bestChain'), '$_maxChain'),
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
