import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class RimasScreen extends StatefulWidget {
  const RimasScreen({super.key});

  @override
  State<RimasScreen> createState() => _RimasScreenState();
}

class _PalabraRima {
  final String emoji;
  final String palabra;
  final String familia; // sufijo común
  const _PalabraRima(this.emoji, this.palabra, this.familia);
}

class _RimasScreenState extends State<RimasScreen> {
  static const _color = Color(0xFF8B5CF6);

  static const _palabras = <_PalabraRima>[
    // Familia ON
    _PalabraRima('🦁', 'LEÓN', 'ON'),
    _PalabraRima('🐭', 'RATÓN', 'ON'),
    _PalabraRima('🍋', 'LIMÓN', 'ON'),
    // Familia ANA
    _PalabraRima('🐸', 'RANA', 'ANA'),
    _PalabraRima('🍎', 'MANZANA', 'ANA'),
    _PalabraRima('🍌', 'BANANA', 'ANA'),
    // Familia OSA
    _PalabraRima('🌹', 'ROSA', 'OSA'),
    _PalabraRima('🦋', 'MARIPOSA', 'OSA'),
    // Familia ESA
    _PalabraRima('🍓', 'FRESA', 'ESA'),
    // Familia ATO (limitado a uno con icono)
    _PalabraRima('🐱', 'GATO', 'ATO'),
    _PalabraRima('🐯', 'TIGRE', 'IGRE'),
  ];

  final _rng = Random();
  late _PalabraRima _referencia;
  late _PalabraRima _correcta;
  late List<_PalabraRima> _opciones;
  String? _previa;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), _decirReferencia);
    });
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  void _nuevaRonda() {
    // Filtrar palabras cuya familia tenga al menos 2 miembros
    final familias = <String, List<_PalabraRima>>{};
    for (final p in _palabras) {
      familias.putIfAbsent(p.familia, () => []).add(p);
    }
    final conRimas = familias.entries.where((e) => e.value.length >= 2).toList();

    var intentos = 0;
    MapEntry<String, List<_PalabraRima>> familia;
    do {
      familia = conRimas[_rng.nextInt(conRimas.length)];
      _referencia = familia.value[_rng.nextInt(familia.value.length)];
      intentos++;
    } while (_referencia.palabra == _previa && intentos < 5);
    _previa = _referencia.palabra;

    // Rima correcta = otra de la misma familia
    final rimas = familia.value
        .where((p) => p.palabra != _referencia.palabra)
        .toList();
    _correcta = rimas[_rng.nextInt(rimas.length)];

    // Distractores: de otras familias
    final distractores = _palabras
        .where((p) => p.familia != _referencia.familia)
        .toList()
      ..shuffle(_rng);

    final opciones = <_PalabraRima>{_correcta};
    for (final d in distractores) {
      if (opciones.length >= 3) break;
      opciones.add(d);
    }
    _opciones = opciones.toList()..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  void _decirReferencia() {
    AudioService.instancia.hablar(
        '¿Cuál rima con ${_referencia.palabra.toLowerCase()}?');
  }

  Future<void> _elegir(_PalabraRima p) async {
    if (p.palabra == _correcta.palabra) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('lectura');
      AudioService.instancia.celebrarYDecir(
          '${_referencia.palabra.toLowerCase()} rima con ${_correcta.palabra.toLowerCase()}');
      await mostrarCelebracion(
        context,
        subtitulo:
            '${_referencia.palabra} rima con ${_correcta.palabra}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _decirReferencia();
    } else {
      setState(() => _tocadaIncorrecta = p.palabra);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Rimas',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['♪', '♬'],
      audioInstruccion: 'instr_rimas',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final ref = _TarjetaReferencia(
            palabra: _referencia,
            color: _color,
            onRepetir: _decirReferencia,
            tamano: landscape ? 100 : 130,
          );

          final opciones = Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in _opciones)
                _TarjetaOpcion(
                  palabra: p,
                  color: _color,
                  incorrecta: _tocadaIncorrecta == p.palabra,
                  onTap: () => _elegir(p),
                ),
            ],
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(child: Center(child: ref)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: Center(child: opciones)),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                const Text(
                  '¿Cuál rima?',
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333355),
                  ),
                ),
                const SizedBox(height: 8),
                ref,
                const SizedBox(height: 14),
                Expanded(child: Center(child: opciones)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaReferencia extends StatelessWidget {
  final _PalabraRima palabra;
  final Color color;
  final VoidCallback onRepetir;
  final double tamano;
  const _TarjetaReferencia({
    required this.palabra,
    required this.color,
    required this.onRepetir,
    required this.tamano,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        onTap: onRepetir,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconKid(palabra.emoji, size: tamano, sombra: true),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    palabra.palabra,
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.volume_up_rounded, color: color, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final _PalabraRima palabra;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _TarjetaOpcion({
    required this.palabra,
    required this.color,
    required this.incorrecta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = incorrecta ? KidsColors.error : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            IconKid(palabra.emoji, size: 70, sombra: true),
            const SizedBox(height: 4),
            Text(
              palabra.palabra,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
