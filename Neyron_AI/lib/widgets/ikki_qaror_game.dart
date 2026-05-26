import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class IkkiQarorGame extends StatefulWidget {
  const IkkiQarorGame({super.key});

  @override
  State<IkkiQarorGame> createState() => _IkkiQarorGameState();
}

class _IkkiQarorGameState extends State<IkkiQarorGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _particleController;
  final List<Offset> _particles = [];
  final List<double> _speeds = [];
  final Random _random = Random(42);

  int _currentQuestionIndex = 0;
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Kosmik stansiyada kislorod tizimi buzildi. Qaysi qarorni qabul qilasiz?',
      'optionA': 'Zaxira generatorni yoqish (Tavakkal)',
      'optionB': 'Ekipajni evakuatsiya qilish (Xavfsiz)',
    },
    {
      'question': "Noma'lum sayyoradan biolyuminessent signal kelmoqda. Nima qilasiz?",
      'optionA': 'Signal manbasini qidirish',
      'optionB': 'Xavfsiz masofaga uzoqlashish',
    }
  ];

  @override
  void initState() {
    super.initState();

    // Controller drives painter; value ranges 0..1 and repeats.
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Fewer particles but with layered sizes/speeds for depth
    for (int i = 0; i < 30; i++) {
      _particles.add(Offset(_random.nextDouble(), _random.nextDouble()));
      _speeds.add(0.2 + _random.nextDouble() * 1.2);
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _currentQuestionIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Deep gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF001219), Color(0xFF001E22), Color(0xFF001219)],
              ),
            ),
          ),

          // Particle layer inside RepaintBoundary for performance
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _OptimizedCosmicPainter(
                    points: _particles,
                    speeds: _speeds,
                    t: _particleController.value,
                  ),
                );
              },
            ),
          ),

          // UI layer
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF59FBD8)),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Text(
                        'MISSION STATUS: ACTIVE',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          color: const Color(0xFF59FBD8).withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Questions card with subtle blur + neon rim
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF062628).withOpacity(0.45),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF59FBD8).withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SAVOL: ${_currentQuestionIndex + 1}/${_questions.length}',
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                color: Color(0xFF59FBD8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              currentQuestion['question'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Buttons with neon press + scale effect
                  NeonButton(
                    text: currentQuestion['optionA'],
                    onPressed: _nextQuestion,
                    color: const Color(0xFF59FBD8),
                  ),
                  const SizedBox(height: 16),
                  NeonButton(
                    text: currentQuestion['optionB'],
                    onPressed: _nextQuestion,
                    color: const Color(0xFF7BFFB2),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lightweight neon button with press glow and scale animation
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const NeonButton({required this.text, required this.onPressed, required this.color, super.key});

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180), lowerBound: 0.0, upperBound: 1.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.animateTo(1.0, curve: Curves.easeOut);
  void _onTapUp(_) {
    _ctrl.animateBack(0.0, curve: Curves.easeOut);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _ctrl.animateBack(0.0, curve: Curves.easeOut),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final glow = 6.0 + 18.0 * _ctrl.value;
          final scale = 1.0 - 0.03 * _ctrl.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF021414).withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.color.withOpacity(0.45), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.18),
                    blurRadius: glow,
                    spreadRadius: _ctrl.value * 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: widget.color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: widget.color.withOpacity(0.6), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Optimized painter: only repaints when 't' changes and uses MaskFilter blur for glow.
class _OptimizedCosmicPainter extends CustomPainter {
  final List<Offset> points;
  final List<double> speeds;
  final double t;

  _OptimizedCosmicPainter({required this.points, required this.speeds, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint corePaint = Paint()
      ..color = const Color(0xFF9DFBE6)
      ..style = PaintingStyle.fill;

    final Paint glowPaint = Paint()
      ..color = const Color(0xFF59FBD8).withOpacity(0.12)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final Paint softPaint = Paint()
      ..color = const Color(0xFF59FBD8).withOpacity(0.06)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final speed = speeds[i];
      final dx = (p.dx * size.width + (t * 220 * (p.dx > 0.5 ? 1 : -1) * speed)) % size.width;
      final dy = (p.dy * size.height + (t * 260 * speed)) % size.height;
      final pos = Offset(dx, dy);

      // Layered glow: big soft, medium glow, small core
      canvas.drawCircle(pos, 18.0 * (0.6 + 0.6 * speed), softPaint);
      canvas.drawCircle(pos, 8.0 * (0.8 + 0.6 * speed), glowPaint);
      canvas.drawCircle(pos, 2.2, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OptimizedCosmicPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.points.length != points.length;
  }
}
