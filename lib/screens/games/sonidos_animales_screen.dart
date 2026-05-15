import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class SonidosAnimalesScreen extends StatefulWidget {
  const SonidosAnimalesScreen({super.key});

  @override
  State<SonidosAnimalesScreen> createState() => _SonidosAnimalesScreenState();
}

class _Animal {
  final String clave;
  final String nombre;
  final String emoji;
  const _Animal(this.clave, this.nombre, this.emoji);
}

class _SonidosAnimalesScreenState extends State<SonidosAnimalesScreen> {
  static const _color = Color(0xFF8B5CF6);

  static const _animales = <_Animal>[
    _Animal('gato', 'Gato', '🐱'),
    _Animal('perro', 'Perro', '🐶'),
    _Animal('vaca', 'Vaca', '🐮'),
    _Animal('leon', 'León', '🦁'),
    _Animal('elefante', 'Elefante', '🐘'),
    _Animal('oso', 'Oso', '🐻'),
    _Animal('pajaro', 'Pájaro', '🐦'),
    _Animal('conejo', 'Conejo', '🐰'),
    _Animal('jirafa', 'Jirafa', '🦒'),
    _Animal('koala', 'Koala', '🐨'),
    _Animal('mariposa', 'Mariposa', '🦋'),
    _Animal('abeja', 'Abeja', '🐝'),
    _Animal('pollito', 'Pollito', '🐥'),
    _Animal('tigre', 'Tigre', '🐯'),
    _Animal('zorro', 'Zorro', '🦊'),
  ];

  final _rng = Random();
  late _Animal _correcto;
  late List<_Animal> _opciones;
  String? _previo;
  String? _tocadoIncorrecto;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 900), _reproducirSonido);
    });
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  void _nuevaRonda() {
    var intentos = 0;
    do {
      _correcto = _animales[_rng.nextInt(_animales.length)];
      intentos++;
    } while (_correcto.nombre == _previo && intentos < 5);
    _previo = _correcto.nombre;

    final pool = [..._animales]..shuffle(_rng);
    final set = <_Animal>{_correcto};
    for (final a in pool) {
      if (set.length >= 3) break;
      set.add(a);
    }
    _opciones = set.toList()..shuffle(_rng);
    _tocadoIncorrecto = null;
  }

  void _reproducirSonido() {
    AudioService.instancia.animal(_correcto.clave, _correcto.nombre);
  }

  Future<void> _elegir(_Animal a) async {
    if (a.nombre == _correcto.nombre) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('mundo');
      AudioService.instancia.celebrarYDecir('¡Es ${_correcto.nombre.toLowerCase()}!');
      await mostrarCelebracion(
        context,
        subtitulo: '${_correcto.emoji} ${_correcto.nombre}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      _reproducirSonido();
    } else {
      setState(() => _tocadoIncorrecto = a.nombre);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadoIncorrecto = null);
      _reproducirSonido();
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Sonidos animales',
      categoria: 'mundo',
      color: _color,
      simbolosTema: const ['♪', '♫'],
      audioInstruccion: 'instr_sonidos_animales',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            _BotonSonido(color: _color, onTap: _reproducirSonido),
            const SizedBox(height: 16),
            const Text(
              '¿Qué animal hace ese sonido?',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF333355),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final a in _opciones)
                      _TarjetaAnimal(
                        animal: a,
                        color: _color,
                        incorrecta: _tocadoIncorrecto == a.nombre,
                        onTap: () => _elegir(a),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonSonido extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  const _BotonSonido({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: gradienteCategoria(color),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.volume_up_rounded,
              size: 50, color: Colors.white),
        ),
      ),
    );
  }
}

class _TarjetaAnimal extends StatelessWidget {
  final _Animal animal;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _TarjetaAnimal({
    required this.animal,
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
        width: 120,
        padding: const EdgeInsets.all(8),
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
            IconKid(animal.emoji, size: 80, sombra: true),
            const SizedBox(height: 4),
            Text(
              animal.nombre,
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
