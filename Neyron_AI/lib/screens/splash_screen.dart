import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';
import '../widgets/hero_characters.dart';
import 'main_navigation.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _awaitingLanguage = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final state = context.read<AppState>();
    await state.initialize();
    if (state.hasProfile) {
      await state.incrementStreak();
    }
    // Til hali tanlanmagan bo'lsa — boshida til tanlashni so'raymiz
    if (!state.languageChosen) {
      if (!mounted) return;
      setState(() => _awaitingLanguage = true);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    _goNext(state);
  }

  Future<void> _onPickLang(String code) async {
    final state = context.read<AppState>();
    await state.setLanguage(code);
    if (!mounted) return;
    _goNext(state);
  }

  void _goNext(AppState state) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            state.hasProfile ? const MainNavigation() : const OnboardingScreen(),
      ),
    );
  }

  Widget _loadingBar() {
    return Center(
      child: SizedBox(
        width: 32,
        height: 2,
        child: LinearProgressIndicator(
          backgroundColor: AppColors.pureWhite.withValues(alpha: 0.08),
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.pureWhite.withValues(alpha: 0.35),
          ),
        ),
      ),
    ).animate(delay: 1200.ms).fadeIn();
  }

  Widget _languagePicker() {
    Widget chip(String code, String label) {
      return Expanded(
        child: GestureDetector(
          onTap: () => _onPickLang(code),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cosmicMid,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.pureWhite.withValues(alpha: 0.12),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tilni tanlang · Выберите язык · Choose language',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.pureWhite.withValues(alpha: 0.5),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            chip('uz', 'O\'zbekcha'),
            chip('ru', 'Русский'),
            chip('en', 'English'),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: NeuralBackdrop(
          intensity: 0.9,
          child: SafeArea(
          child: Stack(
            children: [
              // Tepa-chap: editorial index
              Positioned(
                top: 24,
                left: 28,
                child: Text(
                  'NEYRON · 01',
                  style: TextStyle(
                    color: AppColors.pureWhite.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              ),

              // Markaz: hero
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeroCharacters(size: 220)
                        .animate()
                        .fadeIn(duration: 900.ms)
                        .scale(
                          begin: const Offset(0.88, 0.88),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutQuart,
                          duration: 900.ms,
                        ),
                    const SizedBox(height: 40),
                    const Text(
                      'Neyron AI',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.025,
                        color: AppColors.pureWhite,
                        height: 1.0,
                      ),
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    const SizedBox(height: 24),
                    // Hairline + tagline
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 0.5,
                          color: AppColors.professorWarmth.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'MUVAFFAQIYAT SARI',
                          style: TextStyle(
                            color: AppColors.professorWarmth,
                            fontSize: 12,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 32,
                          height: 0.5,
                          color: AppColors.professorWarmth.withValues(alpha: 0.6),
                        ),
                      ],
                    ).animate(delay: 900.ms).fadeIn(duration: 600.ms),
                    const SizedBox(height: 26),
                    // Miyani rivojlantiruvchi o'yin — neyron emblema + tagline
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BrainMark(size: 22, opacity: 0.8),
                        const SizedBox(width: 10),
                        Text(
                          L10n.t('app.tagline'),
                          style: TextStyle(
                            color: AppColors.pureWhite.withValues(alpha: 0.6),
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ).animate(delay: 1100.ms).fadeIn(duration: 600.ms),
                  ],
                ),
              ),

              // Pastki: til tanlash (birinchi marta) yoki yuklanish indikatori
              Positioned(
                bottom: 44,
                left: 24,
                right: 24,
                child: _awaitingLanguage ? _languagePicker() : _loadingBar(),
              ),

              // Pastki burchak: editorial tag
              Positioned(
                bottom: 24,
                right: 28,
                child: Text(
                  'PROFESSOR · MARYAM',
                  style: TextStyle(
                    color: AppColors.pureWhite.withValues(alpha: 0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ).animate(delay: 1400.ms).fadeIn(duration: 600.ms),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
