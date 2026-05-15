import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/dificultad.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class MemoriaScreen extends StatefulWidget {
  const MemoriaScreen({super.key});

  @override
  State<MemoriaScreen> createState() => _MemoriaScreenState();
}

class _Carta {
  final String emoji;
  bool revelada = false;
  bool resuelta = false;
  _Carta(this.emoji);
}

class _MemoriaScreenState extends State<MemoriaScreen> {
  static const _emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🦁', '🐯'];

  final _rng = Random();
  late List<_Carta> _cartas;
  _Carta? _primera;
  bool _bloqueado = false;

  @override
  void initState() {
    super.initState();
    _nuevaPartida();
  }

  void _nuevaPartida() {
    final d = Dificultad.deEdad(
        PerfilesService.instancia.activo?.edad ?? 4);
    final seleccionados = [..._emojis]..shuffle(_rng);
    final pares = seleccionados.take(d.memoriaParejas).toList();
    _cartas = [
      for (final e in pares) ...[_Carta(e), _Carta(e)],
    ]..shuffle(_rng);
    _primera = null;
    _bloqueado = false;
  }

  Future<void> _tocar(_Carta carta) async {
    if (_bloqueado || carta.revelada || carta.resuelta) return;
    setState(() => carta.revelada = true);

    if (_primera == null) {
      _primera = carta;
      return;
    }

    if (_primera!.emoji == carta.emoji) {
      setState(() {
        _primera!.resuelta = true;
        carta.resuelta = true;
        _primera = null;
      });
      Jugadores.instancia.sumarYPasarTurno();
      PerfilesService.instancia.sumarEstrellaActivo('memoria');
      if (_cartas.every((c) => c.resuelta)) {
        await mostrarCelebracion(context, subtitulo: '¡Encontraste todas!');
        if (!mounted) return;
        setState(_nuevaPartida);
      }
    } else {
      _bloqueado = true;
      await Future.delayed(const Duration(milliseconds: 850));
      if (!mounted) return;
      setState(() {
        _primera!.revelada = false;
        carta.revelada = false;
        _primera = null;
        _bloqueado = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Parejas',
      categoria: 'memoria',
      color: KidsColors.memoria,
      simbolosTema: const ['💫', '✨', '⭐', '🌟'],
      audioInstruccion: 'instr_memoria',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          children: [
            Text(
              'Encuentra las parejas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF333355),
                  ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final landscape = constraints.maxWidth > constraints.maxHeight;
                  final maxExtent = landscape ? 150.0 : 180.0;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxExtent,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _cartas.length,
                    itemBuilder: (context, i) {
                      final c = _cartas[i];
                      return _CartaMemoria(carta: c, onTap: () => _tocar(c));
                    },
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

class _CartaMemoria extends StatelessWidget {
  final _Carta carta;
  final VoidCallback onTap;
  const _CartaMemoria({required this.carta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mostrar = carta.revelada || carta.resuelta;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: mostrar
              ? null
              : gradienteCategoria(KidsColors.memoria),
          color: mostrar ? Colors.white : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: mostrar
                ? IconKid(
                    carta.emoji,
                    key: const ValueKey('emoji'),
                    size: 100,
                    sombra: true,
                  )
                : const Icon(
                    Icons.help_rounded,
                    key: ValueKey('icon'),
                    size: 56,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
