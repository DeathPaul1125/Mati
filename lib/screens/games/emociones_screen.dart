import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class EmocionesScreen extends StatefulWidget {
  const EmocionesScreen({super.key});

  @override
  State<EmocionesScreen> createState() => _EmocionesScreenState();
}

class _Emocion {
  final String emoji;
  final String nombre;
  const _Emocion(this.emoji, this.nombre);
}

class _EmocionesScreenState extends State<EmocionesScreen> {
  static const _color = Color(0xFFFFB347);

  static const _emociones = <_Emocion>[
    _Emocion('🙂', 'Feliz'),
    _Emocion('😢', 'Triste'),
    _Emocion('😠', 'Enojado'),
    _Emocion('😲', 'Sorprendido'),
    _Emocion('😴', 'Cansado'),
    _Emocion('😨', 'Asustado'),
    _Emocion('😍', 'Enamorado'),
    _Emocion('😭', 'Llorando'),
  ];

  final _rng = Random();
  late _Emocion _correcta;
  late List<_Emocion> _opciones;
  String? _previa;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), _decirEmocion);
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
      _correcta = _emociones[_rng.nextInt(_emociones.length)];
      intentos++;
    } while (_correcta.nombre == _previa && intentos < 5);
    _previa = _correcta.nombre;

    final candidatos = [..._emociones]..shuffle(_rng);
    final opciones = <_Emocion>{_correcta};
    for (final c in candidatos) {
      if (opciones.length >= 4) break;
      opciones.add(c);
    }
    _opciones = opciones.toList()..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  void _decirEmocion() {
    AudioService.instancia.hablar('Toca la cara ${_correcta.nombre}');
  }

  Future<void> _elegir(_Emocion e) async {
    if (e.nombre == _correcta.nombre) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('emociones');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo: '${_correcta.emoji}  ${_correcta.nombre}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _decirEmocion();
    } else {
      setState(() => _tocadaIncorrecta = e.nombre);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
      _decirEmocion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Emociones',
      categoria: 'emociones',
      color: _color,
      simbolosTema: const ['❤', '✨', '♡'],
      audioInstruccion: 'instr_emociones',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final pregunta = _Pregunta(
            nombre: _correcta.nombre,
            color: _color,
            onRepetir: _decirEmocion,
          );

          final grid = GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.0,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final e in _opciones)
                _TarjetaCara(
                  emocion: e,
                  color: _color,
                  incorrecta: _tocadaIncorrecta == e.nombre,
                  onTap: () => _elegir(e),
                ),
            ],
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Center(child: pregunta),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: Center(child: grid)),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              children: [
                pregunta,
                const SizedBox(height: 16),
                Expanded(child: Center(child: grid)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Pregunta extends StatelessWidget {
  final String nombre;
  final Color color;
  final VoidCallback onRepetir;
  const _Pregunta({
    required this.nombre,
    required this.color,
    required this.onRepetir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: sombraSuave,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Toca la cara ',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: KidsColors.texto,
            ),
          ),
          Text(
            nombre.toUpperCase(),
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRepetir,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
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

class _TarjetaCara extends StatelessWidget {
  final _Emocion emocion;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _TarjetaCara({
    required this.emocion,
    required this.color,
    required this.incorrecta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = incorrecta ? KidsColors.error : color;
    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final lado = constraints.maxWidth;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c, width: 3),
              boxShadow: [
                BoxShadow(
                  color: c.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: IconKid(emocion.emoji, size: lado * 0.68, sombra: true),
          );
        },
      ),
    );
  }
}
