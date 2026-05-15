import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

class CazaLetraScreen extends StatefulWidget {
  const CazaLetraScreen({super.key});

  @override
  State<CazaLetraScreen> createState() => _CazaLetraScreenState();
}

class _Burbuja {
  final String letra;
  final Color color;
  final double x; // 0..1
  final double y; // 0..1
  final double fase;
  bool atrapada = false;
  bool error = false;
  _Burbuja({
    required this.letra,
    required this.color,
    required this.x,
    required this.y,
    required this.fase,
  });
}

class _CazaLetraScreenState extends State<CazaLetraScreen>
    with SingleTickerProviderStateMixin {
  static const _color = Color(0xFF06B6D4);

  static const _objetivos = ['M', 'P', 'S', 'L', 'G'];
  static const _distractoras = [
    'A', 'E', 'I', 'O', 'U', 'B', 'C', 'D', 'F', 'N', 'R', 'T'
  ];
  static const _coloresBurbuja = [
    Color(0xFFFF6B7A),
    Color(0xFF5B8DEF),
    Color(0xFF22C55E),
    Color(0xFFA855F7),
    Color(0xFFFFAE3D),
    Color(0xFFE94B86),
    Color(0xFF4ECDA4),
    Color(0xFF42C8E2),
  ];

  final _rng = Random();
  late String _objetivo;
  late List<_Burbuja> _burbujas;
  int _atrapadas = 0;
  int _total = 0;
  late final AnimationController _flotar;

  @override
  void initState() {
    super.initState();
    _flotar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), _anunciar);
    });
  }

  @override
  void dispose() {
    _flotar.dispose();
    AudioService.instancia.detener();
    super.dispose();
  }

  void _nuevaRonda() {
    _objetivo = _objetivos[_rng.nextInt(_objetivos.length)];
    final cantidadCorrectas = 3 + _rng.nextInt(2); // 3 o 4
    final cantidadTotal = 10;
    final letras = <String>[];
    for (var i = 0; i < cantidadCorrectas; i++) {
      letras.add(_objetivo);
    }
    while (letras.length < cantidadTotal) {
      final cand = _distractoras[_rng.nextInt(_distractoras.length)];
      letras.add(cand);
    }
    letras.shuffle(_rng);

    // Distribuir en una "grilla" 4x3 con variación aleatoria para que no se vea ordenada
    final col = 3;
    final fil = (cantidadTotal / col).ceil();
    _burbujas = [];
    for (var i = 0; i < letras.length; i++) {
      final c = i % col;
      final f = i ~/ col;
      final cellW = 1.0 / col;
      final cellH = 1.0 / fil;
      final cx = cellW * (c + 0.5);
      final cy = cellH * (f + 0.5);
      // jitter dentro de la celda
      final jx = (_rng.nextDouble() - 0.5) * cellW * 0.25;
      final jy = (_rng.nextDouble() - 0.5) * cellH * 0.25;
      _burbujas.add(_Burbuja(
        letra: letras[i],
        color: _coloresBurbuja[_rng.nextInt(_coloresBurbuja.length)],
        x: (cx + jx).clamp(0.08, 0.92),
        y: (cy + jy).clamp(0.08, 0.92),
        fase: _rng.nextDouble() * 2 * pi,
      ));
    }
    _atrapadas = 0;
    _total = cantidadCorrectas;
  }

  void _anunciar() {
    AudioService.instancia.hablar('Toca todas las letras $_objetivo');
  }

  Future<void> _tocar(_Burbuja b) async {
    if (b.atrapada) return;
    if (b.letra == _objetivo) {
      setState(() {
        b.atrapada = true;
        _atrapadas++;
      });
      AudioService.instancia.letra(b.letra);
      PerfilesService.instancia.sumarEstrellaActivo('lectura');
      if (_atrapadas >= _total) {
        Jugadores.instancia.sumarYPasarTurno();
        AudioService.instancia.muyBien();
        await mostrarCelebracion(
          context,
          subtitulo: '¡Cazaste todas las $_objetivo!',
        );
        if (!mounted) return;
        setState(_nuevaRonda);
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        _anunciar();
      }
    } else {
      setState(() => b.error = true);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => b.error = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Caza la letra',
      categoria: 'lectura',
      color: _color,
      simbolosTema: const ['M', 'P', 'S', 'L', 'G'],
      audioInstruccion: 'instr_caza_letra',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            _PanelObjetivo(
              objetivo: _objetivo,
              atrapadas: _atrapadas,
              total: _total,
              color: _color,
              onRepetir: _anunciar,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: _color.withValues(alpha: 0.3), width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _flotar,
                            builder: (context, _) {
                              final t = _flotar.value * 2 * pi;
                              return Stack(
                                children: [
                                  for (final b in _burbujas)
                                    if (!b.atrapada)
                                      Positioned(
                                        left: b.x * c.maxWidth -
                                            40 +
                                            sin(t + b.fase) * 6,
                                        top: b.y * c.maxHeight -
                                            40 +
                                            cos(t + b.fase * 1.3) * 6,
                                        child: _BurbujaWidget(
                                          letra: b.letra,
                                          color: b.color,
                                          error: b.error,
                                          onTap: () => _tocar(b),
                                        ),
                                      ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelObjetivo extends StatelessWidget {
  final String objetivo;
  final int atrapadas;
  final int total;
  final Color color;
  final VoidCallback onRepetir;
  const _PanelObjetivo({
    required this.objetivo,
    required this.atrapadas,
    required this.total,
    required this.color,
    required this.onRepetir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraSuave,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        children: [
          const Text(
            'Toca todas las',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradienteCategoria(color),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              objetivo,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                i < atrapadas
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: KidsColors.estrella,
                size: 26,
              ),
            ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRepetir,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.volume_up_rounded, color: color, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _BurbujaWidget extends StatelessWidget {
  final String letra;
  final Color color;
  final bool error;
  final VoidCallback onTap;
  const _BurbujaWidget({
    required this.letra,
    required this.color,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = error ? KidsColors.error : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: gradienteCategoria(c),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.45),
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
            fontSize: 42,
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
    );
  }
}
