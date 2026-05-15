import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class PatronesScreen extends StatefulWidget {
  const PatronesScreen({super.key});

  @override
  State<PatronesScreen> createState() => _PatronesScreenState();
}

class _PatronesScreenState extends State<PatronesScreen> {
  static const _color = Color(0xFF22C55E);

  // Conjuntos de items para los patrones — usamos emojis sencillos
  static const _itemsBase = <List<String>>[
    ['🔴', '🔵'],
    ['🔴', '🟡'],
    ['🔵', '🟢'],
    ['🌞', '🌙'],
    ['🍎', '🍌'],
    ['⭐', '☁'],
    ['🐱', '🐶'],
  ];

  static const _itemsTernarios = <List<String>>[
    ['🔴', '🔵', '🟢'],
    ['🔴', '🟡', '🔵'],
    ['🌞', '🌙', '⭐'],
    ['🍎', '🍌', '🍇'],
  ];

  final _rng = Random();
  late List<String> _secuencia; // visible
  late String _correcta;
  late List<String> _opciones;
  String? _patronPrevio;
  String? _tocadaIncorrecta;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);

    final List<String> items;
    final String patron;
    if (d.esPreescolar) {
      items = _itemsBase[_rng.nextInt(_itemsBase.length)];
      patron = 'ABAB'; // simple
    } else if (d.esBasica) {
      // ABAB o AABB
      if (_rng.nextBool()) {
        items = _itemsBase[_rng.nextInt(_itemsBase.length)];
        patron = 'ABAB';
      } else {
        items = _itemsBase[_rng.nextInt(_itemsBase.length)];
        patron = 'AABB';
      }
    } else {
      // ABAB, AABB o ABC
      final opc = _rng.nextInt(3);
      if (opc == 0) {
        items = _itemsBase[_rng.nextInt(_itemsBase.length)];
        patron = 'ABAB';
      } else if (opc == 1) {
        items = _itemsBase[_rng.nextInt(_itemsBase.length)];
        patron = 'AABB';
      } else {
        items = _itemsTernarios[_rng.nextInt(_itemsTernarios.length)];
        patron = 'ABC';
      }
    }

    // Genera la secuencia según el patrón. Mostramos 5 items + 1 que falta.
    final completa = <String>[];
    for (var i = 0; i < 6; i++) {
      switch (patron) {
        case 'ABAB':
          completa.add(items[i % 2]);
          break;
        case 'AABB':
          completa.add(items[(i ~/ 2) % 2]);
          break;
        case 'ABC':
          completa.add(items[i % 3]);
          break;
      }
    }
    final clave = '$patron-${items.join()}';
    if (clave == _patronPrevio) {
      // intentamos otro rápido
      _patronPrevio = clave;
    } else {
      _patronPrevio = clave;
    }

    _secuencia = completa.sublist(0, 5);
    _correcta = completa[5];

    // Opciones: correcta + 2 distractores
    final distinto = items.firstWhere((it) => it != _correcta,
        orElse: () => items.first);
    final tercero = items.length > 2
        ? items.firstWhere((it) => it != _correcta && it != distinto,
            orElse: () => '⭐')
        : '⭐';
    final opciones = <String>{_correcta, distinto, tercero}.toList();
    while (opciones.length < 3) {
      opciones.add('⭐');
    }
    opciones.shuffle(_rng);
    _opciones = opciones;
    _tocadaIncorrecta = null;
  }

  Future<void> _elegir(String s) async {
    if (s == _correcta) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('logica');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(context, subtitulo: '¡Patrón completo!');
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadaIncorrecta = s);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadaIncorrecta = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Patrones',
      categoria: 'logica',
      color: _color,
      simbolosTema: const ['🔴', '🔵', '🟢'],
      audioInstruccion: 'instr_patrones',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            const Text(
              '¿Qué sigue?',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF333355),
              ),
            ),
            const SizedBox(height: 10),
            // Secuencia con casilla "?"
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _secuencia)
                  _Celda(
                    contenido: IconKid(s, size: 50, sombra: true),
                    color: _color,
                    lleno: true,
                  ),
                _Celda(
                  contenido: Text(
                    '?',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: _color,
                    ),
                  ),
                  color: _color,
                  lleno: false,
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Elige la que sigue',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF555577),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final o in _opciones)
                      _OpcionGrande(
                        item: o,
                        color: _color,
                        incorrecta: _tocadaIncorrecta == o,
                        onTap: () => _elegir(o),
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

class _Celda extends StatelessWidget {
  final Widget contenido;
  final Color color;
  final bool lleno;
  const _Celda({
    required this.contenido,
    required this.color,
    required this.lleno,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: lleno ? Colors.white : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: lleno ? color.withValues(alpha: 0.3) : color,
          width: lleno ? 2 : 3,
        ),
        boxShadow: lleno ? sombraSuave : null,
      ),
      alignment: Alignment.center,
      child: contenido,
    );
  }
}

class _OpcionGrande extends StatelessWidget {
  final String item;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _OpcionGrande({
    required this.item,
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
        width: 100,
        height: 100,
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
        child: IconKid(item, size: 70, sombra: true),
      ),
    );
  }
}
