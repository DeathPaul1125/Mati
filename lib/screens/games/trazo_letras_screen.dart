import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class TrazoLetrasScreen extends StatefulWidget {
  const TrazoLetrasScreen({super.key});

  @override
  State<TrazoLetrasScreen> createState() => _TrazoLetrasScreenState();
}

class _LetraTrazo {
  final String letra;
  final String palabra;
  final String emoji;
  final List<List<Offset>> trazos;
  const _LetraTrazo({
    required this.letra,
    required this.palabra,
    required this.emoji,
    required this.trazos,
  });
}

class _TrazoLetrasScreenState extends State<TrazoLetrasScreen>
    with SingleTickerProviderStateMixin {
  static final List<_LetraTrazo> _letras = _construirLetras();

  static const _coloresLetra = <Color>[
    Color(0xFFFF6B7A),
    Color(0xFFFFAE3D),
    Color(0xFF22C55E),
    Color(0xFF42C8E2),
    Color(0xFFA855F7),
    Color(0xFFE94B86),
    Color(0xFF4ECDA4),
    Color(0xFF5B8DEF),
  ];

  int _letraIdx = 0;
  int _trazoActual = 0;
  int _puntoActual = 0;
  bool _animandoExito = false;
  bool _mostrarTutorial = false;
  late final AnimationController _pulso;
  late final AnimationController _manoTutorial;

  _LetraTrazo get _letra => _letras[_letraIdx];
  Color get _colorLetra => _coloresLetra[_letraIdx % _coloresLetra.length];
  bool get _completo {
    if (_trazoActual >= _letra.trazos.length) return true;
    return _trazoActual == _letra.trazos.length - 1 &&
        _puntoActual >= _letra.trazos.last.length;
  }

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _manoTutorial = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    // Mostrar el tutorial solo si el perfil aún NO lo vio.
    final perfil = PerfilesService.instancia.activo;
    if (perfil != null && !perfil.tutorialesVistos.contains('trazar')) {
      _mostrarTutorial = true;
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    _manoTutorial.dispose();
    super.dispose();
  }

  void _dejarTutorial() {
    if (!_mostrarTutorial) return;
    setState(() => _mostrarTutorial = false);
    PerfilesService.instancia.marcarTutorialVisto('trazar');
  }

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
      _dejarTutorial();
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
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('trazo');
    AudioService.instancia.celebrarYLetra(_letra.letra, palabraEjemplo: _letra.palabra);
    await mostrarCelebracion(
      context,
      subtitulo: '${_letra.letra} de ${_letra.palabra}',
    );
    if (!mounted) return;
    _siguienteLetra();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Trazar',
      categoria: 'trazo',
      color: _colorLetra,
      simbolosTema: const ['A', 'B', 'C', 'D'],
      audioInstruccion: 'instr_trazar',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            _Encabezado(
              letra: _letra,
              indice: _letraIdx + 1,
              total: _letras.length,
              color: _colorLetra,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onPanUpdate: (d) =>
                        _onPan(d.localPosition, canvasSize),
                    onPanStart: (d) =>
                        _onPan(d.localPosition, canvasSize),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Color.lerp(_colorLetra, Colors.white, 0.92)!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: sombraTarjeta,
                        border: Border.all(
                          color: _colorLetra.withValues(alpha: 0.25),
                          width: 3,
                        ),
                      ),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _pulso,
                            builder: (_, _) => CustomPaint(
                              painter: _TrazoPainter(
                                letra: _letra,
                                color: _colorLetra,
                                trazoActual: _trazoActual,
                                puntoActual: _puntoActual,
                                completo: _animandoExito,
                                pulso: _pulso.value,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                          if (_mostrarTutorial && _puntoActual == 0)
                            _ManoTutorial(
                              animacion: _manoTutorial,
                              puntos: _letra.trazos.first,
                              canvasSize: canvasSize,
                            ),
                        ],
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
              ],
            ),
            if (!_completo)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Termina el trazo para pasar a la siguiente letra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: KidsColors.textoSuave.withValues(alpha: 0.85),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final _LetraTrazo letra;
  final int indice;
  final int total;
  final Color color;

  const _Encabezado({
    required this.letra,
    required this.indice,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraSuave,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: gradienteCategoria(color),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              letra.letra,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconKid(letra.emoji, size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  letra.palabra,
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: KidsColors.texto,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Letra $indice de $total',
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrazoPainter extends CustomPainter {
  final _LetraTrazo letra;
  final Color color;
  final int trazoActual;
  final int puntoActual;
  final bool completo;
  final double pulso;

  _TrazoPainter({
    required this.letra,
    required this.color,
    required this.trazoActual,
    required this.puntoActual,
    required this.completo,
    required this.pulso,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final lado = min(w, h);

    // Centrar y escalar el trazado para que use el espacio cuadrado
    final escala = lado * 0.92;
    final ox = (w - escala) / 2;
    final oy = (h - escala) / 2;
    Offset px(Offset n) => Offset(ox + n.dx * escala, oy + n.dy * escala);

    final anchoTrazo = escala * 0.16;

    // Fondo de la letra grande en color suave
    final estiloFondo = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = anchoTrazo
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

    // Trazo activo (completado) con color vivo
    final estiloActivo = Paint()
      ..color = color
      ..strokeWidth = anchoTrazo * 0.92
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var ti = 0; ti < letra.trazos.length; ti++) {
      final trazo = letra.trazos[ti];
      if (ti < trazoActual || completo) {
        final path = Path()..moveTo(px(trazo.first).dx, px(trazo.first).dy);
        for (final p in trazo.skip(1)) {
          path.lineTo(px(p).dx, px(p).dy);
        }
        canvas.drawPath(path, estiloActivo);
      } else if (ti == trazoActual && puntoActual > 0) {
        final path = Path()..moveTo(px(trazo.first).dx, px(trazo.first).dy);
        for (var i = 1; i <= puntoActual && i < trazo.length; i++) {
          path.lineTo(px(trazo[i]).dx, px(trazo[i]).dy);
        }
        canvas.drawPath(path, estiloActivo);
      }
    }

    // Puntos guía sobre el trazo
    for (var ti = 0; ti < letra.trazos.length; ti++) {
      final trazo = letra.trazos[ti];
      for (var i = 0; i < trazo.length; i++) {
        final p = px(trazo[i]);
        final esActual = !completo && ti == trazoActual && i == puntoActual;
        final yaPasado = completo ||
            ti < trazoActual ||
            (ti == trazoActual && i < puntoActual);
        final r = esActual ? 9.0 : 4.0;

        if (yaPasado) continue;

        canvas.drawCircle(
          p,
          r,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(
          p,
          r,
          Paint()
            ..color = color.withValues(alpha: 0.45)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Indicador pulsante en el punto activo
    if (!completo &&
        trazoActual < letra.trazos.length &&
        puntoActual < letra.trazos[trazoActual].length) {
      final p = px(letra.trazos[trazoActual][puntoActual]);
      final pulseRadio = 18.0 + pulso * 14.0;

      canvas.drawCircle(
        p,
        pulseRadio,
        Paint()..color = color.withValues(alpha: 0.18 * (1.0 - pulso * 0.5)),
      );
      canvas.drawCircle(
        p,
        16,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        p,
        16,
        Paint()
          ..color = color
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke,
      );

      // Si es el inicio de un trazo, mostrar flecha
      if (puntoActual == 0 && letra.trazos[trazoActual].length > 1) {
        final p2 = px(letra.trazos[trazoActual][1]);
        final dir = p2 - p;
        final d = dir.distance;
        if (d > 0) {
          final ux = dir.dx / d;
          final uy = dir.dy / d;
          final start = Offset(p.dx + ux * 22, p.dy + uy * 22);
          final end = Offset(p.dx + ux * 40, p.dy + uy * 40);
          final flecha = Paint()
            ..color = color
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;
          canvas.drawLine(start, end, flecha);
          // Punta de flecha
          final angulo = atan2(uy, ux);
          const cabeza = 10.0;
          canvas.drawLine(
            end,
            Offset(end.dx - cabeza * cos(angulo - 0.5),
                end.dy - cabeza * sin(angulo - 0.5)),
            flecha,
          );
          canvas.drawLine(
            end,
            Offset(end.dx - cabeza * cos(angulo + 0.5),
                end.dy - cabeza * sin(angulo + 0.5)),
            flecha,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrazoPainter old) =>
      old.trazoActual != trazoActual ||
      old.puntoActual != puntoActual ||
      old.completo != completo ||
      old.pulso != pulso ||
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: Colors.white, size: 22),
              const SizedBox(width: 8),
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

// ---------------------------------------------------------------------------
// Construcción de los trazos del abecedario en orden A → Z (incluyendo Ñ).
// ---------------------------------------------------------------------------

List<Offset> _linea(Offset a, Offset b, int n) {
  return List.generate(n, (i) {
    final t = i / (n - 1);
    return Offset.lerp(a, b, t)!;
  });
}

List<Offset> _arco(Offset c, double r, int n, double inicio, double fin) {
  return List.generate(n, (i) {
    final t = i / (n - 1);
    final ang = inicio + t * (fin - inicio);
    return Offset(c.dx + r * cos(ang), c.dy + r * sin(ang));
  });
}

List<Offset> _circulo(Offset c, double r, int n) {
  return List.generate(n, (i) {
    final ang = -pi / 2 + i * 2 * pi / n;
    return Offset(c.dx + r * cos(ang), c.dy + r * sin(ang));
  });
}

List<Offset> _concat(List<List<Offset>> partes) {
  final out = <Offset>[];
  for (var i = 0; i < partes.length; i++) {
    out.addAll(i == 0 ? partes[i] : partes[i].skip(1));
  }
  return out;
}

List<_LetraTrazo> _construirLetras() {
  return [
    _LetraTrazo(
      letra: 'A',
      palabra: 'Árbol',
      emoji: '🌳',
      trazos: [
        _concat([
          _linea(const Offset(0.18, 0.88), const Offset(0.50, 0.12), 10),
          _linea(const Offset(0.50, 0.12), const Offset(0.82, 0.88), 10),
        ]),
        _linea(const Offset(0.30, 0.62), const Offset(0.70, 0.62), 6),
      ],
    ),
    _LetraTrazo(
      letra: 'B',
      palabra: 'Banana',
      emoji: '🍌',
      trazos: [
        _linea(const Offset(0.28, 0.12), const Offset(0.28, 0.88), 11),
        _concat([
          _arco(const Offset(0.30, 0.32), 0.21, 8, -pi / 2, pi / 2),
          _arco(const Offset(0.30, 0.68), 0.23, 8, -pi / 2, pi / 2),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'C',
      palabra: 'Cachorro',
      emoji: '🐶',
      trazos: [
        // 270° abierto a la derecha: empieza arriba-derecha, sube al tope,
        // baja por la izquierda, pasa por el fondo y termina abajo-derecha.
        _arco(const Offset(0.50, 0.50), 0.34, 16, -pi / 4, -7 * pi / 4),
      ],
    ),
    _LetraTrazo(
      letra: 'D',
      palabra: 'Dulce',
      emoji: '🍩',
      trazos: [
        _linea(const Offset(0.28, 0.12), const Offset(0.28, 0.88), 11),
        _arco(const Offset(0.30, 0.50), 0.36, 14, -pi / 2, pi / 2),
      ],
    ),
    _LetraTrazo(
      letra: 'E',
      palabra: 'Elefante',
      emoji: '🐘',
      trazos: [
        _concat([
          _linea(const Offset(0.72, 0.18), const Offset(0.25, 0.18), 6),
          _linea(const Offset(0.25, 0.18), const Offset(0.25, 0.85), 9),
          _linea(const Offset(0.25, 0.85), const Offset(0.74, 0.85), 6),
        ]),
        _linea(const Offset(0.25, 0.51), const Offset(0.64, 0.51), 5),
      ],
    ),
    _LetraTrazo(
      letra: 'F',
      palabra: 'Fresa',
      emoji: '🍓',
      trazos: [
        _concat([
          _linea(const Offset(0.72, 0.18), const Offset(0.25, 0.18), 6),
          _linea(const Offset(0.25, 0.18), const Offset(0.25, 0.88), 9),
        ]),
        _linea(const Offset(0.25, 0.50), const Offset(0.60, 0.50), 5),
      ],
    ),
    _LetraTrazo(
      letra: 'G',
      palabra: 'Gato',
      emoji: '🐱',
      trazos: [
        _concat([
          // Misma C correcta…
          _arco(const Offset(0.50, 0.50), 0.34, 16, -pi / 4, -7 * pi / 4),
          // …y un gancho desde la esquina inferior-derecha hacia el centro.
          _linea(const Offset(0.74, 0.74), const Offset(0.74, 0.50), 5),
          _linea(const Offset(0.74, 0.50), const Offset(0.54, 0.50), 4),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'H',
      palabra: 'Helado',
      emoji: '🍦',
      trazos: [
        _linea(const Offset(0.25, 0.12), const Offset(0.25, 0.88), 11),
        _linea(const Offset(0.75, 0.12), const Offset(0.75, 0.88), 11),
        _linea(const Offset(0.25, 0.50), const Offset(0.75, 0.50), 6),
      ],
    ),
    _LetraTrazo(
      letra: 'I',
      palabra: 'Iguana',
      emoji: '🦎',
      trazos: [
        _linea(const Offset(0.50, 0.15), const Offset(0.50, 0.85), 12),
      ],
    ),
    _LetraTrazo(
      letra: 'J',
      palabra: 'Jirafa',
      emoji: '🦒',
      trazos: [
        _concat([
          _linea(const Offset(0.65, 0.15), const Offset(0.65, 0.68), 8),
          _arco(const Offset(0.45, 0.68), 0.20, 7, 0, pi),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'K',
      palabra: 'Koala',
      emoji: '🐨',
      trazos: [
        _linea(const Offset(0.25, 0.12), const Offset(0.25, 0.88), 11),
        _linea(const Offset(0.75, 0.18), const Offset(0.25, 0.50), 7),
        _linea(const Offset(0.25, 0.50), const Offset(0.75, 0.88), 7),
      ],
    ),
    _LetraTrazo(
      letra: 'L',
      palabra: 'León',
      emoji: '🦁',
      trazos: [
        _concat([
          _linea(const Offset(0.30, 0.12), const Offset(0.30, 0.85), 10),
          _linea(const Offset(0.30, 0.85), const Offset(0.78, 0.85), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'M',
      palabra: 'Manzana',
      emoji: '🍎',
      trazos: [
        _concat([
          _linea(const Offset(0.18, 0.88), const Offset(0.18, 0.15), 9),
          _linea(const Offset(0.18, 0.15), const Offset(0.50, 0.58), 6),
          _linea(const Offset(0.50, 0.58), const Offset(0.82, 0.15), 6),
          _linea(const Offset(0.82, 0.15), const Offset(0.82, 0.88), 9),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'N',
      palabra: 'Nube',
      emoji: '☁️',
      trazos: [
        _concat([
          _linea(const Offset(0.25, 0.88), const Offset(0.25, 0.12), 10),
          _linea(const Offset(0.25, 0.12), const Offset(0.75, 0.88), 10),
          _linea(const Offset(0.75, 0.88), const Offset(0.75, 0.12), 10),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'Ñ',
      palabra: 'Ñandú',
      emoji: '🦤',
      trazos: [
        _concat([
          _linea(const Offset(0.25, 0.85), const Offset(0.25, 0.28), 8),
          _linea(const Offset(0.25, 0.28), const Offset(0.75, 0.85), 9),
          _linea(const Offset(0.75, 0.85), const Offset(0.75, 0.28), 8),
        ]),
        _arco(const Offset(0.50, 0.13), 0.15, 6, pi, 2 * pi),
      ],
    ),
    _LetraTrazo(
      letra: 'O',
      palabra: 'Oso',
      emoji: '🐻',
      trazos: [
        _circulo(const Offset(0.50, 0.50), 0.34, 18),
      ],
    ),
    _LetraTrazo(
      letra: 'P',
      palabra: 'Pizza',
      emoji: '🍕',
      trazos: [
        _linea(const Offset(0.28, 0.88), const Offset(0.28, 0.12), 11),
        _arco(const Offset(0.30, 0.30), 0.22, 8, -pi / 2, pi / 2),
      ],
    ),
    _LetraTrazo(
      letra: 'Q',
      palabra: 'Queso',
      emoji: '🧀',
      trazos: [
        _circulo(const Offset(0.50, 0.45), 0.32, 18),
        _linea(const Offset(0.62, 0.62), const Offset(0.85, 0.88), 6),
      ],
    ),
    _LetraTrazo(
      letra: 'R',
      palabra: 'Ratón',
      emoji: '🐭',
      trazos: [
        _linea(const Offset(0.28, 0.88), const Offset(0.28, 0.12), 11),
        _concat([
          _arco(const Offset(0.30, 0.30), 0.22, 8, -pi / 2, pi / 2),
          _linea(const Offset(0.30, 0.52), const Offset(0.78, 0.88), 8),
        ]),
      ],
    ),
    // S corregida: trazo continuo con 18 waypoints que dibujan una S limpia.
    _LetraTrazo(
      letra: 'S',
      palabra: 'Sol',
      emoji: '🌞',
      trazos: [
        const [
          Offset(0.72, 0.20),
          Offset(0.62, 0.14),
          Offset(0.50, 0.12),
          Offset(0.38, 0.14),
          Offset(0.27, 0.20),
          Offset(0.22, 0.30),
          Offset(0.24, 0.40),
          Offset(0.32, 0.46),
          Offset(0.45, 0.49),
          Offset(0.58, 0.52),
          Offset(0.70, 0.58),
          Offset(0.77, 0.68),
          Offset(0.75, 0.78),
          Offset(0.66, 0.86),
          Offset(0.50, 0.88),
          Offset(0.35, 0.86),
          Offset(0.26, 0.80),
          Offset(0.22, 0.72),
        ],
      ],
    ),
    _LetraTrazo(
      letra: 'T',
      palabra: 'Tigre',
      emoji: '🐯',
      trazos: [
        _linea(const Offset(0.15, 0.18), const Offset(0.85, 0.18), 9),
        _linea(const Offset(0.50, 0.18), const Offset(0.50, 0.88), 10),
      ],
    ),
    // U corregida: la curva inferior ahora va realmente hacia abajo.
    _LetraTrazo(
      letra: 'U',
      palabra: 'Uva',
      emoji: '🍇',
      trazos: [
        _concat([
          _linea(const Offset(0.22, 0.15), const Offset(0.22, 0.62), 7),
          _arco(const Offset(0.50, 0.62), 0.28, 9, pi, 0),
          _linea(const Offset(0.78, 0.62), const Offset(0.78, 0.15), 7),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'V',
      palabra: 'Vaca',
      emoji: '🐮',
      trazos: [
        _concat([
          _linea(const Offset(0.18, 0.15), const Offset(0.50, 0.88), 10),
          _linea(const Offset(0.50, 0.88), const Offset(0.82, 0.15), 10),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'W',
      palabra: 'Wifi',
      emoji: '📶',
      trazos: [
        _concat([
          _linea(const Offset(0.10, 0.15), const Offset(0.30, 0.88), 7),
          _linea(const Offset(0.30, 0.88), const Offset(0.50, 0.40), 6),
          _linea(const Offset(0.50, 0.40), const Offset(0.70, 0.88), 6),
          _linea(const Offset(0.70, 0.88), const Offset(0.90, 0.15), 7),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'X',
      palabra: 'Xilófono',
      emoji: '🎵',
      trazos: [
        _linea(const Offset(0.18, 0.15), const Offset(0.82, 0.88), 10),
        _linea(const Offset(0.82, 0.15), const Offset(0.18, 0.88), 10),
      ],
    ),
    _LetraTrazo(
      letra: 'Y',
      palabra: 'Yate',
      emoji: '⛵',
      trazos: [
        _linea(const Offset(0.20, 0.15), const Offset(0.50, 0.50), 7),
        _concat([
          _linea(const Offset(0.80, 0.15), const Offset(0.50, 0.50), 7),
          _linea(const Offset(0.50, 0.50), const Offset(0.50, 0.88), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'Z',
      palabra: 'Zorro',
      emoji: '🦊',
      trazos: [
        _concat([
          _linea(const Offset(0.20, 0.18), const Offset(0.80, 0.18), 7),
          _linea(const Offset(0.80, 0.18), const Offset(0.20, 0.82), 10),
          _linea(const Offset(0.20, 0.82), const Offset(0.80, 0.82), 7),
        ]),
      ],
    ),

    // ============================================================
    // Minúsculas (a → z) — cuerpo en y=[0.35, 0.85] con ascendentes
    // hasta y=0.10 y descendentes hasta y=0.92.
    // ============================================================
    _LetraTrazo(
      letra: 'a',
      palabra: 'árbol',
      emoji: '🌳',
      trazos: [
        _circulo(const Offset(0.42, 0.62), 0.22, 16),
        _linea(const Offset(0.64, 0.42), const Offset(0.64, 0.85), 7),
      ],
    ),
    _LetraTrazo(
      letra: 'b',
      palabra: 'banana',
      emoji: '🍌',
      trazos: [
        _linea(const Offset(0.30, 0.12), const Offset(0.30, 0.85), 11),
        _arco(const Offset(0.30, 0.65), 0.20, 10, -pi / 2, pi / 2),
      ],
    ),
    _LetraTrazo(
      letra: 'c',
      palabra: 'cachorro',
      emoji: '🐶',
      trazos: [
        _arco(const Offset(0.55, 0.62), 0.25, 14, -pi / 4, -7 * pi / 4),
      ],
    ),
    _LetraTrazo(
      letra: 'd',
      palabra: 'dulce',
      emoji: '🍩',
      trazos: [
        _circulo(const Offset(0.42, 0.62), 0.22, 16),
        _linea(const Offset(0.64, 0.12), const Offset(0.64, 0.85), 11),
      ],
    ),
    _LetraTrazo(
      letra: 'e',
      palabra: 'elefante',
      emoji: '🐘',
      trazos: [
        _concat([
          _linea(const Offset(0.66, 0.62), const Offset(0.30, 0.62), 6),
          _arco(const Offset(0.48, 0.62), 0.18, 13, pi, 2 * pi + 0.4),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'f',
      palabra: 'fresa',
      emoji: '🍓',
      trazos: [
        _concat([
          _arco(const Offset(0.50, 0.25), 0.15, 7, 0, -pi),
          _linea(const Offset(0.35, 0.25), const Offset(0.35, 0.85), 9),
        ]),
        _linea(const Offset(0.20, 0.50), const Offset(0.55, 0.50), 5),
      ],
    ),
    _LetraTrazo(
      letra: 'g',
      palabra: 'gato',
      emoji: '🐱',
      trazos: [
        _circulo(const Offset(0.42, 0.62), 0.22, 16),
        _concat([
          _linea(const Offset(0.64, 0.42), const Offset(0.64, 0.88), 8),
          _linea(const Offset(0.64, 0.88), const Offset(0.40, 0.92), 4),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'h',
      palabra: 'helado',
      emoji: '🍦',
      trazos: [
        _linea(const Offset(0.30, 0.12), const Offset(0.30, 0.85), 11),
        _concat([
          _arco(const Offset(0.46, 0.55), 0.16, 8, -pi, 0),
          _linea(const Offset(0.62, 0.55), const Offset(0.62, 0.85), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'i',
      palabra: 'iguana',
      emoji: '🦎',
      trazos: [
        _linea(const Offset(0.50, 0.42), const Offset(0.50, 0.85), 9),
        _circulo(const Offset(0.50, 0.25), 0.045, 6),
      ],
    ),
    _LetraTrazo(
      letra: 'j',
      palabra: 'jirafa',
      emoji: '🦒',
      trazos: [
        _concat([
          _linea(const Offset(0.55, 0.42), const Offset(0.55, 0.83), 8),
          _arco(const Offset(0.42, 0.83), 0.13, 6, 0, pi),
        ]),
        _circulo(const Offset(0.55, 0.25), 0.045, 6),
      ],
    ),
    _LetraTrazo(
      letra: 'k',
      palabra: 'koala',
      emoji: '🐨',
      trazos: [
        _linea(const Offset(0.30, 0.12), const Offset(0.30, 0.85), 11),
        _linea(const Offset(0.60, 0.50), const Offset(0.30, 0.68), 6),
        _linea(const Offset(0.30, 0.68), const Offset(0.60, 0.85), 6),
      ],
    ),
    _LetraTrazo(
      letra: 'l',
      palabra: 'león',
      emoji: '🦁',
      trazos: [
        _linea(const Offset(0.50, 0.12), const Offset(0.50, 0.85), 11),
      ],
    ),
    _LetraTrazo(
      letra: 'm',
      palabra: 'manzana',
      emoji: '🍎',
      trazos: [
        _concat([
          _linea(const Offset(0.18, 0.85), const Offset(0.18, 0.45), 6),
          _linea(const Offset(0.18, 0.45), const Offset(0.40, 0.45), 4),
          _linea(const Offset(0.40, 0.45), const Offset(0.40, 0.85), 6),
        ]),
        _concat([
          _linea(const Offset(0.40, 0.45), const Offset(0.62, 0.45), 4),
          _linea(const Offset(0.62, 0.45), const Offset(0.62, 0.85), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'n',
      palabra: 'nube',
      emoji: '☁️',
      trazos: [
        _concat([
          _linea(const Offset(0.30, 0.85), const Offset(0.30, 0.45), 6),
          _linea(const Offset(0.30, 0.45), const Offset(0.62, 0.45), 5),
          _linea(const Offset(0.62, 0.45), const Offset(0.62, 0.85), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'ñ',
      palabra: 'ñandú',
      emoji: '🦤',
      trazos: [
        _concat([
          _linea(const Offset(0.30, 0.85), const Offset(0.30, 0.55), 5),
          _linea(const Offset(0.30, 0.55), const Offset(0.62, 0.55), 5),
          _linea(const Offset(0.62, 0.55), const Offset(0.62, 0.85), 5),
        ]),
        _arco(const Offset(0.46, 0.32), 0.13, 6, pi, 2 * pi),
      ],
    ),
    _LetraTrazo(
      letra: 'o',
      palabra: 'oso',
      emoji: '🐻',
      trazos: [
        _circulo(const Offset(0.50, 0.62), 0.23, 16),
      ],
    ),
    _LetraTrazo(
      letra: 'p',
      palabra: 'pizza',
      emoji: '🍕',
      trazos: [
        _linea(const Offset(0.28, 0.92), const Offset(0.28, 0.42), 9),
        _arco(const Offset(0.28, 0.57), 0.16, 9, -pi / 2, pi / 2),
      ],
    ),
    _LetraTrazo(
      letra: 'q',
      palabra: 'queso',
      emoji: '🧀',
      trazos: [
        _circulo(const Offset(0.40, 0.62), 0.22, 16),
        _linea(const Offset(0.62, 0.42), const Offset(0.62, 0.92), 9),
      ],
    ),
    _LetraTrazo(
      letra: 'r',
      palabra: 'ratón',
      emoji: '🐭',
      trazos: [
        _concat([
          _arco(const Offset(0.42, 0.50), 0.13, 6, -pi / 3, -pi),
          _linea(const Offset(0.29, 0.50), const Offset(0.29, 0.85), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 's',
      palabra: 'sol',
      emoji: '🌞',
      trazos: [
        const [
          Offset(0.65, 0.46),
          Offset(0.55, 0.40),
          Offset(0.43, 0.40),
          Offset(0.33, 0.45),
          Offset(0.28, 0.53),
          Offset(0.34, 0.61),
          Offset(0.46, 0.63),
          Offset(0.58, 0.66),
          Offset(0.66, 0.73),
          Offset(0.65, 0.81),
          Offset(0.55, 0.85),
          Offset(0.42, 0.85),
          Offset(0.31, 0.81),
          Offset(0.27, 0.74),
        ],
      ],
    ),
    _LetraTrazo(
      letra: 't',
      palabra: 'tigre',
      emoji: '🐯',
      trazos: [
        _linea(const Offset(0.45, 0.20), const Offset(0.45, 0.85), 10),
        _linea(const Offset(0.28, 0.45), const Offset(0.60, 0.45), 5),
      ],
    ),
    _LetraTrazo(
      letra: 'u',
      palabra: 'uva',
      emoji: '🍇',
      trazos: [
        _concat([
          _linea(const Offset(0.30, 0.45), const Offset(0.30, 0.67), 5),
          _arco(const Offset(0.45, 0.67), 0.15, 8, pi, 0),
          _linea(const Offset(0.60, 0.67), const Offset(0.60, 0.45), 5),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'v',
      palabra: 'vaca',
      emoji: '🐮',
      trazos: [
        _concat([
          _linea(const Offset(0.25, 0.45), const Offset(0.50, 0.85), 8),
          _linea(const Offset(0.50, 0.85), const Offset(0.75, 0.45), 8),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'w',
      palabra: 'wifi',
      emoji: '📶',
      trazos: [
        _concat([
          _linea(const Offset(0.12, 0.45), const Offset(0.30, 0.85), 6),
          _linea(const Offset(0.30, 0.85), const Offset(0.50, 0.55), 5),
          _linea(const Offset(0.50, 0.55), const Offset(0.70, 0.85), 5),
          _linea(const Offset(0.70, 0.85), const Offset(0.88, 0.45), 6),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'x',
      palabra: 'xilófono',
      emoji: '🎵',
      trazos: [
        _linea(const Offset(0.25, 0.45), const Offset(0.65, 0.85), 8),
        _linea(const Offset(0.65, 0.45), const Offset(0.25, 0.85), 8),
      ],
    ),
    _LetraTrazo(
      letra: 'y',
      palabra: 'yate',
      emoji: '⛵',
      trazos: [
        _linea(const Offset(0.25, 0.45), const Offset(0.50, 0.70), 6),
        _concat([
          _linea(const Offset(0.65, 0.45), const Offset(0.50, 0.70), 4),
          _linea(const Offset(0.50, 0.70), const Offset(0.30, 0.92), 5),
        ]),
      ],
    ),
    _LetraTrazo(
      letra: 'z',
      palabra: 'zorro',
      emoji: '🦊',
      trazos: [
        _concat([
          _linea(const Offset(0.25, 0.45), const Offset(0.65, 0.45), 5),
          _linea(const Offset(0.65, 0.45), const Offset(0.25, 0.85), 8),
          _linea(const Offset(0.25, 0.85), const Offset(0.65, 0.85), 5),
        ]),
      ],
    ),
  ];
}

// ===================================================================
// Tutorial: mano fantasma que se desliza por el primer trazo
// Solo aparece la PRIMERA vez que el niño entra al juego de Trazar.
// ===================================================================

class _ManoTutorial extends StatelessWidget {
  final AnimationController animacion;
  final List<Offset> puntos;
  final Size canvasSize;

  const _ManoTutorial({
    required this.animacion,
    required this.puntos,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animacion,
          builder: (context, _) {
            // El ciclo tiene una pausa al inicio y al final.
            // 0..0.15 → quieto en el primer punto
            // 0.15..0.85 → desliza por todos los puntos
            // 0.85..1.0 → quieto al final
            final t = animacion.value;
            final double progreso;
            if (t < 0.15) {
              progreso = 0.0;
            } else if (t < 0.85) {
              progreso = (t - 0.15) / 0.70;
            } else {
              progreso = 1.0;
            }
            // Interpolar entre los puntos del trazo
            final n = puntos.length;
            final pos = progreso * (n - 1);
            final i = pos.floor().clamp(0, n - 1);
            final f = (pos - i).clamp(0.0, 1.0);
            final a = puntos[i];
            final b = puntos[i + 1 < n ? i + 1 : i];
            final lado = canvasSize.width < canvasSize.height
                ? canvasSize.width
                : canvasSize.height;
            final escala = lado * 0.92;
            final ox = (canvasSize.width - escala) / 2;
            final oy = (canvasSize.height - escala) / 2;
            final px = ox + (a.dx + (b.dx - a.dx) * f) * escala;
            final py = oy + (a.dy + (b.dy - a.dy) * f) * escala;

            // Fade in al inicio + un anillo halo
            final opacidad = (t < 0.05 ? t / 0.05 : 1.0).clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned(
                  left: px - 24,
                  top: py - 24,
                  child: Opacity(
                    opacity: opacidad,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x44FFFFFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: px - 18,
                  top: py - 6,
                  child: Opacity(
                    opacity: opacidad,
                    child: const Text(
                      '👆',
                      style: TextStyle(
                        fontSize: 48,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
