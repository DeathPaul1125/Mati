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

  // Items que pueden aparecer en los caminos
  static const _items = [
    '🌳', '🌵', '🌹', '🌸', '🌺', '⭐', '🍄', '🌽', '🌱', '🐝', '🐝',
  ];

  // Casas en colores distintos para identificarlas
  static const _coloresCasa = [
    Color(0xFFFF8A65),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
  ];

  final _rng = Random();
  late List<List<String>> _caminos; // 3 caminos, cada uno con N items
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
    final cantidadItems = d.esPreescolar ? 2 : (d.esBasica ? 3 : 3);
    final cantidadCasas = d.esPreescolar ? 2 : 3;

    // Generar 3 (o 2) caminos con items DIFERENTES entre sí
    _caminos = [];
    final usados = <String>{};
    for (var i = 0; i < cantidadCasas; i++) {
      final disponibles = _items.where((it) => !usados.contains(it)).toList()
        ..shuffle(_rng);
      final camino = disponibles.take(cantidadItems).toList();
      usados.addAll(camino);
      _caminos.add(camino);
    }
    _rutaCorrecta = _rng.nextInt(cantidadCasas);
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
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            _PanelSecuencia(
              items: _caminos[_rutaCorrecta],
              color: _color,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sigue los dibujos y elige la casa',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: KidsColors.textoSuave,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _caminos.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _ColumnaCasa(
                        items: _caminos[i],
                        colorCasa: _coloresCasa[i % _coloresCasa.length],
                        incorrecta: _tocadaIncorrecta == 'casa_$i',
                        onTap: () => _elegir(i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelSecuencia extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _PanelSecuencia({required this.items, required this.color});

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
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, color: color, size: 24),
              const SizedBox(width: 4),
            ],
            IconKid(items[i], size: 40, sombra: true),
          ],
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, color: color, size: 24),
          const SizedBox(width: 4),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              '?',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnaCasa extends StatelessWidget {
  final List<String> items;
  final Color colorCasa;
  final bool incorrecta;
  final VoidCallback onTap;

  const _ColumnaCasa({
    required this.items,
    required this.colorCasa,
    required this.incorrecta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = incorrecta ? KidsColors.error : colorCasa;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c, width: 3),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Casa estilizada con CustomPaint
            SizedBox(
              width: 70,
              height: 70,
              child: CustomPaint(painter: _CasaPainter(color: colorCasa)),
            ),
            const SizedBox(height: 8),
            // Items del camino
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final it in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: IconKid(it, size: 42, sombra: true),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CasaPainter extends CustomPainter {
  final Color color;
  _CasaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Techo (triángulo)
    final techo = Path()
      ..moveTo(w * 0.10, h * 0.42)
      ..lineTo(w * 0.50, h * 0.05)
      ..lineTo(w * 0.90, h * 0.42)
      ..close();
    canvas.drawPath(techo, Paint()..color = color);

    // Cuerpo (rectángulo)
    final cuerpo = Rect.fromLTRB(w * 0.18, h * 0.40, w * 0.82, h * 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cuerpo, const Radius.circular(6)),
      Paint()..color = color.withValues(alpha: 0.85),
    );

    // Puerta
    final puerta = Rect.fromLTRB(w * 0.42, h * 0.65, w * 0.58, h * 0.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(puerta, const Radius.circular(4)),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );

    // Ventana
    final ventana = Rect.fromLTWH(w * 0.25, h * 0.50, w * 0.14, w * 0.14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ventana, const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _CasaPainter old) => old.color != color;
}
