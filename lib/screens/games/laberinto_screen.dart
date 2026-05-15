import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class LaberintoScreen extends StatefulWidget {
  const LaberintoScreen({super.key});

  @override
  State<LaberintoScreen> createState() => _LaberintoScreenState();
}

class _Laberinto {
  final String inicioEmoji;
  final String finEmoji;
  final List<Offset> camino; // waypoints normalizados (0..1)
  const _Laberinto({
    required this.inicioEmoji,
    required this.finEmoji,
    required this.camino,
  });
}

class _LaberintoScreenState extends State<LaberintoScreen> {
  // Caminos sencillos para niños 3-7. Mezcla de patrones para que cada
  // sesión sea distinta.
  static final List<_Laberinto> _laberintos = [
    // 1. Zigzag horizontal de izquierda a derecha
    _Laberinto(
      inicioEmoji: '🐭',
      finEmoji: '🧀',
      camino: [
        const Offset(0.08, 0.18),
        const Offset(0.30, 0.18),
        const Offset(0.30, 0.45),
        const Offset(0.55, 0.45),
        const Offset(0.55, 0.70),
        const Offset(0.92, 0.70),
      ],
    ),
    // 2. U invertida
    _Laberinto(
      inicioEmoji: '🐶',
      finEmoji: '🦴',
      camino: [
        const Offset(0.10, 0.85),
        const Offset(0.10, 0.20),
        const Offset(0.50, 0.20),
        const Offset(0.90, 0.20),
        const Offset(0.90, 0.85),
      ],
    ),
    // 3. Camino curvilíneo en S
    _Laberinto(
      inicioEmoji: '🐝',
      finEmoji: '🌹',
      camino: [
        const Offset(0.10, 0.15),
        const Offset(0.50, 0.30),
        const Offset(0.85, 0.45),
        const Offset(0.50, 0.65),
        const Offset(0.15, 0.85),
        const Offset(0.92, 0.85),
      ],
    ),
    // 4. Escalera descendente
    _Laberinto(
      inicioEmoji: '🐱',
      finEmoji: '🐟',
      camino: [
        const Offset(0.10, 0.15),
        const Offset(0.35, 0.15),
        const Offset(0.35, 0.40),
        const Offset(0.60, 0.40),
        const Offset(0.60, 0.65),
        const Offset(0.90, 0.65),
        const Offset(0.90, 0.88),
      ],
    ),
    // 5. Diagonal con codo
    _Laberinto(
      inicioEmoji: '🐰',
      finEmoji: '🥕',
      camino: [
        const Offset(0.10, 0.20),
        const Offset(0.30, 0.50),
        const Offset(0.55, 0.65),
        const Offset(0.85, 0.85),
      ],
    ),
    // 6. Espiral hacia adentro
    _Laberinto(
      inicioEmoji: '🐢',
      finEmoji: '🌿',
      camino: [
        const Offset(0.10, 0.10),
        const Offset(0.90, 0.10),
        const Offset(0.90, 0.90),
        const Offset(0.10, 0.90),
        const Offset(0.10, 0.30),
        const Offset(0.70, 0.30),
        const Offset(0.70, 0.70),
        const Offset(0.40, 0.70),
        const Offset(0.40, 0.50),
      ],
    ),
    // 7. Zigzag vertical
    _Laberinto(
      inicioEmoji: '🐦',
      finEmoji: '🌳',
      camino: [
        const Offset(0.15, 0.10),
        const Offset(0.15, 0.30),
        const Offset(0.50, 0.30),
        const Offset(0.50, 0.55),
        const Offset(0.85, 0.55),
        const Offset(0.85, 0.85),
      ],
    ),
    // 8. L mayúscula
    _Laberinto(
      inicioEmoji: '🦊',
      finEmoji: '🍇',
      camino: [
        const Offset(0.15, 0.15),
        const Offset(0.15, 0.85),
        const Offset(0.90, 0.85),
      ],
    ),
    // 9. Z mayúscula
    _Laberinto(
      inicioEmoji: '🐝',
      finEmoji: '🍯',
      camino: [
        const Offset(0.10, 0.15),
        const Offset(0.90, 0.15),
        const Offset(0.20, 0.85),
        const Offset(0.90, 0.85),
      ],
    ),
    // 10. M (subir-bajar-subir-bajar)
    _Laberinto(
      inicioEmoji: '🐛',
      finEmoji: '🍓',
      camino: [
        const Offset(0.10, 0.85),
        const Offset(0.25, 0.15),
        const Offset(0.50, 0.55),
        const Offset(0.75, 0.15),
        const Offset(0.90, 0.85),
      ],
    ),
    // 11. Diagonal recta
    _Laberinto(
      inicioEmoji: '🐌',
      finEmoji: '🌺',
      camino: [
        const Offset(0.10, 0.10),
        const Offset(0.35, 0.35),
        const Offset(0.60, 0.60),
        const Offset(0.90, 0.90),
      ],
    ),
    // 12. Caracol cuadrado pequeño
    _Laberinto(
      inicioEmoji: '🦋',
      finEmoji: '🌸',
      camino: [
        const Offset(0.50, 0.50),
        const Offset(0.80, 0.50),
        const Offset(0.80, 0.85),
        const Offset(0.15, 0.85),
        const Offset(0.15, 0.20),
        const Offset(0.85, 0.20),
      ],
    ),
    // 13. Camino con tres codos
    _Laberinto(
      inicioEmoji: '🐥',
      finEmoji: '🐣',
      camino: [
        const Offset(0.10, 0.20),
        const Offset(0.40, 0.20),
        const Offset(0.40, 0.50),
        const Offset(0.70, 0.50),
        const Offset(0.70, 0.20),
        const Offset(0.90, 0.20),
        const Offset(0.90, 0.85),
      ],
    ),
    // 14. V invertida (montaña)
    _Laberinto(
      inicioEmoji: '🐭',
      finEmoji: '🧀',
      camino: [
        const Offset(0.10, 0.85),
        const Offset(0.30, 0.50),
        const Offset(0.50, 0.15),
        const Offset(0.70, 0.50),
        const Offset(0.90, 0.85),
      ],
    ),
    // 15. Doble U (W)
    _Laberinto(
      inicioEmoji: '🐶',
      finEmoji: '🎾',
      camino: [
        const Offset(0.10, 0.15),
        const Offset(0.10, 0.85),
        const Offset(0.40, 0.85),
        const Offset(0.40, 0.30),
        const Offset(0.60, 0.30),
        const Offset(0.60, 0.85),
        const Offset(0.90, 0.85),
      ],
    ),
  ];

  final _rng = Random();
  late List<int> _orden; // índices barajados
  int _posicionEnOrden = 0;
  int _puntoActual = 0;
  bool _completo = false;

  _Laberinto get _lab => _laberintos[_orden[_posicionEnOrden]];

  @override
  void initState() {
    super.initState();
    _orden = List.generate(_laberintos.length, (i) => i)..shuffle(_rng);
  }

  void _siguiente() {
    setState(() {
      _posicionEnOrden++;
      if (_posicionEnOrden >= _orden.length) {
        // Re-mezclar al terminar el ciclo
        _orden = List.generate(_laberintos.length, (i) => i)..shuffle(_rng);
        _posicionEnOrden = 0;
      }
      _puntoActual = 0;
      _completo = false;
    });
  }

  void _reset() {
    setState(() {
      _puntoActual = 0;
      _completo = false;
    });
  }

  void _onPan(Offset pos, Size size) {
    if (_completo) return;
    if (_puntoActual >= _lab.camino.length) return;
    final objetivo = _lab.camino[_puntoActual];
    final objetivoPx = Offset(
      objetivo.dx * size.width,
      objetivo.dy * size.height,
    );
    if ((pos - objetivoPx).distance < 50) {
      setState(() => _puntoActual++);
      if (_puntoActual >= _lab.camino.length) {
        _completar();
      }
    }
  }

  Future<void> _completar() async {
    setState(() => _completo = true);
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('motrices');
    AudioService.instancia.muyBien();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await mostrarCelebracion(context, subtitulo: '¡Llegaste!');
    if (!mounted) return;
    _siguiente();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Laberinto',
      categoria: 'motrices',
      color: const Color(0xFFFF6B7A),
      simbolosTema: const ['🌿', '✦'],
      audioInstruccion: 'instr_laberinto',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            const Text(
              'Lleva el dedo desde el inicio hasta el final',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _onPan(d.localPosition, size),
                    onPanUpdate: (d) => _onPan(d.localPosition, size),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: sombraTarjeta,
                        border: Border.all(
                          color: const Color(0xFFFF6B7A).withValues(alpha: 0.25),
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _LaberintoPainter(
                          camino: _lab.camino,
                          puntoActual: _puntoActual,
                          completo: _completo,
                        ),
                        size: Size.infinite,
                        child: LayoutBuilder(
                          builder: (context, c) {
                            return Stack(
                              children: [
                                Positioned(
                                  left: _lab.camino.first.dx * c.maxWidth - 22,
                                  top: _lab.camino.first.dy * c.maxHeight - 22,
                                  child: IconKid(_lab.inicioEmoji, size: 44, sombra: true),
                                ),
                                Positioned(
                                  left: _lab.camino.last.dx * c.maxWidth - 22,
                                  top: _lab.camino.last.dy * c.maxHeight - 22,
                                  child: IconKid(_lab.finEmoji, size: 44, sombra: true),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: const Color(0xFFFF9F45),
                  borderRadius: BorderRadius.circular(20),
                  elevation: 4,
                  child: InkWell(
                    onTap: _reset,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Empezar de nuevo',
                            style: TextStyle(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LaberintoPainter extends CustomPainter {
  final List<Offset> camino;
  final int puntoActual;
  final bool completo;

  _LaberintoPainter({
    required this.camino,
    required this.puntoActual,
    required this.completo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (camino.isEmpty) return;

    Offset px(Offset n) => Offset(n.dx * size.width, n.dy * size.height);

    // Camino base (gris claro)
    final base = Paint()
      ..color = const Color(0xFFFF6B7A).withValues(alpha: 0.18)
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final pathBase = Path()..moveTo(px(camino.first).dx, px(camino.first).dy);
    for (final p in camino.skip(1)) {
      pathBase.lineTo(px(p).dx, px(p).dy);
    }
    canvas.drawPath(pathBase, base);

    // Camino recorrido en color vivo
    final activo = Paint()
      ..color = const Color(0xFFFF6B7A)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final limite = completo ? camino.length : puntoActual;
    if (limite > 0) {
      final pathActivo = Path()..moveTo(px(camino.first).dx, px(camino.first).dy);
      for (var i = 1; i < limite && i < camino.length; i++) {
        pathActivo.lineTo(px(camino[i]).dx, px(camino[i]).dy);
      }
      canvas.drawPath(pathActivo, activo);
    }

    // Punto siguiente con halo amarillo
    if (!completo && puntoActual < camino.length) {
      final p = px(camino[puntoActual]);
      canvas.drawCircle(
        p,
        18,
        Paint()..color = const Color(0x55FFC83D),
      );
      canvas.drawCircle(
        p,
        10,
        Paint()..color = const Color(0xFFFFC83D),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LaberintoPainter old) =>
      old.puntoActual != puntoActual ||
      old.completo != completo ||
      old.camino != camino;
}
