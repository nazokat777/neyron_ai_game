import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_characters.dart';
import 'main_navigation.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            state.hasProfile ? const MainNavigation() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
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
                  ],
                ),
              ),

              // Pastki indicator
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 2,
                    child: LinearProgressIndicator(
                      backgroundColor:
                          AppColors.pureWhite.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.pureWhite.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ).animate(delay: 1200.ms).fadeIn(),
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
    );
  }
}
