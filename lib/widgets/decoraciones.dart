import 'dart:math';
import 'package:flutter/material.dart';

class NubesYSol extends StatefulWidget {
  final double height;
  const NubesYSol({super.key, this.height = 120});

  @override
  State<NubesYSol> createState() => _NubesYSolState();
}

class _NubesYSolState extends State<NubesYSol>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(
        size: Size(double.infinity, widget.height),
        painter: _NubesYSolPainter(_ctrl.value),
      ),
    );
  }
}

class _NubesYSolPainter extends CustomPainter {
  final double t;
  _NubesYSolPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final solX = size.width * 0.82;
    final solY = size.height * 0.5;
    final solR = size.height * 0.32;

    final rayPaint = Paint()
      ..color = const Color(0xFFFFE066).withValues(alpha: 0.55)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final ang = i * 2 * pi / 10 + t * 2 * pi;
      final inner = solR * 1.15;
      final outer = solR * 1.55;
      canvas.drawLine(
        Offset(solX + cos(ang) * inner, solY + sin(ang) * inner),
        Offset(solX + cos(ang) * outer, solY + sin(ang) * outer),
        rayPaint,
      );
    }
    final solGradient = RadialGradient(
      colors: [const Color(0xFFFFE066), const Color(0xFFFFB347)],
    );
    canvas.drawCircle(
      Offset(solX, solY),
      solR,
      Paint()
        ..shader = solGradient.createShader(
          Rect.fromCircle(center: Offset(solX, solY), radius: solR),
        ),
    );
    final faceR = solR * 0.16;
    final eyePaint = Paint()..color = const Color(0xFF553300);
    canvas.drawCircle(Offset(solX - faceR * 1.4, solY - faceR * 0.6), faceR * 0.55, eyePaint);
    canvas.drawCircle(Offset(solX + faceR * 1.4, solY - faceR * 0.6), faceR * 0.55, eyePaint);
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(solX, solY + faceR * 0.6),
          width: faceR * 3.2,
          height: faceR * 2.2),
      0.3,
      pi - 0.6,
      false,
      Paint()
        ..color = const Color(0xFF553300)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    final shift = (t * size.width * 0.3) % size.width;
    _drawCloud(canvas, Offset(-shift + size.width * 0.15, size.height * 0.45),
        size.height * 0.28);
    _drawCloud(canvas, Offset(-shift + size.width * 0.55, size.height * 0.30),
        size.height * 0.22);
    _drawCloud(canvas, Offset(-shift + size.width * 0.95, size.height * 0.55),
        size.height * 0.30);
    _drawCloud(canvas, Offset(-shift + size.width * 1.35, size.height * 0.40),
        size.height * 0.24);
  }

  void _drawCloud(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final shadow = Paint()..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawCircle(c.translate(0, r * 0.18), r * 1.05, shadow);
    canvas.drawCircle(c.translate(-r * 0.7, r * 0.15), r * 0.75, paint);
    canvas.drawCircle(c.translate(r * 0.7, r * 0.15), r * 0.7, paint);
    canvas.drawCircle(c.translate(-r * 0.25, -r * 0.15), r * 0.95, paint);
    canvas.drawCircle(c.translate(r * 0.35, -r * 0.05), r * 0.85, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: c.translate(0, r * 0.4), width: r * 2.2, height: r * 0.9),
        Radius.circular(r),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _NubesYSolPainter old) => old.t != t;
}

class ColinaInferior extends StatelessWidget {
  final Color color;
  final double height;
  const ColinaInferior({
    super.key,
    this.color = const Color(0xFFB5E7A0),
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _ColinaPainter(color),
    );
  }
}

class _ColinaPainter extends CustomPainter {
  final Color color;
  _ColinaPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25, size.height * 0.0,
        size.width * 0.5, size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 1.0,
        size.width, size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black26, 6, true);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.3)!, color],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _ColinaPainter old) => false;
}
