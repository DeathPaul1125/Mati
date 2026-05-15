import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class CuerpoScreen extends StatefulWidget {
  const CuerpoScreen({super.key});

  @override
  State<CuerpoScreen> createState() => _CuerpoScreenState();
}

class _ParteCuerpo {
  final String emoji;
  final String nombre;
  const _ParteCuerpo(this.emoji, this.nombre);
}

class _CuerpoScreenState extends State<CuerpoScreen> {
  static const _color = Color(0xFFEC4899);

  static const _partes = <_ParteCuerpo>[
    _ParteCuerpo('👀', 'Ojos'),
    _ParteCuerpo('👂', 'Oreja'),
    _ParteCuerpo('👃', 'Nariz'),
    _ParteCuerpo('👄', 'Boca'),
    _ParteCuerpo('🦷', 'Diente'),
    _ParteCuerpo('🖐', 'Mano'),
    _ParteCuerpo('🦶', 'Pie'),
    _ParteCuerpo('🦵', 'Pierna'),
  ];

  final _rng = Random();
  late _ParteCuerpo _correcta;
  late List<_ParteCuerpo> _opciones;
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
      _correcta = _partes[_rng.nextInt(_partes.length)];
      intentos++;
    } while (_correcta.nombre == _previa && intentos < 5);
    _previa = _correcta.nombre;

    final candidatos = [..._partes]..shuffle(_rng);
    final set = <_ParteCuerpo>{_correcta};
    for (final c in candidatos) {
      if (set.length >= 4) break;
      set.add(c);
    }
    _opciones = set.toList()..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  void _anunciar() {
    AudioService.instancia.hablar('¿Dónde está ${_correcta.nombre.toLowerCase()}?');
  }

  Future<void> _elegir(_ParteCuerpo p) async {
    if (p.nombre == _correcta.nombre) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('mundo');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo: _correcta.nombre,
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
      _anunciar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Mi cuerpo',
      categoria: 'mundo',
      color: _color,
      simbolosTema: const ['♡', '✦'],
      audioInstruccion: 'instr_cuerpo',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            _Pregunta(
              parte: _correcta,
              color: _color,
              onRepetir: _anunciar,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final p in _opciones)
                      _TarjetaParte(
                        parte: p,
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
  final _ParteCuerpo parte;
  final Color color;
  final VoidCallback onRepetir;
  const _Pregunta({
    required this.parte,
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
            '¿Dónde está',
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
              parte.nombre.toUpperCase(),
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
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
              width: 38,
              height: 38,
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

class _TarjetaParte extends StatelessWidget {
  final _ParteCuerpo parte;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _TarjetaParte({
    required this.parte,
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
        builder: (context, cn) {
          final lado = min(cn.maxWidth, cn.maxHeight);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: IconKid(parte.emoji, size: lado * 0.55, sombra: true),
          );
        },
      ),
    );
  }
}
