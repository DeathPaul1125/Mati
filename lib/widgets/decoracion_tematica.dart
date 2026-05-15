import 'dart:math';
import 'package:flutter/material.dart';

class DecoracionTematica extends StatefulWidget {
  final List<String> simbolos;
  final Color color;
  final int cantidad;

  const DecoracionTematica({
    super.key,
    required this.simbolos,
    required this.color,
    this.cantidad = 10,
  });

  @override
  State<DecoracionTematica> createState() => _DecoracionTematicaState();
}

class _DecoracionTematicaState extends State<DecoracionTematica>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Flotante> _items;

  @override
  void initState() {
    super.initState();
    final rng = Random(widget.simbolos.join().hashCode);
    _items = List.generate(widget.cantidad, (i) {
      return _Flotante(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 22 + rng.nextDouble() * 22,
        rot: rng.nextDouble() * 2 * pi - pi,
        fase: rng.nextDouble() * 2 * pi,
        velocidad: 0.4 + rng.nextDouble() * 0.5,
        simbolo: widget.simbolos[rng.nextInt(widget.simbolos.length)],
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
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
          return Stack(
            fit: StackFit.expand,
            children: _items.map((f) {
              final phase = (_ctrl.value * f.velocidad * 2 * pi) + f.fase;
              return Align(
                alignment: Alignment(
                  (f.x * 2 - 1) + sin(phase) * 0.04,
                  (f.y * 2 - 1) + cos(phase * 0.8) * 0.04,
                ),
                child: Transform.rotate(
                  angle: f.rot + sin(phase) * 0.15,
                  child: Opacity(
                    opacity: 0.22 + 0.12 * (0.5 + 0.5 * sin(phase * 1.3)),
                    child: Text(
                      f.simbolo,
                      style: TextStyle(
                        fontSize: f.size,
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w800,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _Flotante {
  final double x;
  final double y;
  final double size;
  final double rot;
  final double fase;
  final double velocidad;
  final String simbolo;
  _Flotante({
    required this.x,
    required this.y,
    required this.size,
    required this.rot,
    required this.fase,
    required this.velocidad,
    required this.simbolo,
  });
}
