import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/app_state.dart';
import '../services/i18n.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_characters.dart';
import 'onboarding_screen.dart';

/// Pasport — Professor'ning kabinetidagi yozuv kartochka.
/// Editorial: hero name, section indices, hairline sections.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    if (profile == null) {
      return const ColoredBox(color: AppColors.cosmicDeep);
    }
    final level = ((profile.totalSessions * 5) + (profile.streakDays * 2))
        .clamp(1, 100);

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(profile),
              const SizedBox(height: 40),
              _section('01', 'Shogird'),
              const SizedBox(height: 20),
              _maryamSection(profile, level),
              const SizedBox(height: 40),
              _section('02', 'Statistika'),
              const SizedBox(height: 20),
              _statsGrid(profile),
              const SizedBox(height: 40),
              _section('03', 'Ko\'nikmalar'),
              const SizedBox(height: 20),
              _skillsSection(profile),
              const SizedBox(height: 40),
              _section('04', 'Sozlamalar'),
              const SizedBox(height: 20),
              _settingsSection(context, state),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER — name as hero ────────────────────────────────────
  Widget _header(UserProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PASPORT',
              style: TextStyle(
                color: AppColors.pureWhite.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 0.5,
                color: AppColors.pureWhite.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.03,
            height: 1.0,
          ),
        ).animate().fadeIn().slideX(begin: -0.02, end: 0),
        const SizedBox(height: 10),
        Text(
          '${profile.age} yosh · ${profile.ageGroup.displayName}',
          style: TextStyle(
            color: AppColors.pureWhite.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ─── Section header ──────────────────────────────────────────
  Widget _section(String index, String title) {
    return Row(
      children: [
        Text(
          index,
          style: TextStyle(
            color: AppColors.pureWhite.withValues(alpha: 0.35),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.pureWhite,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 0.5,
            color: AppColors.pureWhite.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  // ─── 01 Maryam — hero treatment ──────────────────────────────
  Widget _maryamSection(UserProfile profile, int level) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MaryamImage(size: 110, level: level, animated: true),
        const SizedBox(width: 20),
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
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w600,
                      color: AppColors.professorWarmth,
                      letterSpacing: -0.04,
                      height: 1.0,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    ' / 100',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.pureWhite.withValues(alpha: 0.35),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.05, end: 0);
  }

  // ─── 02 Stats grid ───────────────────────────────────────────
  Widget _statsGrid(UserProfile profile) {
    return Row(
      children: [
        Expanded(child: _statBlock('${profile.streakDays}', 'kun streak')),
        Container(
          width: 0.5,
          height: 56,
          color: AppColors.pureWhite.withValues(alpha: 0.1),
        ),
        Expanded(child: _statBlock('${profile.totalSessions}', 'sessiya')),
        Container(
          width: 0.5,
          height: 56,
          color: AppColors.pureWhite.withValues(alpha: 0.1),
        ),
        Expanded(child: _statBlock('${profile.coins}', 'tanga')),
      ],
    ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _statBlock(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            letterSpacing: -0.02,
            height: 1.0,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.pureWhite.withValues(alpha: 0.5),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── 03 Skills — typographic bar list ────────────────────────
  Widget _skillsSection(UserProfile profile) {
    final entries = <(String, double)>[
      ('Xotira', profile.skills['memory'] ?? 0),
      ('E\'tibor', profile.skills['attention'] ?? 0),
      ('Mantiq', profile.skills['logic'] ?? 0),
      ('Tezlik', profile.skills['speed'] ?? 0),
      ('Egiluvchanlik', profile.skills['flexibility'] ?? 0),
    ];
    return Column(
      children: entries.map((e) => _skillRow(e.$1, e.$2)).toList(),
    ).animate(delay: 350.ms).fadeIn();
  }

  Widget _skillRow(String name, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                '${value.toInt()}',
                style: const TextStyle(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0, 1),
              backgroundColor: AppColors.cosmicMid,
              color: AppColors.neuronGreen,
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 04 Settings ─────────────────────────────────────────────
  Widget _settingsSection(BuildContext context, AppState state) {
    return Column(
      children: [
        _settingsTile(
          context,
          icon: Icons.vpn_key_outlined,
          title: 'AI API kaliti',
          subtitle: state.hasApiKey ? 'O\'rnatilgan' : 'O\'rnatilmagan',
          onTap: () => _showApiKeyDialog(context, state),
        ),
        _settingsTile(
          context,
          icon: Icons.refresh_rounded,
          title: 'Profilni qayta yaratish',
          subtitle: 'Hammasini o\'chiradi',
          onTap: () => _confirmReset(context, state),
          isDanger: true,
        ),
      ],
    ).animate(delay: 450.ms).fadeIn();
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final accent = isDanger ? AppColors.accentRed : AppColors.pureWhite;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.pureWhite.withValues(alpha: 0.08),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.pureWhite.withValues(alpha: 0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.pureWhite.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DIALOGS ─────────────────────────────────────────────────
  void _showApiKeyDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.apiKey ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cosmicMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Anthropic API kaliti',
          style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Professor bilan AI suhbat uchun kerak.\nKalitni shu yerdan oling:',
              style: TextStyle(
                  fontSize: 13, color: AppColors.pureWhite, height: 1.5),
            ),
            const SizedBox(height: 4),
            const Text(
              'console.anthropic.com/settings/keys',
              style:
                  TextStyle(fontSize: 13, color: AppColors.neuronGreen),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cosmicDeep,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                    color: AppColors.pureWhite, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: 'sk-ant-...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  hintStyle: TextStyle(
                      color: AppColors.pureWhite.withValues(alpha: 0.3)),
                ),
                obscureText: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor',
                style: TextStyle(
                    color: AppColors.pureWhite.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              await state.setApiKey(controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cosmicMid,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Hammasini o\'chirish?',
          style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Profilingiz, suhbatlar va statistika o\'chadi.\nBu qaytarib bo\'lmaydi.',
          style: TextStyle(
              color: AppColors.pureWhite, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor',
                style: TextStyle(
                    color: AppColors.pureWhite.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: AppColors.pureWhite,
            ),
            onPressed: () async {
              await state.reset();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}
