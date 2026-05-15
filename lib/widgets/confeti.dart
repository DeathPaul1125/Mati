import 'dart:math';
import 'package:flutter/material.dart';

class ConfetiOverlay extends StatefulWidget {
  final Duration duracion;
  final int cantidad;

  const ConfetiOverlay({
    super.key,
    this.duracion = const Duration(milliseconds: 1400),
    this.cantidad = 80,
  });

  @override
  State<ConfetiOverlay> createState() => _ConfetiOverlayState();
}

class _ConfetiOverlayState extends State<ConfetiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Pedazo> _piezas;

  static const _colores = [
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFE984D2),
    Color(0xFFFF9F45),
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _piezas = List.generate(widget.cantidad, (_) {
      return _Pedazo(
        startX: rng.nextDouble(),
        startY: -0.15 - rng.nextDouble() * 0.2,
        vx: (rng.nextDouble() - 0.5) * 0.3,
        vy: 0.8 + rng.nextDouble() * 0.5,
        spin: (rng.nextDouble() - 0.5) * 12,
        size: 8.0 + rng.nextDouble() * 10,
        color: _colores[rng.nextInt(_colores.length)],
        forma: _Forma.values[rng.nextInt(_Forma.values.length)],
        fase: rng.nextDouble() * 2 * pi,
      );
    });
    _ctrl = AnimationController(vsync: this, duration: widget.duracion)
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfetiPainter(_piezas, _ctrl.value),
          );
        },
      ),
    );
  }
}

enum _Forma { rect, circ, tira }

class _Pedazo {
  final double startX;
  final double startY;
  final double vx;
  final double vy;
  final double spin;
  final double size;
  final Color color;
  final _Forma forma;
  final double fase;
  _Pedazo({
    required this.startX,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.spin,
    required this.size,
    required this.color,
    required this.forma,
    required this.fase,
  });
}

class _ConfetiPainter extends CustomPainter {
  final List<_Pedazo> piezas;
  final double t;
  _ConfetiPainter(this.piezas, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in piezas) {
      final x = (p.startX + p.vx * t) * size.width +
          sin(p.fase + t * 6) * 12;
      final y = (p.startY + p.vy * t * 1.4) * size.height;
      if (y < -p.size || y > size.height + p.size) continue;

      final fade = t < 0.85 ? 1.0 : (1.0 - (t - 0.85) / 0.15).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: fade);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * t);
      switch (p.forma) {
        case _Forma.rect:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 0.6),
              const Radius.circular(2),
            ),
            paint,
          );
        case _Forma.circ:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
        case _Forma.tira:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size * 0.35, height: p.size * 1.2),
              const Radius.circular(2),
            ),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfetiPainter old) => old.t != t;
}
