import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class LetraPerdidaScreen extends StatefulWidget {
  const LetraPerdidaScreen({super.key});

  @override
  State<LetraPerdidaScreen> createState() => _LetraPerdidaScreenState();
}

class _PalabraImg {
  final String emoji;
  final String palabra;
  const _PalabraImg(this.emoji, this.palabra);
}

class _LetraPerdidaScreenState extends State<LetraPerdidaScreen>
    with SingleTickerProviderStateMixin {
  static const _color = Color(0xFFEC4899);

  static const _palabras = <_PalabraImg>[
    _PalabraImg('🐱', 'GATO'),
    _PalabraImg('🌙', 'LUNA'),
    _PalabraImg('🌞', 'SOL'),
    _PalabraImg('🌹', 'ROSA'),
    _PalabraImg('🏠', 'CASA'),
    _PalabraImg('🌳', 'ARBOL'),
    _PalabraImg('🍌', 'BANANA'),
    _PalabraImg('🍎', 'MANZANA'),
    _PalabraImg('🍕', 'PIZZA'),
    _PalabraImg('🍦', 'HELADO'),
    _PalabraImg('🦁', 'LEON'),
    _PalabraImg('🐶', 'PERRO'),
    _PalabraImg('🐰', 'CONEJO'),
    _PalabraImg('🦒', 'JIRAFA'),
    _PalabraImg('🐮', 'VACA'),
    _PalabraImg('🌮', 'TACO'),
    _PalabraImg('🐸', 'RANA'),
    _PalabraImg('🍓', 'FRESA'),
    _PalabraImg('🍐', 'PERA'),
    _PalabraImg('🍋', 'LIMON'),
    _PalabraImg('🐝', 'ABEJA'),
    _PalabraImg('🦊', 'ZORRO'),
  ];

  final _rng = Random();
  late _PalabraImg _palabra;
  late int _idxPerdida;
  late List<String> _opciones;
  String? _palabraPrevia;
  String? _tocadaIncorrecta;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _nuevaRonda();
  }

  @override
  void dispose() {
    _shake.dispose();
    AudioService.instancia.detener();
    super.dispose();
  }

  void _nuevaRonda() {
    var intentos = 0;
    do {
      _palabra = _palabras[_rng.nextInt(_palabras.length)];
      intentos++;
    } while (_palabra.palabra == _palabraPrevia && intentos < 5);
    _palabraPrevia = _palabra.palabra;

    _idxPerdida = _rng.nextInt(_palabra.palabra.length);
    final correcta = _palabra.palabra[_idxPerdida];

    final pool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        .split('')
        .where((c) => c != correcta)
        .toList()
      ..shuffle(_rng);
    _opciones = [correcta, pool[0], pool[1]]..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  Future<void> _elegir(String letra) async {
    final correcta = _palabra.palabra[_idxPerdida];
    if (letra == correcta) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('lectura');
      AudioService.instancia.celebrarYDecir(_palabra.palabra.toLowerCase());
      await mostrarCelebracion(
        context,
        subtitulo: _palabra.palabra,
      );
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadaIncorrecta = letra);
      _shake.forward(from: 0);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Letra perdida',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['?', 'A', 'B', 'C'],
      audioInstruccion: 'instr_letra_perdida',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;
          final imagen = _TarjetaPalabra(
            palabra: _palabra,
            idxPerdida: _idxPerdida,
            color: _color,
            tamano: landscape ? 100 : 130,
          );

          final tiles = Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final l in _opciones)
                _TileLetra(
                  letra: l,
                  color: _color,
                  incorrecta: _tocadaIncorrecta == l,
                  shake: _shake,
                  onTap: () => _elegir(l),
                ),
            ],
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(child: Center(child: imagen)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: Center(child: tiles)),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                const Text(
                  '¿Qué letra falta?',
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333355),
                  ),
                ),
                const SizedBox(height: 8),
                imagen,
                const SizedBox(height: 18),
                Expanded(child: Center(child: tiles)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaPalabra extends StatelessWidget {
  final _PalabraImg palabra;
  final int idxPerdida;
  final Color color;
  final double tamano;
  const _TarjetaPalabra({
    required this.palabra,
    required this.idxPerdida,
    required this.color,
    required this.tamano,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 3),
        boxShadow: sombraTarjeta,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconKid(palabra.emoji, size: tamano, sombra: true),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            children: [
              for (var i = 0; i < palabra.palabra.length; i++)
                Container(
                  width: 34,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: i == idxPerdida
                        ? null
                        : gradienteCategoria(color),
                    color: i == idxPerdida ? Colors.white : null,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: i == idxPerdida
                          ? color.withValues(alpha: 0.45)
                          : Colors.white,
                      width: i == idxPerdida ? 3 : 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    i == idxPerdida ? '?' : palabra.palabra[i],
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: i == idxPerdida ? color : Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TileLetra extends StatelessWidget {
  final String letra;
  final Color color;
  final bool incorrecta;
  final AnimationController shake;
  final VoidCallback onTap;
  const _TileLetra({
    required this.letra,
    required this.color,
    required this.incorrecta,
    required this.shake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shake,
      builder: (context, child) {
        final dx = incorrecta ? sin(shake.value * pi * 6) * 8.0 : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 80,
          height: 90,
          decoration: BoxDecoration(
            gradient: gradienteCategoria(
                incorrecta ? KidsColors.error : color),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (incorrecta ? KidsColors.error : color)
                    .withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            letra,
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
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
    );
  }
}
