import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

enum _Forma { circulo, cuadrado, triangulo, estrella, corazon, rombo, rectangulo, ovalo }

class FormasScreen extends StatefulWidget {
  const FormasScreen({super.key});

  @override
  State<FormasScreen> createState() => _FormasScreenState();
}

class _FormaItem {
  final _Forma forma;
  final String clave;
  final String nombre;
  final Color color;
  const _FormaItem(this.forma, this.clave, this.nombre, this.color);
}

class _FormasScreenState extends State<FormasScreen> {
  static const _items = [
    _FormaItem(_Forma.circulo, 'circulo', 'Círculo', Color(0xFFEF4444)),
    _FormaItem(_Forma.cuadrado, 'cuadrado', 'Cuadrado', Color(0xFF3B82F6)),
    _FormaItem(_Forma.triangulo, 'triangulo', 'Triángulo', Color(0xFF22C55E)),
    _FormaItem(_Forma.estrella, 'estrella', 'Estrella', Color(0xFFFCD34D)),
    _FormaItem(_Forma.corazon, 'corazon', 'Corazón', Color(0xFFEC4899)),
    _FormaItem(_Forma.rombo, 'rombo', 'Rombo', Color(0xFFA855F7)),
    _FormaItem(_Forma.rectangulo, 'rectangulo', 'Rectángulo', Color(0xFFFB923C)),
    _FormaItem(_Forma.ovalo, 'ovalo', 'Óvalo', Color(0xFF42C8E2)),
  ];

  _FormaItem? _seleccionada;

  Future<void> _tocar(_FormaItem f) async {
    setState(() => _seleccionada = f);
    await AudioService.instancia.forma(f.clave, f.nombre);
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Formas',
      categoria: 'aprender_formas',
      color: const Color(0xFF22C55E),
      simbolosTema: const ['●', '■', '▲'],
      audioInstruccion: 'instr_formas',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const Text(
              'Toca una forma para escucharla',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            if (_seleccionada != null) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: sombraSuave,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: _FormaPainter(
                          forma: _seleccionada!.forma,
                          color: _seleccionada!.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        _seleccionada!.nombre,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: KidsColors.texto,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _tocar(_seleccionada!),
                      icon: Icon(Icons.volume_up_rounded,
                          size: 34, color: _seleccionada!.color),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final f = _items[i];
                  final activa = _seleccionada?.clave == f.clave;
                  return GestureDetector(
                    onTap: () => _tocar(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: activa ? f.color : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: activa ? sombraTarjeta : sombraSuave,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: CustomPaint(
                                painter: _FormaPainter(
                                  forma: f.forma,
                                  color: f.color,
                                ),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              f.nombre,
                              style: const TextStyle(
                                fontFamily: kFuente,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: KidsColors.texto,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _FormaPainter extends CustomPainter {
  final _Forma forma;
  final Color color;
  _FormaPainter({required this.forma, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = (w < h ? w : h) * 0.4;

    switch (forma) {
      case _Forma.circulo:
        canvas.drawCircle(Offset(cx, cy), r, paint);
      case _Forma.cuadrado:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
            const Radius.circular(8),
          ),
          paint,
        );
      case _Forma.rectangulo:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: r * 2.4, height: r * 1.3),
            const Radius.circular(8),
          ),
          paint,
        );
      case _Forma.triangulo:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx - r, cy + r * 0.8)
          ..lineTo(cx + r, cy + r * 0.8)
          ..close();
        canvas.drawPath(path, paint);
      case _Forma.estrella:
        final path = Path();
        for (var i = 0; i < 10; i++) {
          final ang = -pi / 2 + i * pi / 5;
          final rad = i.isEven ? r : r * 0.5;
          final x = cx + rad * cos(ang);
          final y = cy + rad * sin(ang);
          i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        path.close();
        canvas.drawPath(path, paint);
      case _Forma.corazon:
        final path = Path()
          ..moveTo(cx, cy + r * 0.8)
          ..cubicTo(cx + r * 1.4, cy + r * 0.1, cx + r * 0.7, cy - r * 0.9,
              cx, cy - r * 0.2)
          ..cubicTo(cx - r * 0.7, cy - r * 0.9, cx - r * 1.4, cy + r * 0.1,
              cx, cy + r * 0.8)
          ..close();
        canvas.drawPath(path, paint);
      case _Forma.rombo:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.85, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.85, cy)
          ..close();
        canvas.drawPath(path, paint);
      case _Forma.ovalo:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, cy), width: r * 2.2, height: r * 1.5),
          paint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _FormaPainter old) =>
      old.forma != forma || old.color != color;
}
