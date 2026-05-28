import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';
import 'adaptive_flow_engine.dart';

/// Yuzlarni eslab qolish — cheksiz adaptiv qisqa muddatli vizual xotira
/// (face-name binding). Ilmiy asos: fusiform face area + hippocampal binding.
/// Haqiqiy inson yuzlari (randomuser.me), jinsga mos o'zbek ismlari bilan.
class FaceMatchGame extends StatefulWidget {
  const FaceMatchGame({super.key});

  @override
  State<FaceMatchGame> createState() => _FaceMatchGameState();
}

enum _Phase { loading, memorize, quiz }

class _Character {
  final String name;
  final String photoUrl;
  const _Character(this.name, this.photoUrl);
}

class _FaceMatchGameState extends State<FaceMatchGame> {
  static const int memorizeSeconds = 5;

  static const List<String> _maleNames = [
    'Aziz', 'Bekzod', 'Sardor', 'Jasur', 'Otabek', 'Shahzod',
  ];
  static const List<String> _femaleNames = [
    'Madina', 'Nilufar', 'Kamola', 'Dilnoza', 'Zarina', 'Malika',
  ];

  final Random _rng = Random();
  final AdaptiveFlowEngine _engine = AdaptiveFlowEngine(alpha: 0.14, beta: 0.20);

  _Phase _phase = _Phase.loading;
  bool _error = false;

  List<_Character> _characters = [];
  List<String> _quizOrder = [];
  int _quizIndex = 0;
  int _secondsLeft = memorizeSeconds;
  int? _selectedIndex;
  bool? _lastCorrect;
  bool _finished = false;
  bool _levelUp = false;
  Timer? _timer;

  // Qiyinchilik darajaga qarab o'sadi (3..5 yuz), name pool'lari yetarli.
  int get _facesPerRound => (3 + (_engine.level - 1) ~/ 2).clamp(3, 5);

  String? get _currentName =>
      (_phase == _Phase.quiz && _quizIndex < _quizOrder.length)
          ? _quizOrder[_quizIndex]
          : null;

  @override
  void initState() {
    super.initState();
    _loadRoundContent();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRoundContent() async {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.loading;
      _error = false;
    });
    try {
      final count = _facesPerRound;
      final people = await _fetchPeople(count);
      final male = List<String>.from(_maleNames)..shuffle(_rng);
      final female = List<String>.from(_femaleNames)..shuffle(_rng);
      var mi = 0;
      var fi = 0;
      final chars = <_Character>[];
      for (final p in people) {
        final isMale = p.$1 == 'male';
        final name = isMale ? male[mi++ % male.length] : female[fi++ % female.length];
        chars.add(_Character(name, p.$2));
      }
      _characters = chars;
      _quizOrder = chars.map((c) => c.name).toList()..shuffle(_rng);
      _quizIndex = 0;
      _selectedIndex = null;
      _lastCorrect = null;
      _levelUp = false;
      if (!mounted) return;
      setState(() {
        _phase = _Phase.memorize;
        _secondsLeft = memorizeSeconds;
      });
      _startMemorizeTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.loading;
        _error = true;
      });
    }
  }

  // randomuser.me: har bir odam uchun jins + rasm birga keladi
  Future<List<(String, String)>> _fetchPeople(int count) async {
    final uri = Uri.parse(
        'https://randomuser.me/api/?results=$count&inc=gender,picture&noinfo');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('status ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List;
    return results.map<(String, String)>((r) {
      final gender = r['gender'] as String;
      final pic = (r['picture'] as Map)['large'] as String;
      // randomuser portretlarida CORS header yo'q → Flutter web (CanvasKit)
      // ularni yuklay olmaydi. weserv.nl proxy CORS qo'shadi (mobilда zararsiz).
      final bare = pic.replaceFirst(RegExp(r'^https?://'), '');
      final proxied = 'https://images.weserv.nl/?url=$bare';
      return (gender, proxied);
    }).toList();
  }

  void _startMemorizeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _startQuiz();
      }
    });
  }

  void _startQuiz() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.quiz;
      _characters = List<_Character>.from(_characters)..shuffle(_rng);
    });
  }

  void _answer(int index) {
    if (_phase != _Phase.quiz || _selectedIndex != null) return;
    _timer?.cancel();
    final correct = _characters[index].name == _currentName;
    final prevLevel = _engine.level;
    _engine.registerRound(correct: correct, reactionTime: null);
    setState(() {
      _selectedIndex = index;
      _lastCorrect = correct;
      _levelUp = _engine.level > prevLevel;
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_engine.gainedLife) HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    _timer = Timer(const Duration(milliseconds: 900), _nextQuestion);
  }

  void _nextQuestion() {
    if (!mounted) return;
    if (_engine.isGameOver) {
      _finish();
      return;
    }
    _quizIndex++;
    if (_quizIndex >= _quizOrder.length) {
      // Raund tugadi — yangi (ehtimol qiyinroq) raund.
      _loadRoundContent();
    } else {
      setState(() {
        _selectedIndex = null;
        _lastCorrect = null;
        _characters = List<_Character>.from(_characters)..shuffle(_rng);
      });
    }
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
    setState(() => _finished = false);
    _loadRoundContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('face.title')),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _body(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_finished) return _resultView();
    switch (_phase) {
      case _Phase.loading:
        return _loadingView();
      case _Phase.memorize:
        return _memorizeView();
      case _Phase.quiz:
        return _quizView();
    }
  }

  Widget _loadingView() {
    if (_error) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            L10n.t('face.loadError'),
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.t('face.checkConnection'),
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadRoundContent,
            child: Text(L10n.t('game.retry')),
          ),
        ],
      );
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.neuronGreen),
    );
  }

  Widget _memorizeView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _topLabel('${L10n.t('face.round')} ${_engine.round.toString().padLeft(2, '0')}'),
        const SizedBox(height: 28),
        Text(
          L10n.t('face.memorize'),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.02,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.t('face.memorizeHint'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 20),
        _countdownPill(),
        const Spacer(),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: _characters
              .map((c) => _avatarTile(c, showName: true, size: 104))
              .toList(),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startQuiz,
            child: Text(L10n.t('game.ready')),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _quizView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        _statusBar(),
        const Spacer(),
        Text(
          L10n.t('face.whoIs'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _currentName ?? '',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.03,
            height: 1.0,
          ),
        ).animate(key: ValueKey('name-${_engine.round}-$_quizIndex')).fadeIn(
            duration: 220.ms),
        const Spacer(),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: List.generate(_characters.length, (i) {
            final c = _characters[i];
            return _avatarTile(
              c,
              showName: false,
              size: 104,
              borderColor: _borderFor(i, c),
              onTap: () => _answer(i),
            );
          }),
        ),
        const Spacer(),
      ],
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

  Color _borderFor(int i, _Character c) {
    if (_selectedIndex == null) {
      return AppColors.pureWhite.withValues(alpha: 0.08);
    }
    final isAnswer = c.name == _currentName;
    if (isAnswer) return AppColors.neuronGreen;
    if (_selectedIndex == i && _lastCorrect == false) return AppColors.accentRed;
    return AppColors.pureWhite.withValues(alpha: 0.08);
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

  Widget _topLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.pureWhite.withValues(alpha: 0.6),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _countdownPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neuronGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '$_secondsLeft',
        style: const TextStyle(
          color: AppColors.neuronGreen,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _avatarTile(
    _Character c, {
    required bool showName,
    required double size,
    Color borderColor = Colors.transparent,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cosmicMid,
              border: Border.all(color: borderColor, width: 3),
            ),
            child: ClipOval(
              child: Image.network(
                c.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, prog) => prog == null
                    ? child
                    : const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neuronGreen,
                          ),
                        ),
                      ),
                errorBuilder: (ctx, e, st) => Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppColors.pureWhite.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 12),
            Text(
              c.name,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
