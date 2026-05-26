import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';

/// "Maxsus Bog'lar" — qo'llab-quvvatlovchi makonlar
/// Tibbiy emas — sokin parvarish maydonlari
class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

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
              const SectionHeader(index: 'TEZ ORADA', title: 'Bog\'lar'),
              const SizedBox(height: 24),
              _gardenRow(
                index: 1,
                emoji: '🌳',
                title: 'Xotira Bog\'i',
                category: 'Xotira',
                description:
                    'Kunlik xotiralarni saqlash, yuzlar va joylar bilan ishlash.',
                accent: AppColors.neuronGreen,
              ),
              _gardenRow(
                index: 2,
                emoji: '🌙',
                title: 'Sokin Burchak',
                category: 'Tinchlik',
                description:
                    'Ortiqcha stimullarsiz, ranglar va shakllar bilan tinch o\'yinlar.',
                accent: AppColors.pureWhite,
              ),
              _gardenRow(
                index: 3,
                emoji: '🌸',
                title: 'Mehr Bog\'i',
                category: 'Hissiyot',
                description:
                    'Yuz ifodalari, suhbat ko\'nikmalari va emotsional bog\'lanish.',
                accent: AppColors.plasmaYellow,
              ),
              const SizedBox(height: 24),
              _disclaimer(),
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
          '03',
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
          'Bog\'lar',
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
          'Tinch va parvarishli makonlar',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _gardenRow({
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
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
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
    ).animate(delay: (120 + index * 80).ms).fadeIn(duration: 320.ms).slideY(
        begin: 0.06, end: 0, curve: Curves.easeOutQuart);
  }

  Widget _disclaimer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.pureWhite.withValues(alpha: 0.08),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.pureWhite.withValues(alpha: 0.45), size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu bog\'lar tibbiy davo emas. Tibbiy maslahat uchun shifokorga murojaat qiling.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.pureWhite.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
