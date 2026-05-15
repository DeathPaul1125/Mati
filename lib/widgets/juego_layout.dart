import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/audio_service.dart';
import '../state/jugadores.dart';
import '../theme.dart';
import 'confeti.dart';
import 'decoracion_tematica.dart';
import 'fondo_decorativo.dart';
import 'icon_kid.dart';
import 'sesion_tracker.dart';

class JuegoLayout extends StatefulWidget {
  final String titulo;
  final String? categoria;
  final Color color;
  final Widget child;
  final List<String>? simbolosTema;
  final String? audioInstruccion;
  // Si es false, no se muestra la barra superior con el chip del jugador
  // (solo se sigue mostrando si hay modo multijugador activo).
  final bool mostrarJugador;

  const JuegoLayout({
    super.key,
    required this.titulo,
    required this.color,
    required this.child,
    this.categoria,
    this.simbolosTema,
    this.audioInstruccion,
    this.mostrarJugador = false,
  });

  @override
  State<JuegoLayout> createState() => _JuegoLayoutState();
}

class _JuegoLayoutState extends State<JuegoLayout> {
  @override
  void initState() {
    super.initState();
    if (widget.audioInstruccion != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) AudioService.instancia.frase(widget.audioInstruccion!);
        });
      });
    }
  }

  void _repetirInstruccion() {
    if (widget.audioInstruccion != null) {
      AudioService.instancia.frase(widget.audioInstruccion!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorSuave = Color.lerp(widget.color, Colors.white, 0.82)!;
    final colorMedio = Color.lerp(widget.color, Colors.white, 0.55)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.titulo),
        flexibleSpace: Container(
          decoration:
              BoxDecoration(gradient: gradienteCategoria(widget.color)),
        ),
        actions: [
          if (widget.audioInstruccion != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _repetirInstruccion,
                icon: const Icon(Icons.volume_up_rounded,
                    color: Colors.white, size: 28),
                tooltip: 'Repetir instrucción',
              ),
            ),
        ],
      ),
      body: SesionTracker(
        categoria: widget.categoria ?? widget.titulo.toLowerCase(),
        child: FondoDecorativo(
          colores: [colorSuave, colorMedio],
          cantidadEstrellas: 8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.simbolosTema != null)
                DecoracionTematica(
                    simbolos: widget.simbolosTema!, color: widget.color),
              SafeArea(
                child: Column(
                  children: [
                    // El chip del jugador se sigue mostrando en multijugador
                    // (importante para indicar de quién es el turno) o cuando
                    // el juego lo pida explícitamente.
                    if (widget.mostrarJugador ||
                        Jugadores.instancia.multijugador)
                      BarraJugadores(color: widget.color)
                    else
                      // Mantenemos el espacio que ocupaba la AppBar
                      const SizedBox(height: 70),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarraJugadores extends StatelessWidget {
  final Color color;
  const BarraJugadores({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Jugadores.instancia,
      builder: (context, _) {
        final j = Jugadores.instancia;
        if (!j.multijugador) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FichaJugador(
                  jugador: jugadorMatias,
                  estrellas: j.estrellasDe(jugadorMatias),
                  activo: true,
                ),
                const SizedBox.shrink(),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 70, 12, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FichaJugador(
                jugador: jugadorMatias,
                estrellas: j.estrellasDe(jugadorMatias),
                activo: j.activo == jugadorMatias,
              ),
              IndicadorTurno(jugador: j.activo),
              FichaJugador(
                jugador: jugadorMichelle,
                estrellas: j.estrellasDe(jugadorMichelle),
                activo: j.activo == jugadorMichelle,
              ),
            ],
          ),
        );
      },
    );
  }
}

class FichaJugador extends StatelessWidget {
  final Jugador jugador;
  final int estrellas;
  final bool activo;

  const FichaJugador({
    super.key,
    required this.jugador,
    required this.estrellas,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: activo
            ? Colors.white
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        boxShadow: activo ? sombraTarjeta : sombraSuave,
        border: Border.all(
          color: activo ? jugador.color : Colors.transparent,
          width: 3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconKid(jugador.emoji, size: 26),
          const SizedBox(width: 6),
          Text(
            jugador.nombre,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: activo ? KidsColors.texto : KidsColors.textoSuave,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star_rounded, color: KidsColors.estrella, size: 22),
          const SizedBox(width: 2),
          Text(
            '$estrellas',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class IndicadorTurno extends StatelessWidget {
  final Jugador jugador;
  const IndicadorTurno({super.key, required this.jugador});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: jugador.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraSuave,
      ),
      child: Text(
        'Te toca',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class TarjetaGrande extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final double? aspectRatio;
  final double radius;
  final EdgeInsets padding;

  const TarjetaGrande({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.aspectRatio,
    this.radius = 24,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      elevation: 6,
      shadowColor: Colors.black54,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: Center(child: child)),
      ),
    );
    if (aspectRatio != null) {
      return AspectRatio(aspectRatio: aspectRatio!, child: card);
    }
    return card;
  }
}

Future<void> mostrarCelebracion(BuildContext context, {String? subtitulo}) async {
  HapticFeedback.mediumImpact();
  await showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    barrierDismissible: false,
    builder: (dialogCtx) {
      final navigator = Navigator.of(dialogCtx);
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (navigator.canPop()) navigator.pop();
      });
      return Stack(
        children: [
          const Positioned.fill(child: ConfetiOverlay()),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 380),
              curve: Curves.elasticOut,
              builder: (_, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 84)),
                    const SizedBox(height: 4),
                    const Text(
                      '¡Muy bien!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: KidsColors.exito,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: KidsColors.textoSuave,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void mostrarErrorSuave(BuildContext context) {
  HapticFeedback.selectionClick();
  final j = Jugadores.instancia;
  final mensaje = j.multijugador
      ? '¡Intenta otra vez, ${j.activo.nombre}!'
      : '¡Inténtalo otra vez, Matías!';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        backgroundColor: Colors.orange.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Row(
          children: [
            const Text('🤔', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
}
