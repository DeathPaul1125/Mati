import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class SombrasScreen extends StatefulWidget {
  const SombrasScreen({super.key});

  @override
  State<SombrasScreen> createState() => _SombrasScreenState();
}

class _SombrasScreenState extends State<SombrasScreen> {
  static const _disponibles = [
    '🐶', '🐱', '🐰', '🐻', '🦊', '🐼', '🦁', '🐯',
    '🍎', '🍌', '🍇', '🍓', '🍕', '🍦', '🌮', '🌸',
    '🚗', '🚌', '🚲', '✈️', '⭐', '🌙', '🌞', '🌳',
  ];

  final _rng = Random();
  late List<String> _sombras;
  late List<String> _dibujos;
  final Set<String> _emparejados = {};

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    _sombras = ([..._disponibles]..shuffle(_rng)).take(d.sombrasItems).toList();
    // Los dibujos llevan otro orden distinto al de las sombras para que
    // el niño tenga que buscar a qué sombra corresponde cada uno.
    _dibujos = [..._sombras];
    if (_dibujos.length > 1) {
      var intentos = 0;
      do {
        _dibujos.shuffle(_rng);
        intentos++;
        // evitar el caso (raro) en que el shuffle deje todo en el mismo orden
      } while (_listasIguales(_dibujos, _sombras) && intentos < 8);
    }
    _emparejados.clear();
  }

  static bool _listasIguales(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _emparejar(String item) async {
    setState(() => _emparejados.add(item));
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('sombras');
    if (_emparejados.length == _sombras.length) {
      await mostrarCelebracion(context, subtitulo: '¡Encontraste todas!');
      if (!mounted) return;
      setState(_nuevaRonda);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Sombras',
      categoria: 'sombras',
      color: KidsColors.sombras,
      simbolosTema: const ['◐', '◑', '✦', '✧'],
      audioInstruccion: 'instr_sombras',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final sombras = _sombras
              .map((item) => _Sombra(
                    item: item,
                    emparejado: _emparejados.contains(item),
                    onMatch: () => _emparejar(item),
                  ))
              .toList();

          final dibujos = _dibujos
              .where((item) => !_emparejados.contains(item))
              .map((item) => _DibujoArrastrable(
                    item: item,
                    onCancelado: () => mostrarErrorSuave(context),
                  ))
              .toList();

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final s in sombras)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: s,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Encuentra la sombra',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF333355),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 14,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: dibujos,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                Text(
                  'Encuentra la sombra',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF333355),
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Arrastra cada dibujo a su sombra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF555577),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: sombras,
                ),
                const Spacer(),
                Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: dibujos,
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Sombra extends StatelessWidget {
  final String item;
  final bool emparejado;
  final VoidCallback onMatch;

  const _Sombra({
    required this.item,
    required this.emparejado,
    required this.onMatch,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data == item && !emparejado,
      onAcceptWithDetails: (_) => onMatch(),
      builder: (context, candidate, rejected) {
        final activo = candidate.isNotEmpty;
        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: activo ? 1.1 : 1.0,
          child: CustomPaint(
            painter: emparejado
                ? null
                : _MarcoSombraPainter(activo: activo),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: emparejado
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(22),
                boxShadow: emparejado
                    ? sombraTarjeta
                    : null,
              ),
              alignment: Alignment.center,
              child: emparejado
                  ? IconKid(item, size: 78, sombra: true)
                  : IconKidSilueta(item, size: 78),
            ),
          ),
        );
      },
    );
  }
}

class _MarcoSombraPainter extends CustomPainter {
  final bool activo;
  _MarcoSombraPainter({required this.activo});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = activo ? KidsColors.sombras : const Color(0xFF7080A0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(22),
    );
    final path = Path()..addRRect(rrect);
    const dash = 8.0;
    const gap = 6.0;
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      var distance = 0.0;
      while (distance < m.length) {
        canvas.drawPath(
          m.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarcoSombraPainter old) =>
      old.activo != activo;
}

class _DibujoArrastrable extends StatelessWidget {
  final String item;
  final VoidCallback onCancelado;
  const _DibujoArrastrable({required this.item, required this.onCancelado});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: IconKid(item, size: 78, sombra: true),
    );
    return Draggable<String>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.2, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      onDraggableCanceled: (_, _) => onCancelado(),
      child: card,
    );
  }
}
