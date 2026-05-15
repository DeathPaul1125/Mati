import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class MayorMenorScreen extends StatefulWidget {
  const MayorMenorScreen({super.key});

  @override
  State<MayorMenorScreen> createState() => _MayorMenorScreenState();
}

class _MayorMenorScreenState extends State<MayorMenorScreen> {
  static const _color = Color(0xFF0EA5E9);
  static const _emojis = ['🍎', '⭐', '🌸', '🐝', '🍓', '🍒', '🌺', '🐠'];

  final _rng = Random();
  late int _izquierda;
  late int _derecha;
  late String _emoji;
  late bool _buscaMas;
  String? _previo;
  String? _ladoIncorrecto;

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
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final maxN = d.esPreescolar ? 6 : (d.esBasica ? 10 : 15);

    var intentos = 0;
    do {
      _izquierda = 1 + _rng.nextInt(maxN);
      _derecha = 1 + _rng.nextInt(maxN);
      intentos++;
    } while ((_izquierda == _derecha ||
            '$_izquierda-$_derecha' == _previo) &&
        intentos < 8);
    _previo = '$_izquierda-$_derecha';

    _emoji = _emojis[_rng.nextInt(_emojis.length)];
    _buscaMas = _rng.nextBool();
    _ladoIncorrecto = null;
  }

  void _anunciar() {
    AudioService.instancia.hablar(
        _buscaMas ? 'Toca el grupo con más' : 'Toca el grupo con menos');
  }

  bool _ladoCorrecto(bool izquierda) {
    final esMas = _izquierda > _derecha;
    if (_buscaMas) return izquierda == esMas;
    return izquierda != esMas;
  }

  Future<void> _elegir(bool izquierda) async {
    if (_ladoCorrecto(izquierda)) {
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('matematicas');
      AudioService.instancia.muyBien();
      await mostrarCelebracion(
        context,
        subtitulo: _buscaMas
            ? '${max(_izquierda, _derecha)} es más que ${min(_izquierda, _derecha)}'
            : '${min(_izquierda, _derecha)} es menos que ${max(_izquierda, _derecha)}',
      );
      if (!mounted) return;
      setState(_nuevaRonda);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _anunciar();
    } else {
      setState(() => _ladoIncorrecto = izquierda ? 'izq' : 'der');
      mostrarErrorSuave(context);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _ladoIncorrecto = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: _buscaMas ? 'Más o menos' : 'Más o menos',
      categoria: 'matematicas',
      color: _color,
      simbolosTema: const ['>', '<', '=', '?'],
      audioInstruccion: 'instr_mayor_menor',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            _Encabezado(
              buscaMas: _buscaMas,
              color: _color,
              onRepetir: _anunciar,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _Grupo(
                      cantidad: _izquierda,
                      emoji: _emoji,
                      color: _color,
                      incorrecto: _ladoIncorrecto == 'izq',
                      onTap: () => _elegir(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Grupo(
                      cantidad: _derecha,
                      emoji: _emoji,
                      color: _color,
                      incorrecto: _ladoIncorrecto == 'der',
                      onTap: () => _elegir(false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final bool buscaMas;
  final Color color;
  final VoidCallback onRepetir;
  const _Encabezado({
    required this.buscaMas,
    required this.color,
    required this.onRepetir,
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
          const Text(
            'Toca el grupo con',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              gradient: gradienteCategoria(color),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              buscaMas ? 'MÁS' : 'MENOS',
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
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

class _Grupo extends StatelessWidget {
  final int cantidad;
  final String emoji;
  final Color color;
  final bool incorrecto;
  final VoidCallback onTap;
  const _Grupo({
    required this.cantidad,
    required this.emoji,
    required this.color,
    required this.incorrecto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = incorrecto ? KidsColors.error : color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(
                    cantidad,
                    (_) => IconKid(emoji, size: 32, sombra: true),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradienteCategoria(color),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                '$cantidad',
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
