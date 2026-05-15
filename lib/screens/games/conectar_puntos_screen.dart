import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class ConectarPuntosScreen extends StatefulWidget {
  const ConectarPuntosScreen({super.key});

  @override
  State<ConectarPuntosScreen> createState() => _ConectarPuntosScreenState();
}

class _Dibujo {
  final String nombre;
  final String emojiRevela;
  final List<Offset> puntos; // orden de tap (1..N)
  final bool cerrado; // si la última debe unirse a la primera
  const _Dibujo(
    this.nombre,
    this.emojiRevela,
    this.puntos, {
    this.cerrado = true,
  });
}

class _ConectarPuntosScreenState extends State<ConectarPuntosScreen> {
  static const _color = Color(0xFFFF6B7A);

  // ===== Catálogo de figuras =====
  // Todas las coordenadas viven en [0.15..0.85] x [0.20..0.80] para que
  // los puntos NUNCA queden cortados ni pegados a los bordes.
  static final List<_Dibujo> _dibujosBase = [
    // Casa: rectángulo + techo
    _Dibujo('Casa', '🏠', const [
      Offset(0.25, 0.78),
      Offset(0.25, 0.45),
      Offset(0.50, 0.25),
      Offset(0.75, 0.45),
      Offset(0.75, 0.78),
    ]),
    // Estrella de 5 puntas (zigzag 1→3→5→2→4 sobre los 5 vértices)
    // Para verla como estrella el orden de tap es: arriba, abajo-derecha,
    // arriba-izquierda, arriba-derecha, abajo-izquierda → cerrar.
    _Dibujo('Estrella', '⭐', const [
      Offset(0.50, 0.22),
      Offset(0.73, 0.78),
      Offset(0.20, 0.45),
      Offset(0.80, 0.45),
      Offset(0.27, 0.78),
    ]),
    // Triángulo
    _Dibujo('Triángulo', '🍕', const [
      Offset(0.50, 0.25),
      Offset(0.22, 0.78),
      Offset(0.78, 0.78),
    ]),
    // Cuadrado
    _Dibujo('Cuadrado', '📦', const [
      Offset(0.25, 0.25),
      Offset(0.75, 0.25),
      Offset(0.75, 0.78),
      Offset(0.25, 0.78),
    ]),
    // Rombo / diamante
    _Dibujo('Rombo', '💎', const [
      Offset(0.50, 0.22),
      Offset(0.78, 0.50),
      Offset(0.50, 0.78),
      Offset(0.22, 0.50),
    ]),
    // Sol / octágono (8 puntos en círculo)
    _Dibujo('Sol', '🌞', [
      for (var i = 0; i < 8; i++)
        Offset(
          0.50 + 0.30 * cos(-pi / 2 + i * 2 * pi / 8),
          0.50 + 0.30 * sin(-pi / 2 + i * 2 * pi / 8),
        ),
    ]),
    // Pez: cuerpo (1-2-3-7) + cola (3-4-5-6) sin puntos duplicados
    _Dibujo('Pez', '🐟', const [
      Offset(0.18, 0.50),  // 1 mouth
      Offset(0.42, 0.28),  // 2 top body
      Offset(0.65, 0.40),  // 3 tail-junction top
      Offset(0.88, 0.25),  // 4 upper tail tip
      Offset(0.88, 0.75),  // 5 lower tail tip
      Offset(0.65, 0.60),  // 6 tail-junction bottom
      Offset(0.42, 0.72),  // 7 bottom body
    ], cerrado: true),
    // Flor / octágono regular (8 puntos bien espaciados)
    _Dibujo('Flor', '🌸', [
      for (var i = 0; i < 8; i++)
        Offset(
          0.50 + 0.32 * cos(-pi / 2 + i * 2 * pi / 8),
          0.50 + 0.32 * sin(-pi / 2 + i * 2 * pi / 8),
        ),
    ]),
    // Flecha hacia arriba (espaciado amplio para que ningún punto se superponga)
    _Dibujo('Flecha', '⬆', const [
      Offset(0.50, 0.18),  // 1 punta arriba
      Offset(0.18, 0.48),  // 2 punta izquierda del cabezal
      Offset(0.36, 0.48),  // 3 unión izquierda con el cuerpo
      Offset(0.36, 0.80),  // 4 esquina inferior izquierda del cuerpo
      Offset(0.64, 0.80),  // 5 esquina inferior derecha del cuerpo
      Offset(0.64, 0.48),  // 6 unión derecha con el cuerpo
      Offset(0.82, 0.48),  // 7 punta derecha del cabezal
    ]),
    // Cruz / signo más (brazos extendidos para evitar solapamientos)
    _Dibujo('Cruz', '➕', const [
      Offset(0.40, 0.15),  // 1 top-left
      Offset(0.60, 0.15),  // 2 top-right
      Offset(0.60, 0.40),  // 3 inner upper-right
      Offset(0.85, 0.40),  // 4 right-top
      Offset(0.85, 0.60),  // 5 right-bottom
      Offset(0.60, 0.60),  // 6 inner lower-right
      Offset(0.60, 0.85),  // 7 bottom-right
      Offset(0.40, 0.85),  // 8 bottom-left
      Offset(0.40, 0.60),  // 9 inner lower-left
      Offset(0.15, 0.60),  // 10 left-bottom
      Offset(0.15, 0.40),  // 11 left-top
      Offset(0.40, 0.40),  // 12 inner upper-left
    ]),
    // Barco: mástil + casco trapezoidal (sin puntos duplicados)
    _Dibujo('Barco', '⛵', const [
      Offset(0.50, 0.20),  // 1 punta del mástil
      Offset(0.50, 0.55),  // 2 base del mástil (centro)
      Offset(0.18, 0.55),  // 3 esquina superior izquierda del casco
      Offset(0.28, 0.82),  // 4 esquina inferior izquierda del casco
      Offset(0.72, 0.82),  // 5 esquina inferior derecha del casco
      Offset(0.82, 0.55),  // 6 esquina superior derecha del casco
    ], cerrado: false),
  ];

  // ===== Estado =====
  final _rng = Random();
  late List<_Dibujo> _dibujos; // copia mezclada
  int _idx = 0;
  int _siguienteNum = 1;
  String? _tocadoIncorrecto;
  bool _revelado = false;

  _Dibujo get _dibujo => _dibujos[_idx];

  @override
  void initState() {
    super.initState();
    _dibujos = [..._dibujosBase]..shuffle(_rng);
  }

  void _siguienteDibujo() {
    setState(() {
      _idx++;
      if (_idx >= _dibujos.length) {
        // re-mezclar al terminar el ciclo
        _dibujos = [..._dibujosBase]..shuffle(_rng);
        _idx = 0;
      }
      _siguienteNum = 1;
      _tocadoIncorrecto = null;
      _revelado = false;
    });
  }

  Future<void> _tocar(int num) async {
    if (_revelado) return;
    if (num == _siguienteNum) {
      setState(() => _siguienteNum++);
      AudioService.instancia.numero(num);
      if (_siguienteNum > _dibujo.puntos.length) {
        await _completar();
      }
    } else {
      setState(() => _tocadoIncorrecto = '$num');
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadoIncorrecto = null);
    }
  }

  Future<void> _completar() async {
    setState(() => _revelado = true);
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('motrices');
    AudioService.instancia.celebrarYDecir('¡Es ${_dibujo.nombre.toLowerCase()}!');
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await mostrarCelebracion(
      context,
      subtitulo: '¡Es ${_dibujo.nombre.toLowerCase()}!',
    );
    if (!mounted) return;
    _siguienteDibujo();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Conectar puntos',
      categoria: 'motrices',
      color: _color,
      simbolosTema: const ['1', '2', '3', '✦'],
      audioInstruccion: 'instr_conectar_puntos',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            Text(
              _revelado
                  ? '¡Es ${_dibujo.nombre}!'
                  : 'Toca los números del 1 al ${_dibujo.puntos.length} en orden',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  // Reservamos un pequeño margen interior para que los puntos
                  // nunca toquen el borde del cuadro blanco.
                  const margen = 18.0;
                  final usableW = c.maxWidth - margen * 2;
                  final usableH = c.maxHeight - margen * 2;
                  Offset px(Offset n) => Offset(
                        margen + n.dx * usableW,
                        margen + n.dy * usableH,
                      );

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: sombraTarjeta,
                      border: Border.all(
                          color: _color.withValues(alpha: 0.25), width: 3),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Líneas dibujadas
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LineasPainter(
                              puntos: _dibujo.puntos
                                  .map(px)
                                  .toList(),
                              conectados: _siguienteNum - 1,
                              cerrado: _dibujo.cerrado,
                              color: _color,
                            ),
                          ),
                        ),
                        // Emoji revelado en el centro
                        if (_revelado)
                          Center(
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.elasticOut,
                              scale: 1.0,
                              child: IconKid(
                                _dibujo.emojiRevela,
                                size: min(c.maxWidth, c.maxHeight) * 0.45,
                                sombra: true,
                              ),
                            ),
                          ),
                        // Puntos numerados
                        for (var i = 0; i < _dibujo.puntos.length; i++)
                          Positioned(
                            left: px(_dibujo.puntos[i]).dx - 28,
                            top: px(_dibujo.puntos[i]).dy - 28,
                            child: _Punto(
                              numero: i + 1,
                              conectado: (i + 1) < _siguienteNum,
                              esActual: (i + 1) == _siguienteNum && !_revelado,
                              incorrecto: _tocadoIncorrecto == '${i + 1}',
                              color: _color,
                              onTap: () => _tocar(i + 1),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  final int numero;
  final bool conectado;
  final bool esActual;
  final bool incorrecto;
  final Color color;
  final VoidCallback onTap;

  const _Punto({
    required this.numero,
    required this.conectado,
    required this.esActual,
    required this.incorrecto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = incorrecto ? KidsColors.error : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: conectado || esActual
              ? gradienteCategoria(c)
              : null,
          color: conectado || esActual ? null : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: esActual ? KidsColors.estrella : c,
            width: esActual ? 4 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.45),
              blurRadius: esActual ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '$numero',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: (conectado || esActual) ? Colors.white : c,
          ),
        ),
      ),
    );
  }
}

class _LineasPainter extends CustomPainter {
  final List<Offset> puntos; // ya en píxeles absolutos
  final int conectados;
  final bool cerrado;
  final Color color;

  _LineasPainter({
    required this.puntos,
    required this.conectados,
    required this.cerrado,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.isEmpty || conectados < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(puntos.first.dx, puntos.first.dy);
    for (var i = 1; i < conectados && i < puntos.length; i++) {
      path.lineTo(puntos[i].dx, puntos[i].dy);
    }
    // Si están todos conectados y la figura es cerrada, cerrar la línea
    if (conectados >= puntos.length && cerrado) {
      path.lineTo(puntos.first.dx, puntos.first.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineasPainter old) =>
      old.conectados != conectados ||
      old.puntos != puntos ||
      old.color != color ||
      old.cerrado != cerrado;
}
