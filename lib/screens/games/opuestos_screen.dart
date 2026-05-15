import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class OpuestosScreen extends StatefulWidget {
  const OpuestosScreen({super.key});

  @override
  State<OpuestosScreen> createState() => _OpuestosScreenState();
}

class _Lado {
  final String emoji;
  final String etiqueta;
  const _Lado(this.emoji, this.etiqueta);
}

class _ParOpuesto {
  final _Lado a;
  final _Lado b;
  const _ParOpuesto(this.a, this.b);
}

class _OpuestosScreenState extends State<OpuestosScreen> {
  static const _color = Color(0xFF14B8A6);

  static const _pares = <_ParOpuesto>[
    _ParOpuesto(_Lado('🐘', 'Grande'), _Lado('🐭', 'Pequeño')),
    _ParOpuesto(_Lado('🌞', 'Día'), _Lado('🌙', 'Noche')),
    _ParOpuesto(_Lado('🐢', 'Lento'), _Lado('🐰', 'Rápido')),
    _ParOpuesto(_Lado('🦒', 'Alto'), _Lado('🐭', 'Bajo')),
    _ParOpuesto(_Lado('🐦', 'Cielo'), _Lado('🐟', 'Agua')),
    _ParOpuesto(_Lado('🌞', 'Sol'), _Lado('☁️', 'Nubes')),
    _ParOpuesto(_Lado('🦁', 'Grande'), _Lado('🐱', 'Pequeño')),
  ];

  final _rng = Random();
  late _Lado _referencia;
  late _Lado _opuesto;
  late List<_Lado> _opciones;
  String? _previa;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    var intentos = 0;
    _ParOpuesto par;
    do {
      par = _pares[_rng.nextInt(_pares.length)];
      intentos++;
    } while (par.a.etiqueta == _previa && intentos < 5);
    final usarA = _rng.nextBool();
    _referencia = usarA ? par.a : par.b;
    _opuesto = usarA ? par.b : par.a;
    _previa = _referencia.etiqueta;

    // Distractores: items de otros pares, distintos al opuesto correcto
    final candidatos = <_Lado>[];
    for (final p in _pares) {
      if (p == par) continue;
      candidatos.add(p.a);
      candidatos.add(p.b);
    }
    candidatos.shuffle(_rng);

    final opciones = <_Lado>{_opuesto};
    for (final c in candidatos) {
      if (opciones.length >= 3) break;
      // Evitar repetir emoji o etiqueta del opuesto
      if (c.emoji == _opuesto.emoji) continue;
      if (c.etiqueta == _opuesto.etiqueta) continue;
      if (c.emoji == _referencia.emoji) continue;
      opciones.add(c);
    }
    _opciones = opciones.toList()..shuffle(_rng);
    _tocadaIncorrecta = null;
  }

  Future<void> _elegir(_Lado l) async {
    if (l.emoji == _opuesto.emoji && l.etiqueta == _opuesto.etiqueta) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('opuestos');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo:
            'El opuesto de ${_referencia.etiqueta} es ${_opuesto.etiqueta}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadaIncorrecta = '${l.emoji}_${l.etiqueta}');
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Opuestos',
      categoria: 'opuestos',
      color: _color,
      simbolosTema: const ['↔', '⇆', '✦'],
      audioInstruccion: 'instr_opuestos',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;

          final referencia = _TarjetaReferencia(
            lado: _referencia,
            color: _color,
            tamano: landscape ? 110 : 130,
          );

          final opcionesWidget = Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final l in _opciones)
                _TarjetaOpcion(
                  lado: l,
                  color: _color,
                  incorrecta: _tocadaIncorrecta == '${l.emoji}_${l.etiqueta}',
                  onTap: () => _elegir(l),
                ),
            ],
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Center(child: referencia)),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _Pregunta(),
                        const SizedBox(height: 12),
                        opcionesWidget,
                      ],
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
                const SizedBox(height: 8),
                referencia,
                const SizedBox(height: 16),
                Expanded(child: Center(child: opcionesWidget)),
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
      '¿Cuál es el opuesto?',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kFuente,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF333355),
      ),
    );
  }
}

class _TarjetaReferencia extends StatelessWidget {
  final _Lado lado;
  final Color color;
  final double tamano;
  const _TarjetaReferencia({
    required this.lado,
    required this.color,
    required this.tamano,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
        boxShadow: sombraTarjeta,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconKid(lado.emoji, size: tamano, sombra: true),
          const SizedBox(height: 4),
          Text(
            lado.etiqueta,
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final _Lado lado;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _TarjetaOpcion({
    required this.lado,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
            IconKid(lado.emoji, size: 64, sombra: true),
            const SizedBox(height: 4),
            Text(
              lado.etiqueta,
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
