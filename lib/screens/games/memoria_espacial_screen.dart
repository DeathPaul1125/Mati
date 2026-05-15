import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class MemoriaEspacialScreen extends StatefulWidget {
  const MemoriaEspacialScreen({super.key});

  @override
  State<MemoriaEspacialScreen> createState() => _MemoriaEspacialScreenState();
}

enum _Fase { observar, recordar, resultado }

class _MemoriaEspacialScreenState extends State<MemoriaEspacialScreen> {
  static const _color = Color(0xFF7C4DFF);
  static const _emojis = [
    '🐶', '🐱', '🐭', '🐰', '🐻', '🦊', '🦁', '🐯',
    '🐮', '🦒', '🐨', '🦋', '🐝', '🐟', '🐢',
    '🍎', '🍌', '🍕', '🍓', '⭐', '🌙', '🌞', '🌹', '🏠', '🚗',
  ];

  final _rng = Random();
  late List<String> _items;
  late int _indiceObjetivo;
  late int _columnas;
  _Fase _fase = _Fase.observar;
  int? _tocadoIncorrecto;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioService.instancia.detener();
    super.dispose();
  }

  void _nuevaRonda() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final int cantidad;
    if (d.esPreescolar) {
      cantidad = 4; // 2x2
      _columnas = 2;
    } else if (d.esBasica) {
      cantidad = 6; // 2x3 o 3x2
      _columnas = 3;
    } else {
      cantidad = 9; // 3x3
      _columnas = 3;
    }
    final pool = [..._emojis]..shuffle(_rng);
    _items = pool.take(cantidad).toList();
    _indiceObjetivo = _rng.nextInt(cantidad);
    _fase = _Fase.observar;
    _tocadoIncorrecto = null;

    _timer?.cancel();
    final segundos = d.esPreescolar ? 3 : (d.esBasica ? 4 : 4);
    _timer = Timer(Duration(seconds: segundos), () {
      if (!mounted) return;
      setState(() => _fase = _Fase.recordar);
      AudioService.instancia.hablar(
          '¿Dónde estaba el ${_items[_indiceObjetivo].toLowerCase()}?');
    });
  }

  Future<void> _tocar(int idx) async {
    if (_fase != _Fase.recordar) return;
    if (idx == _indiceObjetivo) {
      setState(() => _fase = _Fase.resultado);
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('logica');
      AudioService.instancia.celebrarYDecir('¡Muy bien!');
      await mostrarCelebracion(context, subtitulo: '¡Lo recordaste!');
      if (!mounted) return;
      setState(_nuevaRonda);
    } else {
      setState(() => _tocadoIncorrecto = idx);
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _tocadoIncorrecto = null);
    }
  }

  void _saltarObservacion() {
    if (_fase != _Fase.observar) return;
    _timer?.cancel();
    setState(() => _fase = _Fase.recordar);
    AudioService.instancia.hablar(
        '¿Dónde estaba el ${_items[_indiceObjetivo].toLowerCase()}?');
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Memoria espacial',
      categoria: 'logica',
      color: _color,
      simbolosTema: const ['?', '✦', '🧠'],
      audioInstruccion: 'instr_memoria_espacial',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            _Cabecera(
              fase: _fase,
              emojiObjetivo: _items[_indiceObjetivo],
              color: _color,
              onSaltar: _saltarObservacion,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _columnas,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, i) => _Celda(
                    emoji: _items[i],
                    visible: _fase == _Fase.observar ||
                        _fase == _Fase.resultado ||
                        _tocadoIncorrecto == i,
                    color: _color,
                    incorrecta: _tocadoIncorrecto == i,
                    onTap: () => _tocar(i),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final _Fase fase;
  final String emojiObjetivo;
  final Color color;
  final VoidCallback onSaltar;
  const _Cabecera({
    required this.fase,
    required this.emojiObjetivo,
    required this.color,
    required this.onSaltar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: sombraSuave,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        children: [
          if (fase == _Fase.observar) ...[
            const Expanded(
              child: Text(
                'Mira bien dónde está cada dibujo…',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KidsColors.texto,
                ),
              ),
            ),
            TextButton(
              onPressed: onSaltar,
              child: Text(
                'Listo',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ] else if (fase == _Fase.recordar) ...[
            const Text(
              '¿Dónde estaba',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(width: 6),
            IconKid(emojiObjetivo, size: 36, sombra: true),
            const SizedBox(width: 6),
            const Text(
              '?',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: KidsColors.texto,
              ),
            ),
          ] else
            const Expanded(
              child: Text(
                '¡Genial!',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KidsColors.exito,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Celda extends StatelessWidget {
  final String emoji;
  final bool visible;
  final Color color;
  final bool incorrecta;
  final VoidCallback onTap;
  const _Celda({
    required this.emoji,
    required this.visible,
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
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              gradient: visible ? null : gradienteCategoria(color),
              color: visible ? Colors.white : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c, width: 3),
              boxShadow: [
                BoxShadow(
                  color: c.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: visible
                ? IconKid(emoji, size: lado * 0.6, sombra: true)
                : Text(
                    '?',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: lado * 0.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
