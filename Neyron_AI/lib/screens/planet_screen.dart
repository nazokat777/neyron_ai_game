import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/app_state.dart';
import '../services/i18n.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/editorial.dart';
import '../widgets/hero_characters.dart';
import 'chat_screen.dart';

/// "Sayyora" — bosh sahifa, Professor'ning kabinetiga kirish.
/// Hierarchy: hero composition → greeting → Maryam hero stat → today + magic box
/// (asimmetrik) → stats row.
class PlanetScreen extends StatelessWidget {
  const PlanetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    if (profile == null) {
      return const ColoredBox(color: AppColors.cosmicDeep);
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
      child: NeuralBackdrop(
        intensity: 0.7,
        child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(profile),
              const SizedBox(height: 20),
              _heroSection(context),
              const SizedBox(height: 28),
              _greetingCard(context, state),
              const SizedBox(height: 36),
              _maryamHero(profile),
              const SizedBox(height: 36),
              _todayAndBox(profile),
              const SizedBox(height: 28),
              _statsRow(profile),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────────────
  Widget _topBar(UserProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _pill('🔥', '${profile.streakDays}', L10n.t('planet.day'),
            AppColors.plasmaYellow),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill('🪙', '${profile.coins}', '', AppColors.neuronGreen),
            const SizedBox(width: 12),
            const BrainMark(size: 24),
          ],
        ),
      ],
    );
  }

  Widget _pill(String emoji, String value, String unit, Color roleColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cosmicMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: roleColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: roleColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                color: AppColors.pureWhite,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── HERO ─────────────────────────────────────────────────────
  Widget _heroSection(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Center(
      child: HeroCharacters(size: screenW - 80),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ─── GREETING CARD ───────────────────────────────────────────
  Widget _greetingCard(BuildContext context, AppState state) {
    final profile = state.profile!;
    return _surface(
      borderColor: AppColors.professorWarmth.withValues(alpha: 0.22),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                I18n.professorName,
                style: const TextStyle(
                  color: AppColors.professorWarmth,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neuronGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline,
                        color: AppColors.neuronGreen, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      L10n.t('nav.chat'),
                      style: const TextStyle(
                        color: AppColors.neuronGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            L10n.t('planet.greeting').replaceAll('{name}', profile.name),
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.pureWhite,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1);
  }

  // ─── MARYAM HERO — full-width, type-led, avatar HUGE ─────────
  Widget _maryamHero(UserProfile profile) {
    final level =
        ((profile.totalSessions * 5) + (profile.streakDays * 2)).clamp(1, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            L10n.t('planet.apprentice'),
            style: TextStyle(
              fontSize: 11,
              color: AppColors.pureWhite.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MaryamImage(size: 92, level: level, animated: true),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    I18n.maryamName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pureWhite,
                      letterSpacing: -0.01,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$level',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w600,
                          color: AppColors.professorWarmth,
                          letterSpacing: -0.03,
                          height: 1.0,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        ' / 100',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.pureWhite.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w400,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: level / 100,
            minHeight: 3,
            backgroundColor: AppColors.cosmicMid,
            valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.professorWarmth),
          ),
        ),
      ],
    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1);
  }

  // ─── TODAY + MAGIC BOX — asymmetric 2-column ─────────────────
  Widget _todayAndBox(UserProfile profile) {
    final done = (profile.totalSessions % 3).clamp(0, 3);
    const goal = 3;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Bugungi maqsad — 60%
        Expanded(
          flex: 3,
          child: _surface(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  L10n.t('planet.today'),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.pureWhite.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$done',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pureWhite,
                        letterSpacing: -0.02,
                        height: 1.0,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      ' / $goal',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.pureWhite.withValues(alpha: 0.35),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(goal, (i) {
                    final filled = i < done;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < goal - 1 ? 4 : 0),
                        height: 3,
                        decoration: BoxDecoration(
                          color: filled
                              ? AppColors.neuronGreen
                              : AppColors.cosmicDeep,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Sehrli quti — 40%, plasma-yellow accent
        Expanded(
          flex: 2,
          child: _surface(
            borderColor: AppColors.plasmaYellow.withValues(alpha: 0.3),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📦', style: TextStyle(fontSize: 28)),
                const Spacer(),
                Text(
                  L10n.t('planet.box'),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.plasmaYellow.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  L10n.t('planet.boxNew'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pureWhite,
                    letterSpacing: -0.01,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.1);
  }

  // ─── STATS ────────────────────────────────────────────────────
  Widget _statsRow(UserProfile profile) {
    final totalXp =
        profile.skills.values.fold<double>(0, (a, b) => a + b).toInt();
    final daysWith =
        DateTime.now().difference(profile.joinedDate).inDays + 1;
    return Row(
      children: [
        Expanded(
            child: _statTile(
                '${profile.totalSessions}', L10n.t('planet.session'))),
        Expanded(child: _statTile('$totalXp', L10n.t('planet.xp'))),
        Expanded(child: _statTile('$daysWith', L10n.t('planet.days'))),
      ],
    ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _statTile(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.02,
            height: 1.0,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.pureWhite.withValues(alpha: 0.5),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── Local primitives ────────────────────────────────────────
  Widget _surface({
    required Widget child,
    Color? borderColor,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final container = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cosmicMid,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: child,
    );
    if (onTap == null) return container;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: container,
      ),
    );
  }
}
