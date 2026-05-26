import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Personajlar — alohida shaffof PNG fayllar
class AppImages {
  static const String professorMaryam = 'assets/images/professor_maryam.png';
  static const String professor = 'assets/images/professor.png';
  static const String maryam = 'assets/images/maryam.png';
  static const String celebration = 'assets/images/celebration.png';
}

/// Professor + Maryam birga — hero kompozitsiya rasmi
/// Splash, onboarding, chat empty state uchun
class HeroCharacters extends StatelessWidget {
  final double size;
  final bool glow;
  final bool floating;

  const HeroCharacters({
    super.key,
    this.size = 240,
    this.glow = true,
    this.floating = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      AppImages.professorMaryam,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (glow) {
      image = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.professorWarmth.withValues(alpha: 0.18),
              AppColors.cosmicDeep.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: image,
      );
    }

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (floating && !reduceMotion) {
      image = image
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: -4,
            end: 4,
            duration: 3.seconds,
            curve: Curves.easeInOut,
          );
    }

    return image;
  }
}

/// Professor alohida — dumaloq avatar
class ProfessorImage extends StatelessWidget {
  final double size;
  final bool animated;
  final bool showGlow;

  const ProfessorImage({
    super.key,
    this.size = 80,
    this.animated = true,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.professorWarmth.withValues(alpha: 0.25),
              AppColors.cosmicMid,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.04),
          child: Image.asset(
            AppImages.professor,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    if (showGlow) {
      image = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.professorWarmth.withValues(alpha: 0.4),
              blurRadius: size * 0.2,
              spreadRadius: size * 0.02,
            ),
          ],
        ),
        child: image,
      );
    }

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (animated && !reduceMotion) {
      image = image
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.03, 1.03),
            duration: 3.seconds,
            curve: Curves.easeInOut,
          );
    }

    return image;
  }
}

/// Maryam alohida — dumaloq avatar
class MaryamImage extends StatelessWidget {
  final double size;
  final bool animated;
  final int level;

  const MaryamImage({
    super.key,
    this.size = 100,
    this.animated = true,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    final intensity = (level / 100).clamp(0.4, 1.0);

    Widget image = ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.professorWarmth.withValues(alpha: 0.25),
              AppColors.cosmicMid,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.04),
          child: Image.asset(
            AppImages.maryam,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    image = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.professorWarmth.withValues(alpha: 0.5 * intensity),
            blurRadius: size * 0.25 * intensity,
            spreadRadius: size * 0.03 * intensity,
          ),
        ],
      ),
      child: image,
    );

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (animated && !reduceMotion) {
      image = image
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.04, 1.04),
            duration: 2.5.seconds,
            curve: Curves.easeInOut,
          );
    }

    return image;
  }
}

/// Maryam quvonayotgan — o'yin g'alabasi yoki muvaffaqiyat lahzasi uchun
class CelebrationImage extends StatelessWidget {
  final double size;

  const CelebrationImage({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.plasmaYellow.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: AppColors.professorWarmth.withValues(alpha: 0.3),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Image.asset(
        AppImages.celebration,
        fit: BoxFit.contain,
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .shake(hz: 2, curve: Curves.easeInOut, duration: 800.ms);
  }
}
