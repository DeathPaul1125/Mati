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
  final List<Offset> puntos; // en orden de 1 a N
  const _Dibujo(this.nombre, this.emojiRevela, this.puntos);
}

class _ConectarPuntosScreenState extends State<ConectarPuntosScreen> {
  static const _color = Color(0xFFFF6B7A);

  static final List<_Dibujo> _dibujos = [
    // Casa (5 puntos: cuadrado + techo)
    _Dibujo('Casa', '🏠', [
      const Offset(0.25, 0.80),
      const Offset(0.25, 0.45),
      const Offset(0.50, 0.20),
      const Offset(0.75, 0.45),
      const Offset(0.75, 0.80),
    ]),
    // Estrella (5 puntos)
    _Dibujo('Estrella', '⭐', [
      const Offset(0.50, 0.15),
      const Offset(0.62, 0.45),
      const Offset(0.92, 0.45),
      const Offset(0.68, 0.65),
      const Offset(0.78, 0.92),
    ]),
    // Sol (8 puntos en círculo)
    _Dibujo('Sol', '🌞', [
      const Offset(0.50, 0.15),
      const Offset(0.75, 0.25),
      const Offset(0.85, 0.50),
      const Offset(0.75, 0.75),
      const Offset(0.50, 0.85),
      const Offset(0.25, 0.75),
      const Offset(0.15, 0.50),
      const Offset(0.25, 0.25),
    ]),
    // Triángulo (3 puntos)
    _Dibujo('Triángulo', '🍕', [
      const Offset(0.50, 0.18),
      const Offset(0.18, 0.82),
      const Offset(0.82, 0.82),
    ]),
    // Pez (zigzag)
    _Dibujo('Pez', '🐟', [
      const Offset(0.20, 0.50),
      const Offset(0.45, 0.30),
      const Offset(0.70, 0.50),
      const Offset(0.45, 0.70),
      const Offset(0.20, 0.50),
      const Offset(0.05, 0.35),
      const Offset(0.05, 0.65),
    ]),
    // Corazón (6 puntos)
    _Dibujo('Corazón', '🌹', [
      const Offset(0.50, 0.88),
      const Offset(0.18, 0.55),
      const Offset(0.28, 0.25),
      const Offset(0.50, 0.40),
      const Offset(0.72, 0.25),
      const Offset(0.82, 0.55),
    ]),
  ];

  int _idx = 0;
  int _siguienteNum = 1;
  String? _tocadoIncorrecto;
  bool _revelado = false;

  _Dibujo get _dibujo => _dibujos[_idx];

  void _siguienteDibujo() {
    setState(() {
      _idx = (_idx + 1) % _dibujos.length;
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
    AudioService.instancia.muyBien();
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
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: sombraTarjeta,
                      border: Border.all(
                          color: _color.withValues(alpha: 0.25), width: 3),
                    ),
                    child: Stack(
                      children: [
                        // Líneas dibujadas
                        CustomPaint(
                          painter: _LineasPainter(
                            puntos: _dibujo.puntos,
                            conectados: _siguienteNum - 1,
                            color: _color,
                          ),
                          size: Size(c.maxWidth, c.maxHeight),
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
                                size: c.maxWidth * 0.4,
                                sombra: true,
                              ),
                            ),
                          ),
                        // Puntos numerados
                        for (var i = 0; i < _dibujo.puntos.length; i++)
                          Positioned(
                            left: _dibujo.puntos[i].dx * c.maxWidth - 28,
                            top: _dibujo.puntos[i].dy * c.maxHeight - 28,
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
              color: c.withValues(alpha: 0.35),
              blurRadius: esActual ? 12 : 6,
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
  final List<Offset> puntos;
  final int conectados;
  final Color color;

  _LineasPainter({
    required this.puntos,
    required this.conectados,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (puntos.isEmpty || conectados < 2) return;
    Offset px(Offset n) => Offset(n.dx * size.width, n.dy * size.height);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(px(puntos.first).dx, px(puntos.first).dy);
    for (var i = 1; i < conectados && i < puntos.length; i++) {
      path.lineTo(px(puntos[i]).dx, px(puntos[i]).dy);
    }
    // Si están todos conectados, cerrar la figura
    if (conectados >= puntos.length) {
      path.lineTo(px(puntos.first).dx, px(puntos.first).dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineasPainter old) =>
      old.conectados != conectados ||
      old.puntos != puntos ||
      old.color != color;
}
