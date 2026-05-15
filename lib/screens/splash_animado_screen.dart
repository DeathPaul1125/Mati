import 'dart:math';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/fondo_decorativo.dart';
import 'zona_infantil_screen.dart';

class SplashAnimadoScreen extends StatefulWidget {
  const SplashAnimadoScreen({super.key});

  @override
  State<SplashAnimadoScreen> createState() => _SplashAnimadoScreenState();
}

class _SplashAnimadoScreenState extends State<SplashAnimadoScreen>
    with TickerProviderStateMixin {
  static const _duracionIntro = Duration(milliseconds: 1800);
  static const _esperaTotal = Duration(milliseconds: 2400);

  late final AnimationController _intro;
  late final AnimationController _flotar;

  late final Animation<double> _escalaCohete;
  late final Animation<double> _rotacionCohete;
  late final Animation<double> _opacidadTitulo;
  late final Animation<Offset> _slideTitulo;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(vsync: this, duration: _duracionIntro);
    _flotar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _escalaCohete = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.65),
    ));

    _rotacionCohete = Tween(begin: -0.18, end: 0.0).animate(CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    ));

    _opacidadTitulo = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    _slideTitulo = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
    ));

    _intro.forward();
    _flotar.repeat(reverse: true);

    Future.delayed(_esperaTotal, _navegarAlHome);
  }

  void _navegarAlHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ZonaInfantilScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _flotar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDecorativo(
        colores: const [Color(0xFF7C4DFF), Color(0xFF5B3DCE)],
        cantidadEstrellas: 22,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_intro, _flotar]),
                  builder: (_, _) {
                    final flot = sin(_flotar.value * 2 * pi) * 8;
                    return Transform.translate(
                      offset: Offset(0, flot),
                      child: Transform.rotate(
                        angle: _rotacionCohete.value,
                        child: Transform.scale(
                          scale: _escalaCohete.value,
                          child: Image.asset(
                            'assets/icon_fg.png',
                            width: 220,
                            height: 220,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                SlideTransition(
                  position: _slideTitulo,
                  child: FadeTransition(
                    opacity: _opacidadTitulo,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Juegos Kids',
                          style: TextStyle(
                            fontFamily: kFuente,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '¡Aprende y juega!',
                          style: TextStyle(
                            fontFamily: kFuente,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE9DEFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
