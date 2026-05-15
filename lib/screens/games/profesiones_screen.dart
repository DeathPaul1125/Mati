import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class ProfesionesScreen extends StatefulWidget {
  const ProfesionesScreen({super.key});

  @override
  State<ProfesionesScreen> createState() => _ProfesionesScreenState();
}

class _Profesion {
  final String nombre;
  final String herramienta;
  const _Profesion(this.nombre, this.herramienta);
}

class _ProfesionesScreenState extends State<ProfesionesScreen> {
  static const _color = Color(0xFF0EA5E9);

  static const _profesiones = <_Profesion>[
    _Profesion('Bombero', '🚒'),
    _Profesion('Policía', '🚓'),
    _Profesion('Cocinero', '🍳'),
    _Profesion('Astronauta', '🚀'),
    _Profesion('Doctor', '🩺'),
    _Profesion('Pintor', '🎨'),
    _Profesion('Granjero', '🌾'),
    _Profesion('Mecánico', '🔧'),
    _Profesion('Profesor', '📚'),
    _Profesion('Músico', '🎵'),
  ];

  final _rng = Random();
  late _Profesion _correcta;
  late List<_Profesion> _opciones;
  String? _previa;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 700), _anunciar);
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
      _correcta = _profesiones[_rng.nextInt(_profesiones.length)];
      intentos++;
    } while (_correcta.nombre == _previa && intentos < 5);
    _previa = _correcta.nombre;

    final pool = [..._profesiones]..shuffle(_rng);
    final set = <_Profesion>{_correcta};
    for (final p in pool) {
      if (set.length >= 3) break;
      set.add(p);
    }
    _opciones = set.toList()..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  void _anunciar() {
    AudioService.instancia.hablar(
        '¿Qué usa el ${_correcta.nombre.toLowerCase()}?');
  }

  Future<void> _elegir(_Profesion p) async {
    if (p.nombre == _correcta.nombre) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('mundo');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo: '${_correcta.nombre} usa ${_correcta.herramienta}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _anunciar();
    } else {
      setState(() => _tocadaIncorrecta = p.nombre);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Profesiones',
      categoria: 'mundo',
      color: _color,
      simbolosTema: const ['✦'],
      audioInstruccion: 'instr_profesiones',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            _Pregunta(
              profesion: _correcta,
              color: _color,
              onRepetir: _anunciar,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (final p in _opciones)
                      _TarjetaHerramienta(
                        profesion: p,
                        color: _color,
                        incorrecta: _tocadaIncorrecta == p.nombre,
                        onTap: () => _elegir(p),
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

class _Pregunta extends StatelessWidget {
  final _Profesion profesion;
  final Color color;
  final VoidCallback onRepetir;
  const _Pregunta({
    required this.profesion,
    required this.color,
    required this.onRepetir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraSuave,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
      ),
      child: Row(
        children: [
          const Text(
            '¿Qué usa el',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: gradienteCategoria(color),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              profesion.nombre.toUpperCase(),
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const Text('?',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              )),
          const Spacer(),
          GestureDetector(
            onTap: onRepetir,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.volume_up_rounded, color: color, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaHerramienta extends StatelessWidget {
  final _Profesion profesion;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _TarjetaHerramienta({
    required this.profesion,
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
        height: 130,
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
        alignment: Alignment.center,
        child: IconKid(profesion.herramienta, size: 80, sombra: true),
      ),
    );
  }
}
