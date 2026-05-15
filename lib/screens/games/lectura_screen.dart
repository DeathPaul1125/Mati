import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class LecturaScreen extends StatefulWidget {
  const LecturaScreen({super.key});

  @override
  State<LecturaScreen> createState() => _LecturaScreenState();
}

class _Palabra {
  final String emoji;
  final String palabra;
  const _Palabra(this.emoji, this.palabra);
  String get inicial => palabra[0].toUpperCase();
}

class _LecturaScreenState extends State<LecturaScreen> {
  static const _palabras = <_Palabra>[
    _Palabra('🌳', 'Arbol'),
    _Palabra('🐝', 'Bicho'),
    _Palabra('🐶', 'Cachorro'),
    _Palabra('🐘', 'Elefante'),
    _Palabra('🍓', 'Fresa'),
    _Palabra('🌞', 'Sol'),
    _Palabra('🌮', 'Taco'),
    _Palabra('🍇', 'Uva'),
    _Palabra('🌹', 'Rosa'),
    _Palabra('🍌', 'Banana'),
    _Palabra('🐱', 'Gato'),
    _Palabra('🏠', 'Hogar'),
    _Palabra('🍦', 'Helado'),
    _Palabra('🦁', 'Leon'),
    _Palabra('🌙', 'Luna'),
    _Palabra('🍕', 'Pizza'),
    _Palabra('🌵', 'Cactus'),
    _Palabra('🦋', 'Mariposa'),
    _Palabra('🐭', 'Raton'),
    _Palabra('🌺', 'Flor'),
  ];

  final _rng = Random();
  late _Palabra _correcta;
  late List<String> _opcionesLetras;
  String? _inicialPrevia;

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
      _correcta = _palabras[_rng.nextInt(_palabras.length)];
      intentos++;
    } while (_correcta.inicial == _inicialPrevia && intentos < 5);
    _inicialPrevia = _correcta.inicial;
    final letras = <String>{_correcta.inicial};
    while (letras.length < d.lecturaOpciones) {
      letras.add(_palabras[_rng.nextInt(_palabras.length)].inicial);
    }
    _opcionesLetras = letras.toList()..shuffle(_rng);
  }

  Future<void> _acertar() async {
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('lectura');
    await mostrarCelebracion(
      context,
      subtitulo: '${_correcta.palabra} empieza con ${_correcta.inicial}',
    );
    if (!mounted) return;
    setState(_nuevaRonda);
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Letras',
      categoria: 'lectura',
      color: KidsColors.lectura,
      simbolosTema: const ['A', 'B', 'C', 'a', 'b', 'c', 'M', 'P', 'S'],
      audioInstruccion: 'instr_lectura',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;
          final imagen = DragTarget<String>(
            onWillAcceptWithDetails: (d) => d.data == _correcta.inicial,
            onAcceptWithDetails: (_) => _acertar(),
            builder: (context, candidate, rejected) {
              final activo = candidate.isNotEmpty;
              return AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: activo ? 1.04 : 1.0,
                child: TarjetaGrande(
                  color: activo
                      ? KidsColors.lectura.withValues(alpha: 0.18)
                      : Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconKid(_correcta.emoji,
                          size: landscape ? 130 : 170, sombra: true),
                      const SizedBox(height: 6),
                      Text(
                        _correcta.palabra,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF333355),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          final letras = _opcionesLetras
              .map((l) => _LetraArrastrable(
                    letra: l,
                    onCancelado: () => mostrarErrorSuave(context),
                  ))
              .toList();

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: imagen),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Con qué letra\nempieza?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: const Color(0xFF333355)),
                        ),
                        const SizedBox(height: 14),
                        ...letras.map((l) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: l,
                            )),
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
                Text(
                  '¿Con qué letra empieza?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF333355),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(child: imagen),
                const SizedBox(height: 12),
                const Text(
                  'Arrastra la letra correcta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF555577),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: letras,
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LetraArrastrable extends StatelessWidget {
  final String letra;
  final VoidCallback onCancelado;
  const _LetraArrastrable({required this.letra, required this.onCancelado});

  @override
  Widget build(BuildContext context) {
    final card = _CardLetra(letra: letra);
    return Draggable<String>(
      data: letra,
      feedback: _CardLetra(letra: letra, elevation: 12, scale: 1.15),
      childWhenDragging: Opacity(opacity: 0.35, child: card),
      onDraggableCanceled: (_, _) => onCancelado(),
      child: card,
    );
  }
}

class _CardLetra extends StatelessWidget {
  final String letra;
  final double elevation;
  final double scale;
  const _CardLetra({
    required this.letra,
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
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: gradienteCategoria(KidsColors.lectura),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            letra,
            style: const TextStyle(
              fontSize: 52,
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
