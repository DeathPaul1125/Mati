import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class LogicaScreen extends StatefulWidget {
  const LogicaScreen({super.key});

  @override
  State<LogicaScreen> createState() => _LogicaScreenState();
}

class _Grupo {
  final String nombre;
  final List<String> miembros;
  const _Grupo(this.nombre, this.miembros);
}

class _LogicaScreenState extends State<LogicaScreen> {
  static const _grupos = <_Grupo>[
    _Grupo('frutas', ['🍎', '🍌', '🍇', '🍓', '🍊', '🍉', '🍒', '🥝']),
    _Grupo('animales', ['🐶', '🐱', '🐭', '🐻', '🐼', '🦊', '🐰', '🦁']),
    _Grupo('vehículos', ['🚗', '🚌', '🚜', '🚲', '✈️', '🚂', '🛵', '⛵']),
    _Grupo('comida', ['🍔', '🍕', '🌮', '🍣', '🍩', '🍪', '🍫', '🥪']),
    _Grupo('ropa', ['👕', '👖', '👗', '🧦', '👟', '🧢', '🧤', '🧥']),
    _Grupo('instrumentos', ['🎸', '🥁', '🎹', '🎺', '🎻', '🪕', '🪗', '🎷']),
  ];

  final _rng = Random();
  late List<String> _opciones;
  late String _intruso;
  String? _grupoPrincipalPrevio;
  bool _papeleraAbierta = false;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final n = d.logicaOpciones - 1;
    _Grupo principal;
    var intentos = 0;
    do {
      final indices = List<int>.generate(_grupos.length, (i) => i)
        ..shuffle(_rng);
      principal = _grupos[indices[0]];
      intentos++;
    } while (principal.nombre == _grupoPrincipalPrevio && intentos < 5);
    _grupoPrincipalPrevio = principal.nombre;

    final indicesOtro = List<int>.generate(_grupos.length, (i) => i)
        .where((i) => _grupos[i].nombre != principal.nombre)
        .toList()
      ..shuffle(_rng);
    final otro = _grupos[indicesOtro[0]];
    final miembros = ([...principal.miembros]..shuffle(_rng)).take(n).toList();
    _intruso = (otro.miembros.toList()..shuffle(_rng)).first;
    _opciones = [...miembros, _intruso]..shuffle(_rng);
  }

  Future<void> _acertar() async {
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('logica');
    setState(() => _papeleraAbierta = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await mostrarCelebracion(context);
    if (!mounted) return;
    setState(() {
      _papeleraAbierta = false;
      _nuevaRonda();
    });
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Lógica',
      categoria: 'logica',
      color: KidsColors.logica,
      simbolosTema: const ['?', '!', '✨', '💭'],
      audioInstruccion: 'instr_logica',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          // Columnas adaptativas según cuántos items haya y la orientación,
          // para garantizar que TODAS las opciones se vean sin recortar.
          int columnas;
          if (landscape) {
            columnas = _opciones.length <= 4 ? 2 : 3;
          } else {
            columnas = _opciones.length <= 4 ? 2 : 3;
          }
          final grid = GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: _opciones.length,
            itemBuilder: (context, i) {
              final item = _opciones[i];
              return _ItemArrastrable(
                item: item,
                onCancelado: () => mostrarErrorSuave(context),
              );
            },
          );

          final papelera = DragTarget<String>(
            onWillAcceptWithDetails: (d) => d.data == _intruso,
            onAcceptWithDetails: (_) => _acertar(),
            onMove: (_) {
              if (!_papeleraAbierta) {
                setState(() => _papeleraAbierta = true);
              }
            },
            onLeave: (_) => setState(() => _papeleraAbierta = false),
            builder: (context, candidate, rejected) {
              final activo = candidate.isNotEmpty || _papeleraAbierta;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: activo
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: activo ? KidsColors.logica : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    activo ? '🗑️ 😋' : '🗑️',
                    style: TextStyle(fontSize: landscape ? 56 : 44),
                  ),
                ),
              );
            },
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: grid),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Cuál es diferente?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF333355),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Arrástralo a la papelera',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF555577),
                          ),
                        ),
                        const SizedBox(height: 16),
                        papelera,
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
            child: Column(
              children: [
                const Text(
                  '¿Cuál es diferente?',
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333355),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Arrástralo a la papelera',
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF555577),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(child: grid),
                const SizedBox(height: 6),
                papelera,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemArrastrable extends StatelessWidget {
  final String item;
  final VoidCallback onCancelado;
  const _ItemArrastrable({required this.item, required this.onCancelado});

  @override
  Widget build(BuildContext context) {
    final card = LayoutBuilder(
      builder: (context, c) {
        final lado = min(c.maxWidth, c.maxHeight);
        return TarjetaGrande(
          padding: const EdgeInsets.all(6),
          child: IconKid(item, size: lado * 0.62, sombra: true),
        );
      },
    );
    return Draggable<String>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 120,
          height: 120,
          child: TarjetaGrande(
            padding: const EdgeInsets.all(6),
            child: IconKid(item, size: 84),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      onDraggableCanceled: (_, _) => onCancelado(),
      child: card,
    );
  }
}
