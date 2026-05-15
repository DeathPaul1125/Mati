import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class CaminoSecuenciaScreen extends StatefulWidget {
  const CaminoSecuenciaScreen({super.key});

  @override
  State<CaminoSecuenciaScreen> createState() => _CaminoSecuenciaScreenState();
}

class _CaminoSecuenciaScreenState extends State<CaminoSecuenciaScreen> {
  static const _color = Color(0xFF22C55E);

  // Pool de items que decoran los caminos
  static const _itemsPool = [
    '🌳', '🌲', '🌵', '🌹', '🌸', '🌺', '⭐', '🍄', '🌽', '🌱', '🚩',
  ];

  // Colores de las 3 casas
  static const _coloresCasa = [
    Color(0xFFFF8A65),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
  ];

  // Posiciones X de las 3 columnas (normalizadas 0..1)
  static const _columnasX = [0.16, 0.50, 0.84];

  final _rng = Random();
  late List<List<String>> _caminos; // 3 caminos, items de abajo→arriba
  late int _rutaCorrecta;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final cantidadItems = d.esPreescolar ? 1 : 2;

    _caminos = [];
    final usados = <String>{};
    for (var i = 0; i < 3; i++) {
      final disp = _itemsPool.where((it) => !usados.contains(it)).toList()
        ..shuffle(_rng);
      final camino = disp.take(cantidadItems).toList();
      usados.addAll(camino);
      _caminos.add(camino);
    }
    _rutaCorrecta = _rng.nextInt(3);
    _tocadaIncorrecta = null;
  }

  Future<void> _elegir(int idx) async {
    if (idx == _rutaCorrecta) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('logica');
      AudioService.instancia.celebrarYDecir('¡Esa es la casa correcta!');
      await mostrarCelebracion(context, subtitulo: '¡Bien hecho!');
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadaIncorrecta = 'casa_$idx');
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Camino correcto',
      categoria: 'logica',
      color: _color,
      simbolosTema: const ['→', '?', '✦'],
      audioInstruccion: 'instr_camino_secuencia',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
        child: Column(
          children: [
            _PanelSecuencia(
              items: _caminos[_rutaCorrecta],
              colorCasa: _coloresCasa[_rutaCorrecta],
              color: _color,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _MapaCaminos(
                caminos: _caminos,
                coloresCasa: _coloresCasa,
                columnasX: _columnasX,
                tocadaIncorrecta: _tocadaIncorrecta,
                onTapCasa: _elegir,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Panel superior: secuencia "tronco → item → item → ?(casa)"
// ---------------------------------------------------------------------

class _PanelSecuencia extends StatelessWidget {
  final List<String> items;
  final Color colorCasa;
  final Color color;
  const _PanelSecuencia({
    required this.items,
    required this.colorCasa,
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
        border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tronco (inicio)
          const _Tronco(size: 40),
          for (final it in items) ...[
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, color: color, size: 22),
            const SizedBox(width: 6),
            IconKid(it, size: 38, sombra: true),
          ],
          const SizedBox(width: 6),
          Icon(Icons.arrow_forward_rounded, color: color, size: 22),
          const SizedBox(width: 6),
          // Casa con "?" (silueta del color correcto)
          _CasaIncognita(color: colorCasa.withValues(alpha: 0.55)),
        ],
      ),
    );
  }
}

class _CasaIncognita extends StatelessWidget {
  final Color color;
  const _CasaIncognita({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(44, 44),
            painter: _CasaPainter(
              color: color,
              soloContorno: true,
            ),
          ),
          Text(
            '?',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Mapa con el árbol de caminos
// ---------------------------------------------------------------------

class _MapaCaminos extends StatelessWidget {
  final List<List<String>> caminos;
  final List<Color> coloresCasa;
  final List<double> columnasX;
  final String? tocadaIncorrecta;
  final void Function(int) onTapCasa;

  const _MapaCaminos({
    required this.caminos,
    required this.coloresCasa,
    required this.columnasX,
    required this.tocadaIncorrecta,
    required this.onTapCasa,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;

        // Coordenadas clave (normalizadas):
        const yCasa = 0.13;
        const yEnchufeCasa = 0.30; // donde la rama vertical termina abajo
        const yBifurcacion = 0.62;  // donde las ramas se separan del tronco
        const yTronco = 0.92;       // donde está el tronco
        const xTronco = 0.50;

        // Posiciones items (2 por columna, a alturas distintas)
        final itemY = [0.45, 0.55];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFCFEBC1), // verde pasto
            borderRadius: BorderRadius.circular(24),
            boxShadow: sombraTarjeta,
            border: Border.all(
                color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Pinta el árbol de caminos (líneas marrones)
                CustomPaint(
                  size: Size(w, h),
                  painter: _RamasPainter(
                    columnasX: columnasX,
                    yTronco: yTronco,
                    yBifurcacion: yBifurcacion,
                    yEnchufeCasa: yEnchufeCasa,
                    xTronco: xTronco,
                  ),
                ),
                // Tronco abajo
                Positioned(
                  left: xTronco * w - 26,
                  top: yTronco * h - 30,
                  child: const _Tronco(size: 52),
                ),
                // Flecha arriba del tronco
                Positioned(
                  left: xTronco * w - 10,
                  top: yTronco * h - 56,
                  child: const Icon(Icons.arrow_upward_rounded,
                      size: 22, color: Color(0xFF7C4DFF)),
                ),
                // Items decorativos en cada columna
                for (var i = 0; i < caminos.length; i++)
                  for (var j = 0; j < caminos[i].length; j++)
                    Positioned(
                      left: columnasX[i] * w - 26,
                      top: itemY[j] * h - 26,
                      child: IconKid(caminos[i][j], size: 52, sombra: true),
                    ),
                // Casas arriba (clickeables)
                for (var i = 0; i < coloresCasa.length; i++)
                  Positioned(
                    left: columnasX[i] * w - 45,
                    top: yCasa * h - 45,
                    child: _CasaTap(
                      color: coloresCasa[i],
                      incorrecta: tocadaIncorrecta == 'casa_$i',
                      onTap: () => onTapCasa(i),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RamasPainter extends CustomPainter {
  final List<double> columnasX;
  final double yTronco;
  final double yBifurcacion;
  final double yEnchufeCasa;
  final double xTronco;

  _RamasPainter({
    required this.columnasX,
    required this.yTronco,
    required this.yBifurcacion,
    required this.yEnchufeCasa,
    required this.xTronco,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Tronco vertical: desde yTronco hasta yBifurcacion
    canvas.drawLine(
      Offset(xTronco * w, yTronco * h - 6),
      Offset(xTronco * w, yBifurcacion * h),
      paint,
    );

    // Desde el punto de bifurcación, ramas horizontales hacia cada columna
    for (final col in columnasX) {
      // Línea horizontal desde el tronco hasta la columna
      canvas.drawLine(
        Offset(xTronco * w, yBifurcacion * h),
        Offset(col * w, yBifurcacion * h),
        paint,
      );
      // Línea vertical desde la bifurcación hasta el "enchufe" de la casa
      canvas.drawLine(
        Offset(col * w, yBifurcacion * h),
        Offset(col * w, yEnchufeCasa * h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RamasPainter old) =>
      old.columnasX != columnasX ||
      old.yTronco != yTronco ||
      old.yBifurcacion != yBifurcacion ||
      old.yEnchufeCasa != yEnchufeCasa ||
      old.xTronco != xTronco;
}

// ---------------------------------------------------------------------
// Casa táctil (con CustomPaint)
// ---------------------------------------------------------------------

class _CasaTap extends StatelessWidget {
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;

  const _CasaTap({
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
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.45),
              blurRadius: incorrecta ? 14 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CustomPaint(painter: _CasaPainter(color: c)),
      ),
    );
  }
}

class _CasaPainter extends CustomPainter {
  final Color color;
  final bool soloContorno;
  _CasaPainter({required this.color, this.soloContorno = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cuerpoColor = soloContorno ? Colors.white : color.withValues(alpha: 0.92);
    final techoColor = soloContorno ? color : color;
    final bordeColor = soloContorno ? color : Color.lerp(color, Colors.black, 0.18)!;

    // Cuerpo (rectángulo)
    final cuerpo = Rect.fromLTRB(w * 0.16, h * 0.40, w * 0.84, h * 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuerpo, const Radius.circular(6)),
      Paint()..color = cuerpoColor,
    );
    if (soloContorno) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cuerpo, const Radius.circular(6)),
        Paint()
          ..color = bordeColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    // Techo (triángulo)
    final techo = Path()
      ..moveTo(w * 0.06, h * 0.42)
      ..lineTo(w * 0.50, h * 0.05)
      ..lineTo(w * 0.94, h * 0.42)
      ..close();
    canvas.drawPath(techo, Paint()..color = techoColor);

    if (!soloContorno) {
      // Chimenea
      final chim = Rect.fromLTWH(w * 0.70, h * 0.10, w * 0.10, h * 0.18);
      canvas.drawRect(chim, Paint()..color = Color.lerp(color, Colors.black, 0.12)!);

      // Puerta
      final puerta = Rect.fromLTRB(w * 0.42, h * 0.62, w * 0.58, h * 0.92);
      canvas.drawRRect(
        RRect.fromRectAndRadius(puerta, const Radius.circular(4)),
        Paint()..color = Color.lerp(color, Colors.black, 0.30)!,
      );
      // Ventanas
      final v1 = Rect.fromLTWH(w * 0.22, h * 0.50, w * 0.16, h * 0.16);
      final v2 = Rect.fromLTWH(w * 0.62, h * 0.50, w * 0.16, h * 0.16);
      final whitePaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
      canvas.drawRRect(
          RRect.fromRectAndRadius(v1, const Radius.circular(3)), whitePaint);
      canvas.drawRRect(
          RRect.fromRectAndRadius(v2, const Radius.circular(3)), whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CasaPainter old) =>
      old.color != color || old.soloContorno != soloContorno;
}

// ---------------------------------------------------------------------
// Pequeño tronco decorativo (se usa abajo del mapa y en la secuencia)
// ---------------------------------------------------------------------

class _Tronco extends StatelessWidget {
  final double size;
  const _Tronco({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TroncoPainter()),
    );
  }
}

class _TroncoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const marron = Color(0xFF8B5A2B);
    const marronClaro = Color(0xFFC18A55);

    // Cuerpo (rectángulo marrón)
    final cuerpo = Rect.fromLTWH(w * 0.18, h * 0.20, w * 0.64, h * 0.78);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuerpo, const Radius.circular(8)),
      Paint()..color = marron,
    );

    // Tope (elipse clara — anillos del tronco)
    final tope = Rect.fromLTWH(w * 0.15, h * 0.10, w * 0.70, h * 0.30);
    canvas.drawOval(tope, Paint()..color = marronClaro);
    // Anillo interior
    final anillo = Rect.fromLTWH(w * 0.32, h * 0.18, w * 0.36, h * 0.16);
    canvas.drawOval(
      anillo,
      Paint()
        ..color = marron
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    // Punto centro
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.26),
      w * 0.04,
      Paint()..color = marron,
    );

    // Rama lateral (pequeña)
    canvas.drawCircle(
      Offset(w * 0.16, h * 0.55),
      w * 0.10,
      Paint()..color = marron,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
