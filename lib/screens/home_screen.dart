import 'package:flutter/material.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/icon_kid.dart';
import 'games/animales_screen.dart';
import 'games/aprender_letras_screen.dart';
import 'games/aprender_numeros_screen.dart';
import 'games/clasificar_screen.dart';
import 'games/colores_screen.dart';
import 'games/donde_esta_screen.dart';
import 'games/emociones_screen.dart';
import 'games/forma_palabras_screen.dart';
import 'games/formas_screen.dart';
import 'games/lectura_screen.dart';
import 'games/leer_palabra_screen.dart';
import 'games/logica_screen.dart';
import 'games/matematicas_screen.dart';
import 'games/memoria_screen.dart';
import 'games/opuestos_screen.dart';
import 'games/pintar_screen.dart';
import 'games/reloj_screen.dart';
import 'games/restas_screen.dart';
import 'games/sombras_screen.dart';
import 'games/sumas_screen.dart';
import 'games/trazo_letras_screen.dart';
import 'limite_alcanzado_screen.dart';
import 'logros_screen.dart';
import 'tienda_screen.dart';
import 'zona_infantil_screen.dart';
import 'zona_padres_screen.dart';

class Categoria {
  final String titulo;
  final String emoji;
  final Color color;
  final Widget Function() builder;
  const Categoria(this.titulo, this.emoji, this.color, this.builder);
}

class _Seccion {
  final String titulo;
  final List<Categoria> categorias;
  const _Seccion(this.titulo, this.categorias);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _aprende = [
    Categoria('¿Dónde está?', '👶', Color(0xFFFF8FB1),
        DondeEstaScreen.new),
    Categoria('Letras', '📚', Color(0xFFFFAE3D),
        AprenderLetrasScreen.new),
    Categoria('Forma', '🧩', Color(0xFFE94B86),
        FormaPalabrasScreen.new),
    Categoria('Números', '🔢', Color(0xFF5B8DEF),
        AprenderNumerosScreen.new),
    Categoria('Colores', '🎨', Color(0xFFA855F7),
        ColoresScreen.new),
    Categoria('Formas', '⬢', Color(0xFF22C55E),
        FormasScreen.new),
    Categoria('Animales', '🦊', Color(0xFFFF8A65),
        AnimalesScreen.new),
    Categoria('Trazar', '✍️', Color(0xFF42C8E2),
        TrazoLetrasScreen.new),
    Categoria('Opuestos', '🐘', Color(0xFF14B8A6),
        OpuestosScreen.new),
    Categoria('Emociones', '🙂', Color(0xFFFFB347),
        EmocionesScreen.new),
  ];

  static const _juega = [
    Categoria('Contar', '🍎', Color(0xFF7C4DFF),
        MatematicasScreen.new),
    Categoria('Sumar', '➕', Color(0xFF42C8E2),
        SumasScreen.new),
    Categoria('Restar', '➖', Color(0xFFEF4444),
        RestasScreen.new),
    Categoria('Reloj', '🕒', Color(0xFF06B6D4),
        RelojScreen.new),
    Categoria('Parejas', '🧠', Color(0xFF4ECDA4),
        MemoriaScreen.new),
    Categoria('Lógica', '🧩', Color(0xFFFF6B7A),
        LogicaScreen.new),
    Categoria('Sombras', '👤', Color(0xFF42C8E2),
        SombrasScreen.new),
    Categoria('Clasificar', '📦', Color(0xFFB47BD8),
        ClasificarScreen.new),
    Categoria('Letras Q.', '✨', Color(0xFFFFAE3D),
        LecturaScreen.new),
    Categoria('Leer', '📖', Color(0xFFF59E0B),
        LeerPalabraScreen.new),
  ];

  static const _crea = [
    Categoria('Pintar', '🎨', Color(0xFFE94B86),
        PintarScreen.new),
  ];

  static Future<void> abrirCategoria(
      BuildContext context, Categoria c) async {
    final perfil = PerfilesService.instancia.activo;
    if (perfil != null && perfil.limiteAlcanzado && perfil.limiteEstricto) {
      final desbloqueado = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LimiteAlcanzadoScreen()),
      );
      if (desbloqueado != true) return;
    }
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => c.builder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const secciones = [
      _Seccion('Aprende', _aprende),
      _Seccion('Juega y aprende', _juega),
      _Seccion('Crea', _crea),
    ];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7C4DFF), Color(0xFF5B3DCE)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CabeceraHome(),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 18),
                  children: [
                    for (final s in secciones) _SeccionFila(seccion: s),
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

class _CabeceraHome extends StatelessWidget {
  const _CabeceraHome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          Expanded(child: _ChipPerfilHeader()),
          const SizedBox(width: 8),
          _BotonRedondo(
            icono: Icons.emoji_events_rounded,
            color: const Color(0xFFFF8A65),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LogrosScreen()),
            ),
          ),
          const SizedBox(width: 6),
          _BotonTienda(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TiendaScreen()),
            ),
          ),
          const SizedBox(width: 6),
          _BotonPadres(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ZonaPadresScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPerfilHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PerfilesService.instancia,
      builder: (context, _) {
        final p = PerfilesService.instancia.activo;
        if (p == null) return const SizedBox.shrink();
        return Material(
          color: const Color(0xFF6438D8),
          borderRadius: BorderRadius.circular(36),
          child: InkWell(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ZonaInfantilScreen()),
            ),
            borderRadius: BorderRadius.circular(36),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: p.color.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: IconKid(p.avatar, size: 32),
                      ),
                      Positioned(
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: KidsColors.estrella,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            '${p.nivel()}',
                            style: const TextStyle(
                              fontFamily: kFuente,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.nombre,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${p.edad} años',
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD0C7F8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BotonRedondo extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _BotonRedondo({
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icono, color: color, size: 24),
        ),
      ),
    );
  }
}

class _BotonTienda extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonTienda({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PerfilesService.instancia,
      builder: (context, _) {
        final p = PerfilesService.instancia.activo;
        final puntos = p?.puntos ?? 0;
        return Material(
          elevation: 4,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD93D), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      '$puntos',
                      style: const TextStyle(
                        fontFamily: kFuente,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BotonPadres extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonPadres({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_rounded,
                  size: 20, color: Color(0xFF6438D8)),
              SizedBox(width: 4),
              Text(
                'Para los padres',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: KidsColors.texto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeccionFila extends StatelessWidget {
  final _Seccion seccion;
  const _SeccionFila({required this.seccion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Text(
            seccion.titulo,
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: seccion.categorias.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _TarjetaJuegoGrande(
              categoria: seccion.categorias[i],
              onTap: () =>
                  HomeScreen.abrirCategoria(context, seccion.categorias[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaJuegoGrande extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const _TarjetaJuegoGrande({
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        elevation: 6,
        shadowColor: Colors.black38,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: categoria.color.withValues(alpha: 0.18),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  alignment: Alignment.center,
                  child: _Ilustracion(categoria: categoria),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  categoria.titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: KidsColors.texto,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ilustracion extends StatelessWidget {
  final Categoria categoria;
  const _Ilustracion({required this.categoria});

  @override
  Widget build(BuildContext context) {
    final t = categoria.titulo;
    if (t == 'Letras' || t == 'Letras Q.') {
      return _PreviewTexto(
        textos: const ['A', 'B', 'C'],
        color: categoria.color,
      );
    }
    if (t == 'Forma') {
      return _PreviewTexto(
        textos: const ['T', 'A', 'C', 'O'],
        color: categoria.color,
      );
    }
    if (t == 'Números' || t == 'Contar') {
      return _PreviewTexto(
        textos: const ['1', '2', '3'],
        color: categoria.color,
      );
    }
    if (t == 'Trazar') {
      return _PreviewTexto(
        textos: const ['L'],
        color: categoria.color,
        grande: true,
      );
    }
    if (t == 'Colores') {
      return _PreviewColores();
    }
    if (t == 'Formas') {
      return _PreviewFormas();
    }
    return IconKid(categoria.emoji, size: 84, sombra: true);
  }
}

class _PreviewColores extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const colores = [
      Color(0xFFEF4444),
      Color(0xFFFCD34D),
      Color(0xFF22C55E),
      Color(0xFF3B82F6),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < colores.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 28,
            height: 60,
            decoration: BoxDecoration(
              color: colores[i],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colores[i].withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewFormas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        CustomPaint(
          size: const Size(40, 36),
          painter: _TrianguloPainter(),
        ),
      ],
    );
  }
}

class _TrianguloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF22C55E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _PreviewTexto extends StatelessWidget {
  final List<String> textos;
  final Color color;
  final bool grande;

  const _PreviewTexto({
    required this.textos,
    required this.color,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < textos.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: grande ? 90 : 38,
            height: grande ? 90 : 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(grande ? 22 : 12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              textos[i],
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: grande ? 52 : 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
