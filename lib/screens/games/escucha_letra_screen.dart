import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

class EscuchaLetraScreen extends StatefulWidget {
  const EscuchaLetraScreen({super.key});

  @override
  State<EscuchaLetraScreen> createState() => _EscuchaLetraScreenState();
}

class _LetraInfo {
  final String letra;
  final String palabra;
  const _LetraInfo(this.letra, this.palabra);
}

class _EscuchaLetraScreenState extends State<EscuchaLetraScreen> {
  static const _color = Color(0xFFFF6FA3);

  // Vocales primero (las más fáciles de identificar por sonido).
  static const _vocales = <_LetraInfo>[
    _LetraInfo('A', 'Árbol'),
    _LetraInfo('E', 'Elefante'),
    _LetraInfo('I', 'Iguana'),
    _LetraInfo('O', 'Oso'),
    _LetraInfo('U', 'Uva'),
  ];

  static const _consonantesBasicas = <_LetraInfo>[
    _LetraInfo('M', 'Mamá'),
    _LetraInfo('P', 'Papá'),
    _LetraInfo('S', 'Sol'),
    _LetraInfo('L', 'Luna'),
    _LetraInfo('T', 'Taco'),
    _LetraInfo('N', 'Nube'),
  ];

  static const _consonantesAvanzadas = <_LetraInfo>[
    _LetraInfo('B', 'Banana'),
    _LetraInfo('C', 'Casa'),
    _LetraInfo('D', 'Dulce'),
    _LetraInfo('F', 'Fresa'),
    _LetraInfo('G', 'Gato'),
    _LetraInfo('R', 'Ratón'),
  ];

  static const _coloresLetra = [
    Color(0xFFFF6B7A),
    Color(0xFF5B8DEF),
    Color(0xFF22C55E),
    Color(0xFFA855F7),
    Color(0xFFFFAE3D),
    Color(0xFF42C8E2),
  ];

  final _rng = Random();
  late _LetraInfo _correcta;
  late List<_LetraInfo> _opciones;
  String? _letraPrevia;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 900), _decirLetra);
    });
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  List<_LetraInfo> _letrasPosibles(Dificultad d) {
    if (d.esPreescolar) return _vocales;
    if (d.esBasica) return [..._vocales, ..._consonantesBasicas];
    return [..._vocales, ..._consonantesBasicas, ..._consonantesAvanzadas];
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final cantidad = d.lecturaOpciones.clamp(2, 3);
    final pool = _letrasPosibles(d);

    var intentos = 0;
    do {
      _correcta = pool[_rng.nextInt(pool.length)];
      intentos++;
    } while (_correcta.letra == _letraPrevia && intentos < 5);
    _letraPrevia = _correcta.letra;

    final usadas = <String>{_correcta.letra};
    final opciones = <_LetraInfo>[_correcta];
    while (opciones.length < cantidad) {
      final candidata = pool[_rng.nextInt(pool.length)];
      if (usadas.add(candidata.letra)) opciones.add(candidata);
    }
    opciones.shuffle(_rng);
    _opciones = opciones;
    _tocadaIncorrecta = null;
  }

  void _decirLetra() {
    AudioService.instancia.letra(_correcta.letra, palabraEjemplo: _correcta.palabra);
  }

  Future<void> _elegir(_LetraInfo elegida) async {
    if (elegida.letra == _correcta.letra) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('lectura');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo: '${_correcta.letra} de ${_correcta.palabra}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _decirLetra();
    } else {
      setState(() => _tocadaIncorrecta = elegida.letra);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
      _decirLetra();
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Escucha y toca',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['A', 'E', 'I', 'O', 'U', 'a', 'e', 'i', 'o', 'u'],
      audioInstruccion: 'instr_escucha_letra',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final boton = _BotonRepetir(
            color: _color,
            onTap: _decirLetra,
          );

          final cards = <Widget>[];
          for (var i = 0; i < _opciones.length; i++) {
            final l = _opciones[i];
            cards.add(_CardLetraGrande(
              letra: l.letra,
              color: _coloresLetra[i % _coloresLetra.length],
              incorrecta: _tocadaIncorrecta == l.letra,
              onTap: () => _elegir(l),
            ));
          }

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _Pregunta(),
                        const SizedBox(height: 16),
                        boton,
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: cards,
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
                boton,
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 18,
                      children: cards,
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

class _Pregunta extends StatelessWidget {
  const _Pregunta();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '¿Cuál letra escuchaste?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kFuente,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF333355),
      ),
    );
  }
}

class _BotonRepetir extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _BotonRepetir({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(36),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.volume_up_rounded, color: color, size: 32),
              const SizedBox(width: 10),
              Text(
                'Escuchar otra vez',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardLetraGrande extends StatelessWidget {
  final String letra;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;

  const _CardLetraGrande({
    required this.letra,
    required this.color,
    required this.incorrecta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorFinal = incorrecta ? KidsColors.error : color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: incorrecta
            ? [
                BoxShadow(
                  color: KidsColors.error.withValues(alpha: 0.55),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : sombraTarjeta,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradienteCategoria(colorFinal),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Container(
              width: 130,
              height: 130,
              alignment: Alignment.center,
              child: Text(
                letra,
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 88,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
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
