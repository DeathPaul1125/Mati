import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

class TrazoLetrasScreen extends StatefulWidget {
  const TrazoLetrasScreen({super.key});

  @override
  State<TrazoLetrasScreen> createState() => _TrazoLetrasScreenState();
}

class _TrazoLetra {
  final String letra;
  final List<List<Offset>> trazos;
  const _TrazoLetra(this.letra, this.trazos);
}

class _TrazoLetrasScreenState extends State<TrazoLetrasScreen> {
  static final List<_TrazoLetra> _letras = [
    _TrazoLetra('I', [
      _puntos(const Offset(0.5, 0.15), const Offset(0.5, 0.85), 12),
    ]),
    _TrazoLetra('L', [
      _puntos(const Offset(0.30, 0.15), const Offset(0.30, 0.85), 12) +
          _puntos(const Offset(0.30, 0.85), const Offset(0.80, 0.85), 6)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('T', [
      _puntos(const Offset(0.15, 0.18), const Offset(0.85, 0.18), 10),
      _puntos(const Offset(0.5, 0.18), const Offset(0.5, 0.85), 10),
    ]),
    _TrazoLetra('O', [
      _arco(const Offset(0.5, 0.5), 0.32, 20),
    ]),
    _TrazoLetra('C', [
      _arcoParcial(const Offset(0.55, 0.5), 0.32, 16, 5.50, 0.785),
    ]),
    _TrazoLetra('M', [
      _puntos(const Offset(0.18, 0.85), const Offset(0.18, 0.18), 8) +
          _puntos(const Offset(0.18, 0.18), const Offset(0.50, 0.55), 5)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.50, 0.55), const Offset(0.82, 0.18), 5)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.82, 0.18), const Offset(0.82, 0.85), 8)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('A', [
      _puntos(const Offset(0.18, 0.85), const Offset(0.50, 0.15), 10) +
          _puntos(const Offset(0.50, 0.15), const Offset(0.82, 0.85), 9)
              .skip(1)
              .toList(),
      _puntos(const Offset(0.30, 0.62), const Offset(0.70, 0.62), 5),
    ]),
    _TrazoLetra('E', [
      _puntos(const Offset(0.65, 0.18), const Offset(0.25, 0.18), 5) +
          _puntos(const Offset(0.25, 0.18), const Offset(0.25, 0.85), 8)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.25, 0.85), const Offset(0.70, 0.85), 5)
              .skip(1)
              .toList(),
      _puntos(const Offset(0.25, 0.51), const Offset(0.62, 0.51), 5),
    ]),
    _TrazoLetra('B', [
      _puntos(const Offset(0.28, 0.15), const Offset(0.28, 0.85), 10),
      _arcoParcial(const Offset(0.30, 0.32), 0.20, 8, -pi / 2, pi / 2) +
          _arcoParcial(const Offset(0.30, 0.68), 0.22, 8, -pi / 2, pi / 2)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('D', [
      _puntos(const Offset(0.28, 0.15), const Offset(0.28, 0.85), 10),
      _arcoParcial(const Offset(0.30, 0.5), 0.36, 14, -pi / 2, pi / 2),
    ]),
    _TrazoLetra('F', [
      _puntos(const Offset(0.65, 0.18), const Offset(0.25, 0.18), 5) +
          _puntos(const Offset(0.25, 0.18), const Offset(0.25, 0.85), 8)
              .skip(1)
              .toList(),
      _puntos(const Offset(0.25, 0.50), const Offset(0.58, 0.50), 5),
    ]),
    _TrazoLetra('G', [
      _arcoParcial(const Offset(0.5, 0.5), 0.32, 14, 5.50, 0.785) +
          _puntos(const Offset(0.726, 0.726), const Offset(0.726, 0.50), 4)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.726, 0.50), const Offset(0.55, 0.50), 3)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('H', [
      _puntos(const Offset(0.25, 0.15), const Offset(0.25, 0.85), 10),
      _puntos(const Offset(0.75, 0.15), const Offset(0.75, 0.85), 10),
      _puntos(const Offset(0.25, 0.50), const Offset(0.75, 0.50), 6),
    ]),
    _TrazoLetra('J', [
      _puntos(const Offset(0.65, 0.15), const Offset(0.65, 0.70), 8) +
          _arcoParcial(const Offset(0.45, 0.70), 0.20, 6, 0, pi)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('K', [
      _puntos(const Offset(0.25, 0.15), const Offset(0.25, 0.85), 10),
      _puntos(const Offset(0.75, 0.18), const Offset(0.25, 0.50), 7),
      _puntos(const Offset(0.25, 0.50), const Offset(0.75, 0.85), 7),
    ]),
    _TrazoLetra('N', [
      _puntos(const Offset(0.25, 0.85), const Offset(0.25, 0.15), 9) +
          _puntos(const Offset(0.25, 0.15), const Offset(0.75, 0.85), 9)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.75, 0.85), const Offset(0.75, 0.15), 9)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('Ñ', [
      _puntos(const Offset(0.25, 0.85), const Offset(0.25, 0.30), 8) +
          _puntos(const Offset(0.25, 0.30), const Offset(0.75, 0.85), 8)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.75, 0.85), const Offset(0.75, 0.30), 8)
              .skip(1)
              .toList(),
      _arcoParcial(const Offset(0.5, 0.12), 0.15, 5, pi, 0),
    ]),
    _TrazoLetra('P', [
      _puntos(const Offset(0.28, 0.85), const Offset(0.28, 0.15), 10),
      _arcoParcial(const Offset(0.30, 0.30), 0.22, 8, -pi / 2, pi / 2),
    ]),
    _TrazoLetra('Q', [
      _arco(const Offset(0.5, 0.45), 0.30, 18),
      _puntos(const Offset(0.65, 0.65), const Offset(0.85, 0.88), 6),
    ]),
    _TrazoLetra('R', [
      _puntos(const Offset(0.28, 0.85), const Offset(0.28, 0.15), 10),
      _arcoParcial(const Offset(0.30, 0.30), 0.22, 8, -pi / 2, pi / 2) +
          _puntos(const Offset(0.30, 0.52), const Offset(0.75, 0.85), 7)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('S', [
      _arcoParcial(const Offset(0.5, 0.30), 0.22, 8, -0.3, pi + 0.3) +
          _arcoParcial(const Offset(0.5, 0.68), 0.22, 8, pi + 0.3, 2 * pi - 0.3)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('U', [
      _puntos(const Offset(0.22, 0.15), const Offset(0.22, 0.65), 7) +
          _arcoParcial(const Offset(0.50, 0.65), 0.28, 8, pi, 2 * pi)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.78, 0.65), const Offset(0.78, 0.15), 7)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('V', [
      _puntos(const Offset(0.18, 0.15), const Offset(0.50, 0.85), 9) +
          _puntos(const Offset(0.50, 0.85), const Offset(0.82, 0.15), 9)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('W', [
      _puntos(const Offset(0.10, 0.15), const Offset(0.30, 0.85), 6) +
          _puntos(const Offset(0.30, 0.85), const Offset(0.50, 0.40), 5)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.50, 0.40), const Offset(0.70, 0.85), 5)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.70, 0.85), const Offset(0.90, 0.15), 6)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('X', [
      _puntos(const Offset(0.20, 0.15), const Offset(0.80, 0.85), 9),
      _puntos(const Offset(0.80, 0.15), const Offset(0.20, 0.85), 9),
    ]),
    _TrazoLetra('Y', [
      _puntos(const Offset(0.20, 0.15), const Offset(0.50, 0.50), 6),
      _puntos(const Offset(0.80, 0.15), const Offset(0.50, 0.50), 6) +
          _puntos(const Offset(0.50, 0.50), const Offset(0.50, 0.85), 6)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('Z', [
      _puntos(const Offset(0.20, 0.18), const Offset(0.80, 0.18), 6) +
          _puntos(const Offset(0.80, 0.18), const Offset(0.20, 0.82), 9)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.20, 0.82), const Offset(0.80, 0.82), 6)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('0', [
      _arco(const Offset(0.5, 0.5), 0.32, 18),
    ]),
    _TrazoLetra('1', [
      _puntos(const Offset(0.35, 0.30), const Offset(0.50, 0.15), 4) +
          _puntos(const Offset(0.50, 0.15), const Offset(0.50, 0.85), 10)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('2', [
      _arcoParcial(const Offset(0.50, 0.30), 0.25, 8, -pi, 0.5) +
          _puntos(const Offset(0.75, 0.40), const Offset(0.22, 0.85), 9)
              .skip(1)
              .toList() +
          _puntos(const Offset(0.22, 0.85), const Offset(0.80, 0.85), 6)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('3', [
      _arcoParcial(const Offset(0.45, 0.32), 0.25, 8, -pi + 0.2, pi / 2) +
          _arcoParcial(const Offset(0.45, 0.68), 0.25, 8, -pi / 2, pi - 0.2)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('4', [
      _puntos(const Offset(0.65, 0.15), const Offset(0.22, 0.60), 8) +
          _puntos(const Offset(0.22, 0.60), const Offset(0.78, 0.60), 6)
              .skip(1)
              .toList(),
      _puntos(const Offset(0.65, 0.20), const Offset(0.65, 0.85), 8),
    ]),
    _TrazoLetra('5', [
      _puntos(const Offset(0.72, 0.18), const Offset(0.28, 0.18), 5) +
          _puntos(const Offset(0.28, 0.18), const Offset(0.28, 0.45), 5)
              .skip(1)
              .toList() +
          _arcoParcial(const Offset(0.48, 0.62), 0.28, 8, -pi / 2 - 0.3, pi / 2 + 0.3)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('6', [
      _arcoParcial(const Offset(0.55, 0.40), 0.30, 10, -0.4, -pi) +
          _arcoParcial(const Offset(0.50, 0.68), 0.25, 10, pi, -pi)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('7', [
      _puntos(const Offset(0.22, 0.18), const Offset(0.80, 0.18), 7) +
          _puntos(const Offset(0.80, 0.18), const Offset(0.40, 0.85), 10)
              .skip(1)
              .toList(),
    ]),
    _TrazoLetra('8', [
      _arco(const Offset(0.50, 0.32), 0.20, 12) +
          _arco(const Offset(0.50, 0.68), 0.22, 12).skip(1).toList(),
    ]),
    _TrazoLetra('9', [
      _arco(const Offset(0.50, 0.35), 0.22, 12) +
          _puntos(const Offset(0.72, 0.35), const Offset(0.55, 0.85), 8)
              .skip(1)
              .toList(),
    ]),
  ];

  static List<Offset> _puntos(Offset a, Offset b, int n) {
    return List.generate(n, (i) {
      final t = i / (n - 1);
      return Offset.lerp(a, b, t)!;
    });
  }

  static List<Offset> _arco(Offset c, double r, int n) {
    return List.generate(n, (i) {
      final ang = -pi / 2 + i * 2 * pi / n;
      return Offset(c.dx + r * cos(ang), c.dy + r * sin(ang));
    });
  }

  static List<Offset> _arcoParcial(
      Offset c, double r, int n, double inicio, double fin) {
    return List.generate(n, (i) {
      final t = i / (n - 1);
      final ang = inicio + t * (fin - inicio);
      return Offset(c.dx + r * cos(ang), c.dy + r * sin(ang));
    });
  }

  int _letraIdx = 0;
  int _trazoActual = 0;
  int _puntoActual = 0;
  bool _animandoExito = false;

  _TrazoLetra get _letra => _letras[_letraIdx];

  void _reset() {
    setState(() {
      _trazoActual = 0;
      _puntoActual = 0;
      _animandoExito = false;
    });
  }

  void _siguienteLetra() {
    setState(() {
      _letraIdx = (_letraIdx + 1) % _letras.length;
      _trazoActual = 0;
      _puntoActual = 0;
      _animandoExito = false;
    });
  }

  void _onPan(Offset pos, Size canvasSize) {
    if (_animandoExito) return;
    if (_trazoActual >= _letra.trazos.length) return;

    final trazo = _letra.trazos[_trazoActual];
    if (_puntoActual >= trazo.length) return;

    final objetivo = trazo[_puntoActual];
    final objetivoPx = Offset(
        objetivo.dx * canvasSize.width, objetivo.dy * canvasSize.height);
    final dist = (pos - objetivoPx).distance;

    if (dist < 50) {
      setState(() => _puntoActual++);
      if (_puntoActual >= trazo.length) {
        if (_trazoActual + 1 < _letra.trazos.length) {
          setState(() {
            _trazoActual++;
            _puntoActual = 0;
          });
        } else {
          _completar();
        }
      }
    }
  }

  Future<void> _completar() async {
    setState(() => _animandoExito = true);
    AudioService.instancia.muyBien();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    AudioService.instancia.letra(_letra.letra);
    await mostrarCelebracion(context, subtitulo: 'Trazaste la ${_letra.letra}');
    if (!mounted) return;
    _siguienteLetra();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Trazar',
      categoria: 'trazo',
      color: const Color(0xFF42C8E2),
      simbolosTema: const ['A', 'B', 'C'],
      audioInstruccion: 'instr_trazar',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const Text(
              'Desliza el dedo sobre la letra',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    onPanUpdate: (d) =>
                        _onPan(d.localPosition, canvasSize),
                    onPanStart: (d) =>
                        _onPan(d.localPosition, canvasSize),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: sombraTarjeta,
                      ),
                      child: CustomPaint(
                        painter: _TrazoPainter(
                          letra: _letra,
                          trazoActual: _trazoActual,
                          puntoActual: _puntoActual,
                          completo: _animandoExito,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BotonAccion(
                  icono: Icons.refresh_rounded,
                  etiqueta: 'Borrar',
                  color: const Color(0xFFFF9F45),
                  onTap: _reset,
                ),
                const SizedBox(width: 14),
                _BotonAccion(
                  icono: Icons.arrow_forward_rounded,
                  etiqueta: 'Otra letra',
                  color: const Color(0xFF42C8E2),
                  onTap: _siguienteLetra,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrazoPainter extends CustomPainter {
  final _TrazoLetra letra;
  final int trazoActual;
  final int puntoActual;
  final bool completo;

  _TrazoPainter({
    required this.letra,
    required this.trazoActual,
    required this.puntoActual,
    required this.completo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Offset px(Offset n) => Offset(n.dx * w, n.dy * h);

    // Fondo de la letra grande en gris claro
    final estiloFondo = Paint()
      ..color = const Color(0xFF7FCFE5).withValues(alpha: 0.20)
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final trazo in letra.trazos) {
      final path = Path()..moveTo(px(trazo.first).dx, px(trazo.first).dy);
      for (final p in trazo.skip(1)) {
        path.lineTo(px(p).dx, px(p).dy);
      }
      canvas.drawPath(path, estiloFondo);
    }

    // Trazo activo (completado) en azul fuerte
    final estiloActivo = Paint()
      ..color = const Color(0xFF2BAFD3)
      ..strokeWidth = w * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var ti = 0; ti < letra.trazos.length; ti++) {
      final trazo = letra.trazos[ti];
      if (ti < trazoActual || completo) {
        // Trazo ya completado
        final path = Path()..moveTo(px(trazo.first).dx, px(trazo.first).dy);
        for (final p in trazo.skip(1)) {
          path.lineTo(px(p).dx, px(p).dy);
        }
        canvas.drawPath(path, estiloActivo);
      } else if (ti == trazoActual && puntoActual > 0) {
        // Trazo en progreso, hasta puntoActual
        final path = Path()..moveTo(px(trazo.first).dx, px(trazo.first).dy);
        for (var i = 1; i <= puntoActual && i < trazo.length; i++) {
          path.lineTo(px(trazo[i]).dx, px(trazo[i]).dy);
        }
        canvas.drawPath(path, estiloActivo);
      }
    }

    // Puntos guía
    for (var ti = 0; ti < letra.trazos.length; ti++) {
      final trazo = letra.trazos[ti];
      for (var i = 0; i < trazo.length; i++) {
        final p = px(trazo[i]);
        final esActual = !completo && ti == trazoActual && i == puntoActual;
        final yaPasado = completo ||
            ti < trazoActual ||
            (ti == trazoActual && i < puntoActual);

        final r = esActual ? 14.0 : 6.0;
        canvas.drawCircle(
          p,
          r,
          Paint()
            ..color = yaPasado
                ? Colors.white
                : esActual
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.85),
        );
        if (esActual) {
          canvas.drawCircle(
            p,
            r,
            Paint()
              ..color = const Color(0xFFFFC83D)
              ..strokeWidth = 4
              ..style = PaintingStyle.stroke,
          );
          // Chevron flotante
          final chevron = Paint()
            ..color = const Color(0xFF66BB6A)
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          final cy = p.dy - 28;
          canvas.drawLine(Offset(p.dx - 8, cy - 4),
              Offset(p.dx, cy + 4), chevron);
          canvas.drawLine(Offset(p.dx, cy + 4),
              Offset(p.dx + 8, cy - 4), chevron);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrazoPainter old) =>
      old.trazoActual != trazoActual ||
      old.puntoActual != puntoActual ||
      old.completo != completo ||
      old.letra.letra != letra.letra;
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final Color color;
  final VoidCallback onTap;

  const _BotonAccion({
    required this.icono,
    required this.etiqueta,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Text(
                etiqueta,
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
