import 'dart:math';
import 'package:flutter/material.dart';

class Mascota extends StatefulWidget {
  final double size;
  final Color color;
  final Color colorBorde;

  const Mascota({
    super.key,
    this.size = 140,
    this.color = const Color(0xFFFFD23C),
    this.colorBorde = const Color(0xFFE6A01E),
  });

  @override
  State<Mascota> createState() => _MascotaState();
}

class _MascotaState extends State<Mascota>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
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
      builder: (_, _) {
        final dy = -6 * sin(_ctrl.value * pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _EstrellaCarita(
              color: widget.color,
              borde: widget.colorBorde,
            ),
          ),
        );
      },
    );
  }
}

class _EstrellaCarita extends CustomPainter {
  final Color color;
  final Color borde;
  _EstrellaCarita({required this.color, required this.borde});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rOut = size.width * 0.48;
    final rIn = rOut * 0.45;

    final path = Path();
    for (var i = 0; i < 10; i++) {
      final ang = -pi / 2 + i * pi / 5;
      final r = i.isEven ? rOut : rIn;
      final x = cx + r * cos(ang);
      final y = cy + r * sin(ang);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawShadow(path, Colors.black26, 6, false);

    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 0.9,
        colors: [Color.lerp(color, Colors.white, 0.3)!, color],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: rOut));
    canvas.drawPath(path, fill);

    canvas.drawPath(
      path,
      Paint()
        ..color = borde
        ..style = PaintingStyle.stroke
        ..strokeWidth = rOut * 0.06
        ..strokeJoin = StrokeJoin.round,
    );

    final eyeR = rOut * 0.075;
    final eyeDx = rOut * 0.22;
    final eyeDy = -rOut * 0.05;
    final eyePaint = Paint()..color = const Color(0xFF2A2A40);
    for (final sign in [-1, 1]) {
      final ex = cx + sign * eyeDx;
      final ey = cy + eyeDy;
      canvas.drawCircle(Offset(ex, ey), eyeR, eyePaint);
      canvas.drawCircle(
        Offset(ex + eyeR * 0.35, ey - eyeR * 0.25),
        eyeR * 0.35,
        Paint()..color = Colors.white,
      );
    }

    final mouthRect = Rect.fromCenter(
      center: Offset(cx, cy + rOut * 0.14),
      width: rOut * 0.65,
      height: rOut * 0.45,
    );
    canvas.drawArc(
      mouthRect,
      0.25,
      pi - 0.5,
      false,
      Paint()
        ..color = const Color(0xFF4A2A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = rOut * 0.06
        ..strokeCap = StrokeCap.round,
    );

    final cheekPaint = Paint()..color = const Color(0x99FF98AC);
    for (final sign in [-1, 1]) {
      canvas.drawCircle(
        Offset(cx + sign * rOut * 0.35, cy + rOut * 0.10),
        rOut * 0.09,
        cheekPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EstrellaCarita oldDelegate) => false;
}

class BurbujaTexto extends StatelessWidget {
  final String texto;
  final Color color;
  const BurbujaTexto({super.key, required this.texto, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF333355),
        ),
      ),
    );
  }
}
