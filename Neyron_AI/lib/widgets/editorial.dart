import 'dart:math';
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

/// Miya emblemasi — jonli neyron-tarmoq (CustomPainter, impuls to'lqini).
/// "Neyron AI" — miya rivojlantiruvchi o'yin mavzusini bildiradi.
class BrainMark extends StatefulWidget {
  final double size;
  final double opacity;
  const BrainMark({super.key, this.size = 26, this.opacity = 0.7});

  @override
  State<BrainMark> createState() => _BrainMarkState();
}

class _BrainMarkState extends State<BrainMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _NeuralEmblemPainter(t: _c.value, opacity: widget.opacity),
        ),
      ),
    );
  }
}

class _NeuralEmblemPainter extends CustomPainter {
  final double t; // 0..1 puls
  final double opacity;
  _NeuralEmblemPainter({required this.t, required this.opacity});

  // Miyaga o'xshash ikki-pallali neyron klasteri (normallashtirilgan)
  static const List<Offset> _nodes = [
    Offset(0.30, 0.30),
    Offset(0.64, 0.24),
    Offset(0.20, 0.58),
    Offset(0.50, 0.50),
    Offset(0.80, 0.56),
    Offset(0.44, 0.80),
  ];
  static const List<List<int>> _edges = [
    [0, 1], [0, 3], [1, 3], [1, 4], [2, 3], [3, 4], [3, 5], [2, 5], [4, 5],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(int i) =>
        Offset(_nodes[i].dx * size.width, _nodes[i].dy * size.height);
    final base = AppColors.neuronGreen;

    final line = Paint()
      ..color = base.withValues(alpha: opacity * 0.45)
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;
    for (final e in _edges) {
      canvas.drawLine(p(e[0]), p(e[1]), line);
    }

    final r = size.width * 0.075;
    for (var i = 0; i < _nodes.length; i++) {
      // Har nuqta navbatma-navbat yorishadi — "impuls" to'lqini
      final phase = (t + i / _nodes.length) % 1.0;
      final glow = 0.55 + 0.45 * (1 - (phase - 0.5).abs() * 2);
      final dot = Paint()
        ..color = base.withValues(alpha: (opacity * glow).clamp(0.0, 1.0));
      canvas.drawCircle(p(i), r * (0.85 + 0.35 * glow), dot);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralEmblemPainter old) =>
      old.t != t || old.opacity != opacity;
}

/// Jonli neyron tarmoq foni — butun ekran bo'ylab harakatlanuvchi neyronlar,
/// bog'lanishlar va impuls uchqunlari. "Neyron AI / miya" mavzusini kuchli
/// bildiradi. Orqa fonga qo'yiladi (child ustida ko'rinadi).
class NeuralBackdrop extends StatefulWidget {
  final Widget? child;
  final double intensity; // 0..1 — umumiy ko'rinish kuchi
  const NeuralBackdrop({super.key, this.child, this.intensity = 1.0});

  @override
  State<NeuralBackdrop> createState() => _NeuralBackdropState();
}

class _NeuralBackdropState extends State<NeuralBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 9))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              painter: _NeuralNetPainter(t: _c.value, intensity: widget.intensity),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _NeuralNetPainter extends CustomPainter {
  final double t; // 0..1 loop
  final double intensity;
  _NeuralNetPainter({required this.t, required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 5;
    final rows = (size.height / size.width * cols * 1.3).clamp(6, 14).round();
    final n = cols * rows;
    final cw = size.width / cols;
    final ch = size.height / rows;
    const twoPi = 2 * pi;

    final pos = List<Offset>.generate(n, (i) {
      final c = i % cols, r = i ~/ cols;
      final bx = (c + 0.5) * cw;
      final by = (r + 0.5) * ch;
      final dx = sin(i * 1.7 + t * twoPi) * cw * 0.18;
      final dy = cos(i * 2.3 + t * twoPi) * ch * 0.18;
      return Offset(bx + dx, by + dy);
    });

    Color nodeColor(int i) {
      if (i % 9 == 0) return AppColors.plasmaYellow;
      if (i % 7 == 0) return AppColors.gameBlue;
      return AppColors.neuronGreen;
    }

    final edgePaint = Paint()
      ..strokeWidth = 1
      ..color = AppColors.neuronGreen.withValues(alpha: 0.10 * intensity);

    var seed = 0;
    void edge(int a, int b, int s) {
      canvas.drawLine(pos[a], pos[b], edgePaint);
      // bog'lanish bo'ylab harakatlanuvchi impuls uchquni
      final frac = (t * 2 + s * 0.137) % 1.0;
      final p = Offset.lerp(pos[a], pos[b], frac)!;
      canvas.drawCircle(
        p,
        1.8,
        Paint()..color = nodeColor(s).withValues(alpha: 0.55 * intensity),
      );
    }

    for (var i = 0; i < n; i++) {
      final c = i % cols;
      if (c < cols - 1) edge(i, i + 1, seed++);
      if (i + cols < n) edge(i, i + cols, seed++);
    }

    for (var i = 0; i < n; i++) {
      final glow = 0.5 +
          0.5 *
              sin(((pos[i].dx + pos[i].dy) / (size.width + size.height)) *
                      twoPi *
                      2 -
                  t * twoPi * 2);
      final dot = Paint()
        ..color = nodeColor(i).withValues(alpha: (0.16 + 0.5 * glow) * intensity);
      canvas.drawCircle(pos[i], 2.0 + 2.6 * glow, dot);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralNetPainter old) =>
      old.t != t || old.intensity != intensity;
}
