import 'dart:math';
import 'package:flutter/material.dart';

class FondoDecorativo extends StatefulWidget {
  final Widget child;
  final List<Color> colores;
  final int cantidadEstrellas;

  const FondoDecorativo({
    super.key,
    required this.child,
    this.colores = const [Color(0xFFFFE7B5), Color(0xFFFFC5D6)],
    this.cantidadEstrellas = 14,
  });

  @override
  State<FondoDecorativo> createState() => _FondoDecorativoState();
}

class _FondoDecorativoState extends State<FondoDecorativo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particula> _particulas;

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    _particulas = List.generate(
      widget.cantidadEstrellas,
      (_) => _Particula(
        dx: rng.nextDouble(),
        dy: rng.nextDouble(),
        size: 8 + rng.nextDouble() * 22,
        fase: rng.nextDouble() * 2 * pi,
        velocidad: 0.4 + rng.nextDouble() * 0.6,
      ),
    );
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.colores,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => CustomPaint(
            painter: _ParticulasPainter(_particulas, _ctrl.value),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particula {
  final double dx;
  final double dy;
  final double size;
  final double fase;
  final double velocidad;
  _Particula({
    required this.dx,
    required this.dy,
    required this.size,
    required this.fase,
    required this.velocidad,
  });
}

class _ParticulasPainter extends CustomPainter {
  final List<_Particula> particulas;
  final double t;
  _ParticulasPainter(this.particulas, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particulas) {
      final phase = (t * p.velocidad * 2 * pi) + p.fase;
      final dy = sin(phase) * 14;
      final opacity = 0.25 + 0.25 * (0.5 + 0.5 * sin(phase * 1.5));
      final cx = p.dx * size.width;
      final cy = p.dy * size.height + dy;
      _drawStar(canvas, Offset(cx, cy), p.size, opacity);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, double opacity) {
    final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
    final path = Path();
    final rOut = size / 2;
    final rIn = rOut * 0.45;
    for (var i = 0; i < 10; i++) {
      final ang = -pi / 2 + i * pi / 5;
      final r = i.isEven ? rOut : rIn;
      final x = center.dx + r * cos(ang);
      final y = center.dy + r * sin(ang);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ParticulasPainter old) => old.t != t;
}
