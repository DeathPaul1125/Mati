import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class RestasScreen extends StatefulWidget {
  const RestasScreen({super.key});

  @override
  State<RestasScreen> createState() => _RestasScreenState();
}

class _RestasScreenState extends State<RestasScreen> {
  static const _color = Color(0xFFEF4444);
  static const _emojis = ['🍎', '🎈', '⭐', '🍓', '🍒', '🌸', '🐠', '🍇'];

  final _rng = Random();
  late int _a;
  late int _b;
  late int _resultado;
  late String _emoji;
  late List<int> _opciones;
  int? _resultadoPrevio;
  final Set<int> _eliminados = {};

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final maxNum = d.esPreescolar ? 5 : (d.esBasica ? 10 : 15);

    var intentos = 0;
    do {
      _resultado = _rng.nextInt(maxNum); // 0..maxNum-1
      _a = _resultado + 1 + _rng.nextInt(maxNum - _resultado);
      _b = _a - _resultado;
      intentos++;
    } while (_resultado == _resultadoPrevio && intentos < 5);
    _resultadoPrevio = _resultado;
    _emoji = _emojis[_rng.nextInt(_emojis.length)];

    final opciones = <int>{_resultado};
    while (opciones.length < 3) {
      final delta = _rng.nextInt(5) - 2;
      final cand = _resultado + delta;
      if (cand >= 0 && cand <= maxNum) opciones.add(cand);
    }
    _opciones = opciones.toList()..shuffle(_rng);
    _eliminados.clear();
  }

  Future<void> _elegir(int n) async {
    if (n != _resultado) {
      AudioService.instancia.intentalo();
      mostrarErrorSuave(context);
      return;
    }
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('sumas');
    AudioService.instancia.muyBien();
    await mostrarCelebracion(
      context,
      subtitulo: '$_a − $_b = $_resultado',
    );
    if (!mounted) return;
    setState(_nuevaRonda);
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Restar',
      categoria: 'sumas',
      color: _color,
      simbolosTema: const ['−', '=', '1', '2', '3'],
      audioInstruccion: 'instr_numeros_aprender',
      child: OrientationBuilder(
        builder: (context, orientation) {
          final landscape = orientation == Orientation.landscape;
          final operacion = _PanelOperacion(
            a: _a,
            b: _b,
            emoji: _emoji,
            color: _color,
            eliminados: _eliminados,
          );
          final opciones = _PanelOpciones(
            opciones: _opciones,
            color: _color,
            onTap: _elegir,
          );

          if (landscape) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  Expanded(flex: 3, child: operacion),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: opciones),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Expanded(child: operacion),
                const SizedBox(height: 14),
                opciones,
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PanelOperacion extends StatelessWidget {
  final int a;
  final int b;
  final String emoji;
  final Color color;
  final Set<int> eliminados;

  const _PanelOperacion({
    required this.a,
    required this.b,
    required this.emoji,
    required this.color,
    required this.eliminados,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: sombraTarjeta,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Representación visual: A items, con B tachados/grises
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: List.generate(a, (i) {
              final tachado = i >= a - b;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: tachado ? 0.30 : 1.0,
                    child: IconKid(emoji, size: 38),
                  ),
                  if (tachado)
                    Icon(Icons.close_rounded,
                        size: 36, color: color.withValues(alpha: 0.85)),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          // Expresión a − b = ?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Caja(texto: '$a', color: color),
              const SizedBox(width: 8),
              Text(
                '−',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              _Caja(texto: '$b', color: color),
              const SizedBox(width: 8),
              Text(
                '=',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              const _Caja(texto: '?', color: Color(0xFFFFC83D)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Caja extends StatelessWidget {
  final String texto;
  final Color color;
  const _Caja({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.25)!,
            color,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        texto,
        style: const TextStyle(
          fontFamily: kFuente,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PanelOpciones extends StatelessWidget {
  final List<int> opciones;
  final Color color;
  final void Function(int) onTap;

  const _PanelOpciones({
    required this.opciones,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: opciones
          .map((n) => GestureDetector(
                onTap: () => onTap(n),
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(color, Colors.white, 0.25)!,
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.42),
                          blurRadius: 8,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$n',
                    style: const TextStyle(
                      fontFamily: kFuente,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
