import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';

/// "Akademiya" — reyting, duel, klub
class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
      child: NeuralBackdrop(
        intensity: 0.7,
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 40),
              _selfRecord(),
              const SizedBox(height: 40),
              SectionHeader(
                  index: L10n.t('garden.soon'),
                  title: L10n.t('academy.competitions')),
              const SizedBox(height: 24),
              _featureRow(
                index: 1,
                emoji: '🏆',
                title: L10n.t('academy.f1.title'),
                category: L10n.t('academy.f1.cat'),
                description: L10n.t('academy.f1.desc'),
                accent: AppColors.plasmaYellow,
              ),
              _featureRow(
                index: 2,
                emoji: '⚔️',
                title: L10n.t('academy.f2.title'),
                category: L10n.t('academy.f2.cat'),
                description: L10n.t('academy.f2.desc'),
                accent: AppColors.accentRed,
              ),
              _featureRow(
                index: 3,
                emoji: '👥',
                title: L10n.t('academy.f3.title'),
                category: L10n.t('academy.f3.cat'),
                description: L10n.t('academy.f3.desc'),
                accent: AppColors.neuronGreen,
              ),
              _featureRow(
                index: 4,
                emoji: '🎖️',
                title: L10n.t('academy.f4.title'),
                category: L10n.t('academy.f4.cat'),
                description: L10n.t('academy.f4.desc'),
                accent: AppColors.pureWhite,
              ),
            ],
          ),
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
              '04',
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
          L10n.t('nav.academy'),
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
          L10n.t('academy.subtitle'),
          style: TextStyle(
            fontSize: 15,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // Hero: "o'zingiz bilan poyga" — solo state
  Widget _selfRecord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentTag(label: L10n.t('academy.state'), color: AppColors.plasmaYellow),
        const SizedBox(height: 14),
        Text(
          L10n.t('academy.selfRace'),
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            height: 1.1,
            letterSpacing: -0.025,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          L10n.t('academy.selfRaceDesc'),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.04, end: 0);
  }

  Widget _featureRow({
    required int index,
    required String emoji,
    required String title,
    required String category,
    required String description,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.pureWhite.withValues(alpha: 0.35),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
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
                        AccentTag(label: category, color: accent),
                        const Spacer(),
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pureWhite,
                        letterSpacing: -0.015,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.pureWhite.withValues(alpha: 0.55),
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
    ).animate(delay: (200 + index * 80).ms).fadeIn(duration: 320.ms).slideY(
        begin: 0.06, end: 0, curve: Curves.easeOutQuart);
  }
}
