import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class MatematicasScreen extends StatefulWidget {
  const MatematicasScreen({super.key});

  @override
  State<MatematicasScreen> createState() => _MatematicasScreenState();
}

class _MatematicasScreenState extends State<MatematicasScreen> {
  static const _emojisObjetos = ['🍎', '🎈', '⭐', '🐠', '🌸', '🦋', '🍓', '🐝', '🍒'];

  final _rng = Random();
  late int _cantidad;
  late String _emoji;
  late List<int> _opciones;
  int? _cantidadPrevia;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    var intentos = 0;
    do {
      _cantidad = d.matMin + _rng.nextInt(d.matMax);
      intentos++;
    } while (_cantidad == _cantidadPrevia && intentos < 5);
    _cantidadPrevia = _cantidad;
    _emoji = _emojisObjetos[_rng.nextInt(_emojisObjetos.length)];
    final opciones = <int>{_cantidad};
    while (opciones.length < d.matOpciones) {
      opciones.add(d.matMin + _rng.nextInt(d.matMax));
    }
    _opciones = opciones.toList()..shuffle(_rng);
  }

  Future<void> _acertar() async {
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('matematicas');
    await mostrarCelebracion(context);
    if (!mounted) return;
    setState(_nuevaRonda);
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Cuenta',
      categoria: 'matematicas',
      color: KidsColors.matematicas,
      simbolosTema: const ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
      audioInstruccion: 'instr_contar',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;
          final basket = DragTarget<int>(
            onWillAcceptWithDetails: (d) => d.data == _cantidad,
            onAcceptWithDetails: (_) => _acertar(),
            builder: (context, candidate, rejected) {
              final activo = candidate.isNotEmpty;
              return AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: activo ? 1.05 : 1.0,
                child: TarjetaGrande(
                  color: activo
                      ? KidsColors.matematicas.withValues(alpha: 0.15)
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        _cantidad,
                        (_) => IconKid(_emoji,
                            size: _cantidad <= 5
                                ? 100
                                : (_cantidad <= 10 ? 72 : 54),
                            sombra: true),
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          final opciones = _opciones
              .map((n) => _NumeroArrastrable(
                    numero: n,
                    onCancelado: () => mostrarErrorSuave(context),
                  ))
              .toList();

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: basket),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Cuántos hay?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: const Color(0xFF333355)),
                        ),
                        const SizedBox(height: 14),
                        ...opciones.map((o) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: o,
                            )),
                        const SizedBox(height: 12),
                        const Text(
                          'Arrastra el número correcto',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF555577),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Text(
                  '¿Cuántos hay?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF333355),
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(child: basket),
                const SizedBox(height: 16),
                const Text(
                  'Arrastra el número correcto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333355),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: opciones,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NumeroArrastrable extends StatelessWidget {
  final int numero;
  final VoidCallback onCancelado;
  const _NumeroArrastrable({required this.numero, required this.onCancelado});

  @override
  Widget build(BuildContext context) {
    final card = _CardNumero(numero: numero);
    return Draggable<int>(
      data: numero,
      feedback: _CardNumero(numero: numero, elevation: 12, scale: 1.15),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      onDraggableCanceled: (_, _) => onCancelado(),
      child: card,
    );
  }
}

class _CardNumero extends StatelessWidget {
  final int numero;
  final double elevation;
  final double scale;
  const _CardNumero({
    required this.numero,
    this.elevation = 6,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Material(
        color: Colors.transparent,
        elevation: elevation,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black54,
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            gradient: gradienteCategoria(KidsColors.matematicas),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            '$numero',
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
        ),
      ),
    );
  }
}
