import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class FormaPalabrasScreen extends StatefulWidget {
  const FormaPalabrasScreen({super.key});

  @override
  State<FormaPalabrasScreen> createState() => _FormaPalabrasScreenState();
}

class _Palabra {
  final String palabra;
  final String emoji;
  const _Palabra(this.palabra, this.emoji);
  int get longitud => palabra.length;
}

class _FormaPalabrasScreenState extends State<FormaPalabrasScreen>
    with SingleTickerProviderStateMixin {
  static const _color = Color(0xFFE94B86);

  // 3 letras
  static const _faciles = <_Palabra>[
    _Palabra('SOL', '🌞'),
    _Palabra('UVA', '🍇'),
    _Palabra('OSO', '🐻'),
    _Palabra('PEZ', '🐟'),
  ];

  // 4 letras
  static const _medias = <_Palabra>[
    _Palabra('LUNA', '🌙'),
    _Palabra('TACO', '🌮'),
    _Palabra('GATO', '🐱'),
    _Palabra('ROSA', '🌹'),
    _Palabra('FLOR', '🌺'),
    _Palabra('CASA', '🏠'),
    _Palabra('LEON', '🦁'),
    _Palabra('VACA', '🐮'),
    _Palabra('PATO', '🐥'),
    _Palabra('RANA', '🐸'),
  ];

  // 5-6 letras
  static const _dificiles = <_Palabra>[
    _Palabra('TIGRE', '🐯'),
    _Palabra('PIZZA', '🍕'),
    _Palabra('FRESA', '🍓'),
    _Palabra('KOALA', '🐨'),
    _Palabra('ZORRO', '🦊'),
    _Palabra('BANANA', '🍌'),
    _Palabra('CONEJO', '🐰'),
    _Palabra('HELADO', '🍦'),
    _Palabra('JIRAFA', '🦒'),
  ];

  final _rng = Random();
  late _Palabra _palabraActual;
  late List<String> _letrasRevueltas;
  late List<bool> _letrasUsadas;
  late List<String?> _slots;
  String? _palabraPrevia;
  int? _tileIncorrecto;

  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 900), _decirPalabra);
    });
  }

  @override
  void dispose() {
    _shake.dispose();
    AudioService.instancia.detener();
    super.dispose();
  }

  List<_Palabra> _poolDeEdad() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    if (d.esPreescolar) return _faciles;
    if (d.esBasica) return [..._faciles, ..._medias];
    return [..._faciles, ..._medias, ..._dificiles];
  }

  void _nuevaRonda() {
    final pool = _poolDeEdad();
    var intentos = 0;
    do {
      _palabraActual = pool[_rng.nextInt(pool.length)];
      intentos++;
    } while (_palabraActual.palabra == _palabraPrevia && intentos < 5);
    _palabraPrevia = _palabraActual.palabra;

    _letrasRevueltas = _palabraActual.palabra.split('');
    // Asegurar que el orden inicial NO sea el correcto
    if (_letrasRevueltas.length > 1) {
      var tries = 0;
      do {
        _letrasRevueltas.shuffle(_rng);
        tries++;
      } while (_letrasRevueltas.join() == _palabraActual.palabra && tries < 8);
    }
    _letrasUsadas = List.filled(_letrasRevueltas.length, false);
    _slots = List.filled(_palabraActual.longitud, null);
    _tileIncorrecto = null;
  }

  void _decirPalabra() {
    AudioService.instancia.hablar(_palabraActual.palabra.toLowerCase());
  }

  int get _siguienteSlot {
    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i] == null) return i;
    }
    return _slots.length;
  }

  Future<void> _tocarLetra(int idx) async {
    if (_letrasUsadas[idx]) return;
    final slotIdx = _siguienteSlot;
    if (slotIdx >= _slots.length) return;

    final letraEsperada = _palabraActual.palabra[slotIdx];
    final letraTile = _letrasRevueltas[idx];

    if (letraTile == letraEsperada) {
      setState(() {
        _slots[slotIdx] = letraTile;
        _letrasUsadas[idx] = true;
        _tileIncorrecto = null;
      });
      AudioService.instancia.letra(letraTile);
      if (slotIdx == _slots.length - 1) {
        await _completar();
      }
    } else {
      setState(() => _tileIncorrecto = idx);
      _shake.forward(from: 0);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _tileIncorrecto = null);
    }
  }

  void _quitarUltima() {
    final ultimoIdx = _slots.lastIndexWhere((s) => s != null);
    if (ultimoIdx < 0) return;
    final letra = _slots[ultimoIdx]!;
    setState(() {
      _slots[ultimoIdx] = null;
      // marcar como no usado el primer tile no usado que tenga esa letra
      for (var i = 0; i < _letrasRevueltas.length; i++) {
        if (_letrasUsadas[i] && _letrasRevueltas[i] == letra) {
          _letrasUsadas[i] = false;
          break;
        }
      }
    });
  }

  Future<void> _completar() async {
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('lectura');
    AudioService.instancia.celebrarYDecir(_palabraActual.palabra.toLowerCase());
    await mostrarCelebracion(
      context,
      subtitulo: '¡Formaste ${_palabraActual.palabra}!',
    );
    if (!mounted) return;
    setState(_nuevaRonda);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _decirPalabra();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Nombre de la letra',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['A', 'B', 'C', 'a', 'b', 'c'],
      audioInstruccion: 'instr_forma_palabras',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final imagen = _TarjetaImagen(
            palabra: _palabraActual,
            color: _color,
            onTap: _decirPalabra,
            tamano: landscape ? 110 : 140,
          );

          final slots = _Slots(
            slots: _slots,
            color: _color,
            onTapSlot: _quitarUltima,
          );

          final tiles = _Tiles(
            letras: _letrasRevueltas,
            usadas: _letrasUsadas,
            color: _color,
            tileIncorrecto: _tileIncorrecto,
            shake: _shake,
            onTap: _tocarLetra,
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(child: Center(child: imagen)),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        slots,
                        const SizedBox(height: 18),
                        tiles,
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
                const _Pregunta(),
                const SizedBox(height: 8),
                imagen,
                const SizedBox(height: 14),
                slots,
                const SizedBox(height: 14),
                Expanded(child: Center(child: tiles)),
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
      'Forma la palabra del dibujo',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kFuente,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF333355),
      ),
    );
  }
}

class _TarjetaImagen extends StatelessWidget {
  final _Palabra palabra;
  final Color color;
  final VoidCallback onTap;
  final double tamano;

  const _TarjetaImagen({
    required this.palabra,
    required this.color,
    required this.onTap,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withValues(alpha: 0.30),
              width: 3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconKid(palabra.emoji, size: tamano, sombra: true),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.volume_up_rounded,
                    color: color, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slots extends StatelessWidget {
  final List<String?> slots;
  final Color color;
  final VoidCallback onTapSlot;

  const _Slots({
    required this.slots,
    required this.color,
    required this.onTapSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < slots.length; i++)
          _SlotCard(
            letra: slots[i],
            color: color,
            onTap: slots[i] != null ? onTapSlot : null,
          ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  final String? letra;
  final Color color;
  final VoidCallback? onTap;

  const _SlotCard({
    required this.letra,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lleno = letra != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 56,
        height: 64,
        decoration: BoxDecoration(
          gradient: lleno ? gradienteCategoria(color) : null,
          color: lleno ? null : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: lleno ? Colors.white : color.withValues(alpha: 0.45),
            width: lleno ? 3 : 3,
            style: lleno ? BorderStyle.solid : BorderStyle.solid,
          ),
          boxShadow: lleno ? sombraSuave : null,
        ),
        alignment: Alignment.center,
        child: Text(
          letra ?? '',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: lleno ? Colors.white : color,
            shadows: lleno
                ? const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  final List<String> letras;
  final List<bool> usadas;
  final Color color;
  final int? tileIncorrecto;
  final AnimationController shake;
  final ValueChanged<int> onTap;

  const _Tiles({
    required this.letras,
    required this.usadas,
    required this.color,
    required this.tileIncorrecto,
    required this.shake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < letras.length; i++)
          _TileLetra(
            letra: letras[i],
            usada: usadas[i],
            incorrecta: tileIncorrecto == i,
            color: color,
            shake: shake,
            onTap: () => onTap(i),
          ),
      ],
    );
  }
}

class _TileLetra extends StatelessWidget {
  final String letra;
  final bool usada;
  final bool incorrecta;
  final Color color;
  final AnimationController shake;
  final VoidCallback onTap;

  const _TileLetra({
    required this.letra,
    required this.usada,
    required this.incorrecta,
    required this.color,
    required this.shake,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shake,
      builder: (context, child) {
        final offsetX = incorrecta
            ? sin(shake.value * pi * 6) * 8.0
            : 0.0;
        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: child,
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: usada ? 0.25 : 1.0,
        child: GestureDetector(
          onTap: usada ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 62,
            height: 68,
            decoration: BoxDecoration(
              gradient: gradienteCategoria(
                  incorrecta ? KidsColors.error : color),
              borderRadius: BorderRadius.circular(18),
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
                fontSize: 36,
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
      ),
    );
  }
}
