import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class LeerPalabraScreen extends StatefulWidget {
  const LeerPalabraScreen({super.key});

  @override
  State<LeerPalabraScreen> createState() => _LeerPalabraScreenState();
}

class _Palabra {
  final String emoji;
  final String palabra;
  const _Palabra(this.emoji, this.palabra);
}

class _LeerPalabraScreenState extends State<LeerPalabraScreen> {
  static const _color = Color(0xFFF59E0B);

  static const _palabras = <_Palabra>[
    _Palabra('🌞', 'SOL'),
    _Palabra('🌙', 'LUNA'),
    _Palabra('🌹', 'ROSA'),
    _Palabra('🌺', 'FLOR'),
    _Palabra('🌳', 'ARBOL'),
    _Palabra('🌵', 'CACTUS'),
    _Palabra('🍎', 'MANZANA'),
    _Palabra('🍌', 'BANANA'),
    _Palabra('🍓', 'FRESA'),
    _Palabra('🍇', 'UVA'),
    _Palabra('🍕', 'PIZZA'),
    _Palabra('🌮', 'TACO'),
    _Palabra('🍦', 'HELADO'),
    _Palabra('🐱', 'GATO'),
    _Palabra('🐶', 'PERRO'),
    _Palabra('🐭', 'RATON'),
    _Palabra('🐰', 'CONEJO'),
    _Palabra('🐻', 'OSO'),
    _Palabra('🦁', 'LEON'),
    _Palabra('🦊', 'ZORRO'),
    _Palabra('🐯', 'TIGRE'),
    _Palabra('🐮', 'VACA'),
    _Palabra('🐘', 'ELEFANTE'),
    _Palabra('🦒', 'JIRAFA'),
    _Palabra('🐝', 'ABEJA'),
    _Palabra('🦋', 'MARIPOSA'),
    _Palabra('🐟', 'PEZ'),
    _Palabra('🐥', 'POLLITO'),
    _Palabra('🏠', 'CASA'),
  ];

  final _rng = Random();
  late _Palabra _correcta;
  late List<_Palabra> _opciones;
  String? _palabraPrevia;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final cantidad = d.lecturaOpciones.clamp(2, 3);
    var intentos = 0;
    do {
      _correcta = _palabras[_rng.nextInt(_palabras.length)];
      intentos++;
    } while (_correcta.palabra == _palabraPrevia && intentos < 5);
    _palabraPrevia = _correcta.palabra;

    final usadas = <String>{_correcta.palabra};
    final opciones = <_Palabra>[_correcta];
    while (opciones.length < cantidad) {
      final candidata = _palabras[_rng.nextInt(_palabras.length)];
      if (usadas.add(candidata.palabra)) opciones.add(candidata);
    }
    opciones.shuffle(_rng);
    _opciones = opciones;
    _tocadaIncorrecta = null;
  }

  Future<void> _elegir(_Palabra elegida) async {
    if (elegida.palabra == _correcta.palabra) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('lectura');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo: 'Se lee "${_correcta.palabra}"',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadaIncorrecta = elegida.palabra);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Leer',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['📖', '📚', 'A', 'a', 'B', 'b'],
      audioInstruccion: 'instr_leer_palabra',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;
          final imagen = TarjetaGrande(
            color: Colors.white,
            child: IconKid(
              _correcta.emoji,
              size: landscape ? 150 : 190,
              sombra: true,
            ),
          );

          final opciones = _opciones
              .map((p) => _BotonPalabra(
                    palabra: p.palabra,
                    color: _color,
                    incorrecta: _tocadaIncorrecta == p.palabra,
                    onTap: () => _elegir(p),
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
                        const _Pregunta(),
                        const SizedBox(height: 14),
                        for (final b in opciones)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: b,
                          ),
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
                const SizedBox(height: 10),
                Expanded(child: imagen),
                const SizedBox(height: 14),
                for (final b in opciones)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: b,
                  ),
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
    return Text(
      '¿Qué palabra es?',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: const Color(0xFF333355),
          ),
    );
  }
}

class _BotonPalabra extends StatelessWidget {
  final String palabra;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;

  const _BotonPalabra({
    required this.palabra,
    required this.color,
    required this.incorrecta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: incorrecta
            ? [
                BoxShadow(
                  color: KidsColors.error.withValues(alpha: 0.55),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : sombraTarjeta,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              gradient: incorrecta
                  ? gradienteCategoria(KidsColors.error)
                  : gradienteCategoria(color),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 68,
                minWidth: 220,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              child: Text(
                palabra,
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
