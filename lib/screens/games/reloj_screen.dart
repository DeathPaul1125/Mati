import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

class RelojScreen extends StatefulWidget {
  const RelojScreen({super.key});

  @override
  State<RelojScreen> createState() => _RelojScreenState();
}

class _Hora {
  final int hora; // 1..12
  final int minutos; // 0 o 30
  const _Hora(this.hora, this.minutos);
  String format() {
    final m = minutos.toString().padLeft(2, '0');
    return '$hora:$m';
  }

  String enPalabras() {
    if (minutos == 0) {
      return hora == 1 ? 'la una en punto' : 'las $hora en punto';
    }
    return hora == 1 ? 'la una y media' : 'las $hora y media';
  }
}

class _RelojScreenState extends State<RelojScreen> {
  static const _color = Color(0xFF06B6D4);

  final _rng = Random();
  late _Hora _correcta;
  late List<_Hora> _opciones;
  String? _previa;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final permitirMedia = !d.esPreescolar;

    var intentos = 0;
    do {
      final h = 1 + _rng.nextInt(12);
      final m = permitirMedia && _rng.nextBool() ? 30 : 0;
      _correcta = _Hora(h, m);
      intentos++;
    } while (_correcta.format() == _previa && intentos < 5);
    _previa = _correcta.format();

    final candidatos = <_Hora>{_correcta};
    while (candidatos.length < 3) {
      final h = 1 + _rng.nextInt(12);
      final m = permitirMedia && _rng.nextBool() ? 30 : 0;
      candidatos.add(_Hora(h, m));
    }
    _opciones = candidatos.toList()..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  Future<void> _elegir(_Hora h) async {
    if (h.format() == _correcta.format()) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('reloj');
      AudioService.instancia.celebrarYDecir('Son ${_correcta.enPalabras()}');
      await mostrarCelebracion(
        context,
        subtitulo: 'Son ${_correcta.enPalabras()}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadaIncorrecta = h.format());
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Reloj',
      categoria: 'reloj',
      color: _color,
      simbolosTema: const ['🕐', '🕒', '🕕'],
      audioInstruccion: 'instr_reloj',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final reloj = AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: sombraTarjeta,
              ),
              padding: const EdgeInsets.all(12),
              child: CustomPaint(
                painter: _RelojPainter(
                  hora: _correcta.hora,
                  minutos: _correcta.minutos,
                  color: _color,
                ),
              ),
            ),
          );

          final opcionesWidget = Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final h in _opciones)
                _BotonHora(
                  hora: h,
                  color: _color,
                  incorrecta: _tocadaIncorrecta == h.format(),
                  onTap: () => _elegir(h),
                ),
            ],
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(child: Center(child: reloj)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _Pregunta(),
                        const SizedBox(height: 16),
                        opcionesWidget,
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                const _Pregunta(),
                const SizedBox(height: 8),
                Expanded(child: Center(child: reloj)),
                const SizedBox(height: 14),
                opcionesWidget,
                const SizedBox(height: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Pregunta extends StatelessWidget {
  const _Pregunta();
  @override
  Widget build(BuildContext context) {
    return const Text(
      '¿Qué hora es?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kFuente,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF333355),
      ),
    );
  }
}

class _BotonHora extends StatelessWidget {
  final _Hora hora;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _BotonHora({
    required this.hora,
    required this.color,
    required this.incorrecta,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final c = incorrecta ? KidsColors.error : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minWidth: 110, minHeight: 70),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.lerp(c, Colors.white, 0.25)!, c],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          hora.format(),
          style: const TextStyle(
            fontFamily: kFuente,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelojPainter extends CustomPainter {
  final int hora;
  final int minutos;
  final Color color;

  _RelojPainter({
    required this.hora,
    required this.minutos,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radio = min(size.width, size.height) / 2;

    // Anillo exterior
    final bordeAnillo = Paint()
      ..color = color
      ..strokeWidth = radio * 0.06
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radio - bordeAnillo.strokeWidth / 2, bordeAnillo);

    // Marcas de 12 horas
    final marcaPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = radio * 0.03
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final ang = -pi / 2 + i * pi / 6;
      final inner = i % 3 == 0 ? radio * 0.78 : radio * 0.82;
      final outer = radio * 0.88;
      canvas.drawLine(
        Offset(center.dx + cos(ang) * inner, center.dy + sin(ang) * inner),
        Offset(center.dx + cos(ang) * outer, center.dy + sin(ang) * outer),
        marcaPaint,
      );
    }

    // Números 1..12
    for (var i = 1; i <= 12; i++) {
      final ang = -pi / 2 + i * pi / 6;
      final r = radio * 0.66;
      final pos = Offset(center.dx + cos(ang) * r, center.dy + sin(ang) * r);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: radio * 0.20,
            fontWeight: FontWeight.w900,
            color: KidsColors.texto,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    // Aguja de horas (corta y gruesa)
    final horaAng =
        -pi / 2 + ((hora % 12) + minutos / 60) * pi / 6;
    final horaTip = Offset(
      center.dx + cos(horaAng) * radio * 0.46,
      center.dy + sin(horaAng) * radio * 0.46,
    );
    canvas.drawLine(
      center,
      horaTip,
      Paint()
        ..color = KidsColors.texto
        ..strokeWidth = radio * 0.08
        ..strokeCap = StrokeCap.round,
    );

    // Aguja de minutos (larga y más fina)
    final minAng = -pi / 2 + minutos * pi / 30;
    final minTip = Offset(
      center.dx + cos(minAng) * radio * 0.72,
      center.dy + sin(minAng) * radio * 0.72,
    );
    canvas.drawLine(
      center,
      minTip,
      Paint()
        ..color = color
        ..strokeWidth = radio * 0.05
        ..strokeCap = StrokeCap.round,
    );

    // Tornillo central
    canvas.drawCircle(
      center,
      radio * 0.06,
      Paint()..color = KidsColors.texto,
    );
    canvas.drawCircle(
      center,
      radio * 0.025,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _RelojPainter old) =>
      old.hora != hora || old.minutos != minutos || old.color != color;
}
