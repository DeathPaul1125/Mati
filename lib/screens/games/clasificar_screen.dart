import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class ClasificarScreen extends StatefulWidget {
  const ClasificarScreen({super.key});

  @override
  State<ClasificarScreen> createState() => _ClasificarScreenState();
}

class _Caja {
  final String etiqueta;
  final String emojiCaja;
  final Color color;
  final List<String> miembros;
  const _Caja(this.etiqueta, this.emojiCaja, this.color, this.miembros);
}

class _ClasificarScreenState extends State<ClasificarScreen> {
  static const _todasCajas = <_Caja>[
    _Caja('Frutas', '🧺', Color(0xFFE74C5C),
        ['🍎', '🍌', '🍇', '🍓', '🍊', '🍒']),
    _Caja('Animales', '🏠', Color(0xFF58C28E),
        ['🐶', '🐱', '🐭', '🐰', '🦊', '🐼']),
    _Caja('Vehículos', '🅿️', Color(0xFF4A90E2),
        ['🚗', '🚌', '🚲', '✈️', '🚂', '⛵']),
    _Caja('Ropa', '🧳', Color(0xFFF5A623),
        ['👕', '👖', '👗', '🧦', '👟', '🧢']),
  ];

  final _rng = Random();
  late List<_Caja> _cajasRonda;
  late List<_ItemRonda> _items;
  final Map<String, String> _colocados = {};

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final mezcladas = [..._todasCajas]..shuffle(_rng);
    _cajasRonda = mezcladas.take(d.clasificarCajas).toList();
    _items = [];
    for (final caja in _cajasRonda) {
      final muestra =
          ([...caja.miembros]..shuffle(_rng)).take(d.clasificarItemsPorCaja);
      for (final m in muestra) {
        _items.add(_ItemRonda(emoji: m, cajaCorrecta: caja.etiqueta));
      }
    }
    _items.shuffle(_rng);
    _colocados.clear();
  }

  Future<void> _colocar(_ItemRonda item, _Caja caja) async {
    if (item.cajaCorrecta != caja.etiqueta) {
      mostrarErrorSuave(context);
      return;
    }
    setState(() => _colocados[item.emoji] = caja.etiqueta);
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('clasificar');
    if (_colocados.length == _items.length) {
      await mostrarCelebracion(context, subtitulo: '¡Todo en su lugar!');
      if (!mounted) return;
      setState(_nuevaRonda);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Clasificar',
      categoria: 'clasificar',
      color: KidsColors.clasificar,
      simbolosTema: const ['📦', '✓', '⭐'],
      audioInstruccion: 'instr_clasificar',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final cajas = _cajasRonda
              .map((caja) => _CajaDestino(
                    caja: caja,
                    colocados: _colocados.entries
                        .where((e) => e.value == caja.etiqueta)
                        .map((e) => e.key)
                        .toList(),
                    onItem: (item) => _colocar(item, caja),
                  ))
              .toList();

          final items = _items
              .where((item) => !_colocados.containsKey(item.emoji))
              .map((item) => _ItemArrastrable(
                    item: item,
                    onCancelado: () => mostrarErrorSuave(context),
                  ))
              .toList();

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        alignment: WrapAlignment.center,
                        children: items,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Coloca cada cosa\nen su caja',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF333355),
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (final c in cajas)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: SizedBox(height: 140, child: c),
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
                  'Coloca cada cosa en su caja',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF333355),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Row(
                  children: cajas
                      .map((c) => Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: c,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: items,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemRonda {
  final String emoji;
  final String cajaCorrecta;
  _ItemRonda({required this.emoji, required this.cajaCorrecta});
}

class _CajaDestino extends StatelessWidget {
  final _Caja caja;
  final List<String> colocados;
  final void Function(_ItemRonda item) onItem;

  const _CajaDestino({
    required this.caja,
    required this.colocados,
    required this.onItem,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<_ItemRonda>(
      onWillAcceptWithDetails: (d) => d.data.cajaCorrecta == caja.etiqueta,
      onAcceptWithDetails: (d) => onItem(d.data),
      builder: (context, candidate, rejected) {
        final activo = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 150,
          decoration: BoxDecoration(
            gradient: gradienteCategoria(caja.color),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: activo ? Colors.white : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: caja.color.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  caja.etiqueta,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: colocados.isEmpty
                      ? IconKid(caja.emojiCaja, size: 70)
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: colocados
                              .map((e) => IconKid(e, size: 40))
                              .toList(),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ItemArrastrable extends StatelessWidget {
  final _ItemRonda item;
  final VoidCallback onCancelado;
  const _ItemArrastrable({required this.item, required this.onCancelado});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      alignment: Alignment.center,
      child: IconKid(item.emoji, size: 88, sombra: true),
    );
    return Draggable<_ItemRonda>(
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
