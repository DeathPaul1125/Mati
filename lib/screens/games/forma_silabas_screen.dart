import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class FormaSilabasScreen extends StatefulWidget {
  const FormaSilabasScreen({super.key});

  @override
  State<FormaSilabasScreen> createState() => _FormaSilabasScreenState();
}

class _PalabraSilabica {
  final String emoji;
  final List<String> silabas;
  const _PalabraSilabica(this.emoji, this.silabas);
  String get palabra => silabas.join();
}

class _FormaSilabasScreenState extends State<FormaSilabasScreen>
    with SingleTickerProviderStateMixin {
  static const _color = Color(0xFF7C4DFF);

  // 2 sílabas (preescolar)
  static const _faciles = <_PalabraSilabica>[
    _PalabraSilabica('🌙', ['LU', 'NA']),
    _PalabraSilabica('🐱', ['GA', 'TO']),
    _PalabraSilabica('🛵', ['MO', 'TO']),
    _PalabraSilabica('🐮', ['VA', 'CA']),
    _PalabraSilabica('🌮', ['TA', 'CO']),
    _PalabraSilabica('🏠', ['CA', 'SA']),
    _PalabraSilabica('🌹', ['RO', 'SA']),
    _PalabraSilabica('🐶', ['PE', 'RRO']),
  ];

  // 3 sílabas
  static const _medias = <_PalabraSilabica>[
    _PalabraSilabica('🍌', ['BA', 'NA', 'NA']),
    _PalabraSilabica('🐨', ['KO', 'A', 'LA']),
    _PalabraSilabica('🦒', ['JI', 'RA', 'FA']),
    _PalabraSilabica('🐥', ['PO', 'LLI', 'TO']),
    _PalabraSilabica('🦁', ['LE', 'O', 'N']),
  ];

  // 4 sílabas
  static const _dificiles = <_PalabraSilabica>[
    _PalabraSilabica('🦋', ['MA', 'RI', 'PO', 'SA']),
    _PalabraSilabica('🦎', ['LA', 'GAR', 'TO']),
  ];

  final _rng = Random();
  late _PalabraSilabica _palabra;
  late List<String> _silabasMezcla;
  late List<bool> _usadas;
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
  }

  @override
  void dispose() {
    _shake.dispose();
    AudioService.instancia.detener();
    super.dispose();
  }

  List<_PalabraSilabica> _pool() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    if (d.esPreescolar) return _faciles;
    if (d.esBasica) return [..._faciles, ..._medias];
    return [..._faciles, ..._medias, ..._dificiles];
  }

  void _nuevaRonda() {
    final pool = _pool();
    var intentos = 0;
    do {
      _palabra = pool[_rng.nextInt(pool.length)];
      intentos++;
    } while (_palabra.palabra == _palabraPrevia && intentos < 5);
    _palabraPrevia = _palabra.palabra;

    _silabasMezcla = [..._palabra.silabas];
    if (_silabasMezcla.length > 1) {
      var t = 0;
      do {
        _silabasMezcla.shuffle(_rng);
        t++;
      } while (
          _silabasMezcla.join() == _palabra.palabra && t < 8);
    }
    _usadas = List.filled(_silabasMezcla.length, false);
    _slots = List.filled(_palabra.silabas.length, null);
    _tileIncorrecto = null;
  }

  int get _slotSiguiente {
    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i] == null) return i;
    }
    return _slots.length;
  }

  Future<void> _tocar(int idx) async {
    if (_usadas[idx]) return;
    final slot = _slotSiguiente;
    if (slot >= _slots.length) return;
    final esperada = _palabra.silabas[slot];
    final tile = _silabasMezcla[idx];
    if (tile == esperada) {
      setState(() {
        _slots[slot] = tile;
        _usadas[idx] = true;
        _tileIncorrecto = null;
      });
      AudioService.instancia.hablar(tile);
      if (slot == _slots.length - 1) {
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
    final ult = _slots.lastIndexWhere((s) => s != null);
    if (ult < 0) return;
    final sil = _slots[ult]!;
    setState(() {
      _slots[ult] = null;
      for (var i = 0; i < _silabasMezcla.length; i++) {
        if (_usadas[i] && _silabasMezcla[i] == sil) {
          _usadas[i] = false;
          break;
        }
      }
    });
  }

  Future<void> _completar() async {
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('lectura');
    AudioService.instancia.muyBien();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    AudioService.instancia.hablar(_palabra.palabra.toLowerCase());
    await mostrarCelebracion(
      context,
      subtitulo: '${_palabra.silabas.join('-')}  =  ${_palabra.palabra}',
    );
    if (!mounted) return;
    setState(_nuevaRonda);
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Forma sílabas',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['ma', 'pe', 'lo', 'gu', 'si'],
      audioInstruccion: 'instr_forma_silabas',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final imagen = _TarjetaImagen(
            palabra: _palabra,
            color: _color,
            tamano: landscape ? 100 : 130,
            onTap: () =>
                AudioService.instancia.hablar(_palabra.palabra.toLowerCase()),
          );

          final slots = Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _slots.length; i++)
                _SlotSilaba(
                  silaba: _slots[i],
                  color: _color,
                  onTap: _slots[i] != null ? _quitarUltima : null,
                ),
            ],
          );

          final tiles = Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < _silabasMezcla.length; i++)
                _TileSilaba(
                  silaba: _silabasMezcla[i],
                  usada: _usadas[i],
                  incorrecta: _tileIncorrecto == i,
                  color: _color,
                  shake: _shake,
                  onTap: () => _tocar(i),
                ),
            ],
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(child: Center(child: imagen)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        slots,
                        const SizedBox(height: 16),
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
                const Text(
                  'Forma la palabra con sílabas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333355),
                  ),
                ),
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

class _TarjetaImagen extends StatelessWidget {
  final _PalabraSilabica palabra;
  final Color color;
  final double tamano;
  final VoidCallback onTap;
  const _TarjetaImagen({
    required this.palabra,
    required this.color,
    required this.tamano,
    required this.onTap,
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: color.withValues(alpha: 0.30), width: 3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconKid(palabra.emoji, size: tamano, sombra: true),
              const SizedBox(width: 10),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.volume_up_rounded, color: color, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotSilaba extends StatelessWidget {
  final String? silaba;
  final Color color;
  final VoidCallback? onTap;
  const _SlotSilaba({
    required this.silaba,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lleno = silaba != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: const BoxConstraints(
          minWidth: 72,
          minHeight: 62,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: lleno ? gradienteCategoria(color) : null,
          color: lleno ? null : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: lleno ? Colors.white : color.withValues(alpha: 0.45),
            width: 3,
          ),
          boxShadow: lleno ? sombraSuave : null,
        ),
        alignment: Alignment.center,
        child: Text(
          silaba ?? '',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: lleno ? Colors.white : color,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _TileSilaba extends StatelessWidget {
  final String silaba;
  final bool usada;
  final bool incorrecta;
  final Color color;
  final AnimationController shake;
  final VoidCallback onTap;
  const _TileSilaba({
    required this.silaba,
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
        final dx = incorrecta ? sin(shake.value * pi * 6) * 8.0 : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: usada ? 0.25 : 1.0,
        child: GestureDetector(
          onTap: usada ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(
              minWidth: 78,
              minHeight: 66,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              silaba,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
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
