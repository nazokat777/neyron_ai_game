import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Indexli sarlavha: `01 — TITLE  ─────`
/// Brand signature, har bir bolder screen'da ishlatiladi.
class SectionHeader extends StatelessWidget {
  final String index;
  final String title;
  final Color? accent;

  const SectionHeader({
    super.key,
    required this.index,
    required this.title,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? AppColors.pureWhite;
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
          style: TextStyle(
            color: accentColor,
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
}

/// Mayda accent dot bilan tag: `· LABEL`
class AccentTag extends StatelessWidget {
  final String label;
  final Color color;

  const AccentTag({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

/// O'yin maydonlari uchun mayda nuqta-grid fonni — lab daftarchasi hissi.
/// Cosmic-mid'dan bir oz yorqinroq mayda nuqtalar.
class DotGridBackdrop extends StatelessWidget {
  final Widget child;
  final double spacing;
  final double dotSize;
  final double alpha;

  const DotGridBackdrop({
    super.key,
    required this.child,
    this.spacing = 32,
    this.dotSize = 1.2,
    this.alpha = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(
        spacing: spacing,
        dotSize: dotSize,
        color: AppColors.pureWhite.withValues(alpha: alpha),
      ),
      child: child,
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final double spacing;
  final double dotSize;
  final Color color;

  _DotGridPainter({
    required this.spacing,
    required this.dotSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = spacing; y < size.height; y += spacing) {
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) =>
      old.spacing != spacing || old.dotSize != dotSize || old.color != color;
}
