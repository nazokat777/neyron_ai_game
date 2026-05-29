import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';
import '../widgets/game_instruction_overlay.dart';
import '../games/shulte_game.dart';
import '../games/memory_matrix_game.dart';
import '../games/stroop_game.dart';
import '../games/quick_math_game.dart';
import '../games/dual_decision_game.dart';
import '../games/number_span_game.dart';
import '../games/face_match_game.dart';
import '../games/word_chain_game.dart';
import '../games/dual_nback_game.dart';
import '../games/flanker_task_game.dart';

/// Laboratoriya — Professor'ning konspekti.
/// Editorial typographic list: katta sarlavhalar, mayda meta, no chrome.
class LabScreen extends StatelessWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 40),
              ..._games(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '05',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.pureWhite.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            const BrainMark(size: 24),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          L10n.t('nav.lab'),
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.025,
            height: 1.0,
          ),
        ).animate().fadeIn().slideX(begin: -0.02, end: 0),
        const SizedBox(height: 16),
        Text(
          L10n.t('lab.subtitle'),
          style: TextStyle(
            fontSize: 15,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  List<Widget> _games(BuildContext context) {
    final items = [
      _GameItem(
        index: 1,
        gameKey: 'shulte',
        title: L10n.t('lab.shulte.title'),
        category: L10n.t('lab.shulte.cat'),
        duration: L10n.t('lab.shulte.dur'),
        description: L10n.t('lab.shulte.desc'),
        accent: AppColors.plasmaYellow,
        builder: () => const ShulteGame(),
      ),
      _GameItem(
        index: 2,
        gameKey: 'memory_matrix',
        title: L10n.t('lab.memory_matrix.title'),
        category: L10n.t('lab.memory_matrix.cat'),
        duration: L10n.t('lab.memory_matrix.dur'),
        description: L10n.t('lab.memory_matrix.desc'),
        accent: AppColors.neuronGreen,
        builder: () => const MemoryMatrixGame(),
      ),
      _GameItem(
        index: 3,
        gameKey: 'dual_decision',
        title: L10n.t('lab.dual_decision.title'),
        category: L10n.t('lab.dual_decision.cat'),
        duration: L10n.t('lab.dual_decision.dur'),
        description: L10n.t('lab.dual_decision.desc'),
        accent: AppColors.plasmaYellow,
        builder: () => const DualDecisionGame(),
      ),
      _GameItem(
        index: 4,
        gameKey: 'stroop',
        title: L10n.t('lab.stroop.title'),
        category: L10n.t('lab.stroop.cat'),
        duration: L10n.t('lab.stroop.dur'),
        description: L10n.t('lab.stroop.desc'),
        accent: AppColors.gameRed,
        builder: () => const StroopGame(),
      ),
      _GameItem(
        index: 5,
        gameKey: 'quick_math',
        title: L10n.t('lab.quick_math.title'),
        category: L10n.t('lab.quick_math.cat'),
        duration: L10n.t('lab.quick_math.dur'),
        description: L10n.t('lab.quick_math.desc'),
        accent: AppColors.gameBlue,
        builder: () => const QuickMathGame(),
      ),
      _GameItem(
        index: 6,
        gameKey: 'number_span',
        title: L10n.t('lab.number_span.title'),
        category: L10n.t('lab.number_span.cat'),
        duration: L10n.t('lab.number_span.dur'),
        description: L10n.t('lab.number_span.desc'),
        accent: AppColors.neuronGreen,
        builder: () => const NumberSpanGame(),
      ),
      _GameItem(
        index: 7,
        gameKey: 'face_match',
        title: L10n.t('lab.face_match.title'),
        category: L10n.t('lab.face_match.cat'),
        duration: L10n.t('lab.face_match.dur'),
        description: L10n.t('lab.face_match.desc'),
        accent: AppColors.plasmaYellow,
        builder: () => const FaceMatchGame(),
      ),
      _GameItem(
        index: 8,
        gameKey: 'word_chain',
        title: L10n.t('lab.word_chain.title'),
        category: L10n.t('lab.word_chain.cat'),
        duration: L10n.t('lab.word_chain.dur'),
        description: L10n.t('lab.word_chain.desc'),
        accent: AppColors.neuronGreen,
        builder: () => const WordChainGame(),
      ),
      _GameItem(
        index: 9,
        gameKey: 'dual_nback',
        title: L10n.t('lab.dual_nback.title'),
        category: L10n.t('lab.dual_nback.cat'),
        duration: L10n.t('lab.dual_nback.dur'),
        description: L10n.t('lab.dual_nback.desc'),
        accent: AppColors.gameBlue,
        builder: () => const DualNBackGame(),
      ),
      _GameItem(
        index: 10,
        gameKey: 'flanker',
        title: L10n.t('lab.flanker.title'),
        category: L10n.t('lab.flanker.cat'),
        duration: L10n.t('lab.flanker.dur'),
        description: L10n.t('lab.flanker.desc'),
        accent: AppColors.gameRed,
        builder: () => const FlankerTaskGame(),
      ),
    ];

    return List.generate(items.length, (i) {
      final item = items[i];
      return _gameRow(context, item)
          .animate(delay: (120 + i * 80).ms)
          .fadeIn(duration: 320.ms)
          .slideY(begin: 0.06, end: 0, curve: Curves.easeOutQuart);
    });
  }

  Widget _gameRow(BuildContext context, _GameItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: AppColors.cosmicDeep,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  foregroundColor: AppColors.pureWhite,
                ),
                body: GameInstructionOverlay(
                  gameKey: item.gameKey,
                  onStart: () => Navigator.of(ctx).pushReplacement(
                    MaterialPageRoute(builder: (_) => item.builder()),
                  ),
                ),
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        item.index.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.pureWhite.withValues(alpha: 0.35),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          fontFeatures:
                              const [FontFeature.tabularFigures()],
                          height: 1.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: item.accent,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: item.accent,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item.duration,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.pureWhite
                                      .withValues(alpha: 0.4),
                                  fontFeatures:
                                      const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.pureWhite,
                              letterSpacing: -0.02,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.pureWhite
                                  .withValues(alpha: 0.55),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 0.5,
                  color: AppColors.pureWhite.withValues(alpha: 0.08),
                  margin: const EdgeInsets.only(left: 36),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameItem {
  final int index;
  final String gameKey;
  final String title;
  final String category;
  final String duration;
  final String description;
  final Color accent;
  final Widget Function() builder;

  const _GameItem({
    required this.index,
    required this.gameKey,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.accent,
    required this.builder,
  });
}
