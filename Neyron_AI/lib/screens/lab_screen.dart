import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../games/shulte_game.dart';
import '../games/memory_matrix_game.dart';
import '../games/stroop_game.dart';
import '../games/quick_math_game.dart';
import '../games/dual_decision_game.dart';

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
        const SizedBox(height: 4),
        const Text(
          'Mashqlar',
          style: TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.025,
            height: 1.0,
          ),
        ).animate().fadeIn().slideX(begin: -0.02, end: 0),
        const SizedBox(height: 16),
        Text(
          'Har xona — alohida eksperiment',
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
        title: 'Shulte jadvali',
        category: 'E\'tibor',
        duration: '3–5 daq',
        description: 'Vizual diqqat va periferik ko\'rishni mashq qiladi.',
        accent: AppColors.plasmaYellow,
        builder: () => const ShulteGame(),
      ),
      _GameItem(
        index: 2,
        title: 'Xotira matritsasi',
        category: 'Xotira',
        duration: '5–7 daq',
        description: 'Ishchi xotira va naqsh esda saqlash.',
        accent: AppColors.neuronGreen,
        builder: () => const MemoryMatrixGame(),
      ),
      _GameItem(
        index: 3,
        title: 'Ikki qaror',
        category: 'Tezlik',
        duration: '2–3 daq',
        description: 'Reaksiya tezligi va qoidaga moslashish.',
        accent: AppColors.plasmaYellow,
        builder: () => const DualDecisionGame(),
      ),
      _GameItem(
        index: 4,
        title: 'Stroop testi',
        category: 'Diqqat',
        duration: '2–3 daq',
        description: 'Rang va so\'z konfliktini yengish.',
        accent: AppColors.gameRed,
        builder: () => const StroopGame(),
      ),
      _GameItem(
        index: 5,
        title: 'Tez hisob',
        category: 'Mantiq',
        duration: '2–3 daq',
        description: 'Arifmetik chaqqonlik.',
        accent: AppColors.gameBlue,
        builder: () => const QuickMathGame(),
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
            MaterialPageRoute(builder: (_) => item.builder()),
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
  final String title;
  final String category;
  final String duration;
  final String description;
  final Color accent;
  final Widget Function() builder;

  const _GameItem({
    required this.index,
    required this.title,
    required this.category,
    required this.duration,
    required this.description,
    required this.accent,
    required this.builder,
  });
}
