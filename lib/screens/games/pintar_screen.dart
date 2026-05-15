import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

class PintarScreen extends StatefulWidget {
  const PintarScreen({super.key});

  @override
  State<PintarScreen> createState() => _PintarScreenState();
}

class _Trazo {
  final List<Offset> puntos;
  final Color color;
  final double grosor;
  _Trazo({required this.color, required this.grosor}) : puntos = [];
}

class _PintarScreenState extends State<PintarScreen> {
  static const _colores = [
    Color(0xFF000000),
    Color(0xFFFF4D4D),
    Color(0xFFFF9F45),
    Color(0xFFFFD93D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFB47BD8),
    Color(0xFFFF8FB1),
    Color(0xFF8B5E34),
  ];
  static const _grosores = [8.0, 16.0, 28.0];

  final List<_Trazo> _trazos = [];
  Color _colorActual = const Color(0xFFFF4D4D);
  double _grosorActual = 16.0;
  bool _esBorrador = false;

  Color get _colorTrazo =>
      _esBorrador ? Colors.white : _colorActual;

  void _empezar(Offset p) {
    setState(() {
      _trazos.add(_Trazo(color: _colorTrazo, grosor: _grosorActual)
        ..puntos.add(p));
    });
  }

  void _continuar(Offset p) {
    if (_trazos.isEmpty) return;
    setState(() => _trazos.last.puntos.add(p));
  }

  void _limpiar() {
    setState(_trazos.clear);
  }

  void _deshacer() {
    if (_trazos.isEmpty) return;
    setState(() => _trazos.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Pintar',
      categoria: 'pintar',
      color: const Color(0xFFE74C5C),
      audioInstruccion: 'instr_pintar',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: sombraTarjeta,
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onPanStart: (d) => _empezar(d.localPosition),
                  onPanUpdate: (d) => _continuar(d.localPosition),
                  child: CustomPaint(
                    painter: _LienzoPainter(_trazos),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: sombraSuave,
              ),
              child: Row(
                children: [
                  for (final c in _colores)
                    Expanded(
                      child: _BotonColor(
                        color: c,
                        seleccionado:
                            !_esBorrador && _colorActual == c,
                        onTap: () => setState(() {
                          _colorActual = c;
                          _esBorrador = false;
                        }),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final g in _grosores)
                  Expanded(
                    child: _BotonGrosor(
                      grosor: g,
                      seleccionado: _grosorActual == g,
                      onTap: () => setState(() => _grosorActual = g),
                    ),
                  ),
                _BotonAccion(
                  icono: Icons.cleaning_services_rounded,
                  etiqueta: 'Borra',
                  activo: _esBorrador,
                  color: const Color(0xFF7F8AA3),
                  onTap: () => setState(() => _esBorrador = !_esBorrador),
                ),
                _BotonAccion(
                  icono: Icons.undo_rounded,
                  etiqueta: 'Atrás',
                  color: const Color(0xFFFFAE3D),
                  onTap: _deshacer,
                ),
                _BotonAccion(
                  icono: Icons.delete_outline_rounded,
                  etiqueta: 'Limpiar',
                  color: const Color(0xFFFF6B7A),
                  onTap: _limpiar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LienzoPainter extends CustomPainter {
  final List<_Trazo> trazos;
  _LienzoPainter(this.trazos);

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in trazos) {
      final paint = Paint()
        ..color = t.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = t.grosor;
      if (t.puntos.length < 2) {
        canvas.drawCircle(t.puntos.first, t.grosor / 2,
            Paint()..color = t.color);
        continue;
      }
      final path = Path()..moveTo(t.puntos.first.dx, t.puntos.first.dy);
      for (var i = 1; i < t.puntos.length; i++) {
        path.lineTo(t.puntos[i].dx, t.puntos[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LienzoPainter old) =>
      old.trazos.length != trazos.length ||
      (trazos.isNotEmpty && old.trazos.isNotEmpty &&
          old.trazos.last.puntos.length != trazos.last.puntos.length);
}

class _BotonColor extends StatelessWidget {
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;
  const _BotonColor({
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: seleccionado ? 48 : 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? Colors.white : Colors.black12,
            width: 3,
          ),
          boxShadow: seleccionado ? sombraTarjeta : null,
        ),
      ),
    );
  }
}

class _BotonGrosor extends StatelessWidget {
  final double grosor;
  final bool seleccionado;
  final VoidCallback onTap;
  const _BotonGrosor({
    required this.grosor,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 52,
        decoration: BoxDecoration(
          color: seleccionado ? Colors.white : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionado ? const Color(0xFF5B8DEF) : Colors.transparent,
            width: 3,
          ),
          boxShadow: seleccionado ? sombraSuave : null,
        ),
        alignment: Alignment.center,
        child: Container(
          width: grosor,
          height: grosor,
          decoration: const BoxDecoration(
            color: KidsColors.texto,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final Color color;
  final bool activo;
  final VoidCallback onTap;

  const _BotonAccion({
    required this.icono,
    required this.etiqueta,
    required this.color,
    required this.onTap,
    this.activo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 52,
          decoration: BoxDecoration(
            color: activo ? color : color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: activo ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: sombraSuave,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, color: Colors.white, size: 22),
              Text(
                etiqueta,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
