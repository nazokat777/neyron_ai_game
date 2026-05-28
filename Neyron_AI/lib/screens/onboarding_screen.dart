import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/app_state.dart';
import '../services/i18n.dart';
import '../services/l10n.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_characters.dart';
import 'main_navigation.dart';

/// Onboarding — 4 bosqich editorial uslubda
/// 01 Tanishuv · 02 Ism · 03 Yosh · 04 Boshlanish
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  int _age = 25;
  int _step = 0;

  List<String> get _stepTitles => [
        L10n.t('onb.step.intro'),
        L10n.t('onb.step.name'),
        L10n.t('onb.step.age'),
        L10n.t('onb.step.ready'),
      ];
  static const int _totalSteps = 4;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _next() => setState(() => _step++);
  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  void _setLang(String code) {
    context.read<AppState>().setLanguage(code);
    setState(() {});
  }

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final profile = UserProfile(
      name: name,
      age: _age,
      joinedDate: DateTime.now(),
    );

    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    await state.setProfile(profile);
    await state.incrementStreak();

    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.cosmicGradient),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                  child: AnimatedSwitcher(
                    duration: 360.ms,
                    switchInCurve: Curves.easeOutQuart,
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStep(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── TOP BAR — editorial index + back ────────────────────────
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: _step > 0
                ? GestureDetector(
                    onTap: _back,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.pureWhite.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  )
                : null,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(_step + 1).toString().padLeft(2, '0')} / 0$_totalSteps',
                  style: TextStyle(
                    color: AppColors.pureWhite.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                    width: 18,
                    height: 0.5,
                    color: AppColors.pureWhite.withValues(alpha: 0.2)),
                const SizedBox(width: 12),
                Text(
                  _stepTitles[_step].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _greetingStep();
      case 1:
        return _nameStep();
      case 2:
        return _ageStep();
      case 3:
        return _finishStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── 01 GREETING ─────────────────────────────────────────────
  Widget _greetingStep() {
    final greeting = L10n.t('onb.greeting')
        .replaceAll('{prof}', I18n.professorName)
        .replaceAll('{maryam}', I18n.maryamName);
    return Column(
      children: [
        _langSelector(),
        const SizedBox(height: 8),
        const HeroCharacters(size: 220)
            .animate()
            .fadeIn(duration: 700.ms)
            .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutQuart),
        const Spacer(),
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            height: 1.1,
            letterSpacing: -0.025,
          ),
          textAlign: TextAlign.left,
        )
            .animate(delay: 500.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuart),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            L10n.t('onb.question'),
            style: TextStyle(
              fontSize: 15,
              color: AppColors.pureWhite.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ).animate(delay: 900.ms).fadeIn(duration: 500.ms),
        ),
        const SizedBox(height: 36),
        _primaryButton(L10n.t('onb.start'), _next).animate(delay: 1100.ms).fadeIn(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _langSelector() {
    Widget chip(String code, String label) {
      final selected = context.watch<AppState>().languageCode == code;
      return GestureDetector(
        onTap: () => _setLang(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.neuronGreen.withValues(alpha: 0.18)
                : AppColors.cosmicMid,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.neuronGreen
                  : AppColors.pureWhite.withValues(alpha: 0.1),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.neuronGreen : AppColors.pureWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chip('uz', 'UZ'),
        chip('ru', 'RU'),
        chip('en', 'EN'),
      ],
    );
  }

  // ─── 02 NAME ─────────────────────────────────────────────────
  Widget _nameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const ProfessorImage(size: 88),
        const SizedBox(height: 36),
        Text(
          L10n.t('onb.nameQ'),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            height: 1.0,
            letterSpacing: -0.03,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _nameController,
          autofocus: true,
          style: const TextStyle(
            fontSize: 28,
            color: AppColors.pureWhite,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.01,
          ),
          decoration: InputDecoration(
            hintText: L10n.t('onb.nameHint'),
            hintStyle: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.25),
              fontWeight: FontWeight.w400,
              fontSize: 28,
            ),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.pureWhite.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.neuronGreen,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onSubmitted: (_) => _next(),
          onChanged: (_) => setState(() {}),
        ),
        const Spacer(),
        _primaryButton(
          L10n.t('onb.continue'),
          _nameController.text.trim().isEmpty ? null : _next,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── 03 AGE ──────────────────────────────────────────────────
  Widget _ageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          L10n.t('onb.ageQ'),
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite.withValues(alpha: 0.55),
            height: 1.05,
            letterSpacing: -0.025,
          ),
        ),
        Text(
          '${_nameController.text}?',
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            height: 1.05,
            letterSpacing: -0.025,
          ),
        ),
        const Spacer(),
        Center(
          child: Text(
            '$_age',
            key: ValueKey('age-$_age'),
            style: const TextStyle(
              fontSize: 144,
              fontWeight: FontWeight.w600,
              color: AppColors.professorWarmth,
              letterSpacing: -0.04,
              height: 1.0,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            L10n.t(AgeGroup.fromAge(_age).l10nKey).toUpperCase(),
            style: TextStyle(
              color: AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 11,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
            activeTrackColor: AppColors.neuronGreen,
            inactiveTrackColor:
                AppColors.pureWhite.withValues(alpha: 0.1),
            thumbColor: AppColors.neuronGreen,
            overlayColor: AppColors.neuronGreen.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: _age.toDouble(),
            min: 3,
            max: 70,
            divisions: 67,
            onChanged: (v) => setState(() => _age = v.round()),
          ),
        ),
        const SizedBox(height: 18),
        _primaryButton(L10n.t('onb.continue'), _next),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── 04 FINISH ───────────────────────────────────────────────
  Widget _finishStep() {
    final ready = L10n.t('onb.ready').replaceAll('{name}', _nameController.text);
    return Column(
      children: [
        const SizedBox(height: 8),
        const HeroCharacters(size: 220)
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOutQuart),
        const Spacer(),
        Text(
          ready,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
            height: 1.05,
            letterSpacing: -0.03,
          ),
          textAlign: TextAlign.left,
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.05, end: 0),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 0.5,
                color: AppColors.professorWarmth.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 10),
              Text(
                L10n.t('onb.cabinetOpen'),
                style: TextStyle(
                  color: AppColors.professorWarmth.withValues(alpha: 0.85),
                  fontSize: 11,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ).animate(delay: 700.ms).fadeIn(),
        ),
        const SizedBox(height: 36),
        _primaryButton(L10n.t('onb.enter'), _finish).animate(delay: 950.ms).fadeIn(),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── Primary CTA ─────────────────────────────────────────────
  Widget _primaryButton(String label, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(label),
      ),
    );
  }
}
