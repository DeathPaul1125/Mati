import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/perfil.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/confeti.dart';
import '../widgets/fondo_decorativo.dart';
import '../widgets/icon_kid.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  Future<void> _comprar(AvatarPremium a) async {
    final perfil = PerfilesService.instancia.activo;
    if (perfil == null) return;

    if (perfil.avatarsDesbloqueados.contains(a.emoji)) {
      perfil.avatar = a.emoji;
      await PerfilesService.instancia.actualizar(perfil);
      if (!mounted) return;
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: KidsColors.exito,
          content: Text(
            '¡Ahora usas el avatar ${a.nombre}!',
            style: const TextStyle(
                fontFamily: kFuente,
                fontWeight: FontWeight.w800,
                fontSize: 16),
          ),
          duration: const Duration(milliseconds: 1200),
        ));
      return;
    }

    if (!perfil.puedeComprar(a.precio)) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          backgroundColor: Colors.orange.shade400,
          content: Text(
            'Necesitas ${a.precio - perfil.puntos} puntos más',
            style: const TextStyle(
                fontFamily: kFuente,
                fontWeight: FontWeight.w800,
                fontSize: 16),
          ),
          duration: const Duration(milliseconds: 1500),
        ));
      return;
    }

    perfil.comprarAvatar(a.emoji, a.precio);
    perfil.avatar = a.emoji;
    await PerfilesService.instancia.actualizar(perfil);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (dialogCtx) {
        final navigator = Navigator.of(dialogCtx);
        Future.delayed(const Duration(milliseconds: 1600), () {
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
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 20,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: KidsColors.estrella.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: IconKid(a.emoji, size: 96, sombra: true),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '¡Nuevo avatar!',
                        style: TextStyle(
                          fontFamily: kFuente,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: KidsColors.exito,
                        ),
                      ),
                      Text(
                        a.nombre,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: KidsColors.texto,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDecorativo(
        colores: const [Color(0xFFFFE7B5), Color(0xFFFFC5D6)],
        cantidadEstrellas: 12,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: PerfilesService.instancia,
            builder: (context, _) {
              final perfil = PerfilesService.instancia.activo;
              if (perfil == null) return const SizedBox.shrink();
              return Column(
                children: [
                  _Cabecera(perfil: perfil),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: avataresPremium.length,
                      itemBuilder: (context, i) {
                        final a = avataresPremium[i];
                        final tiene =
                            perfil.avatarsDesbloqueados.contains(a.emoji);
                        final activo = perfil.avatar == a.emoji;
                        final puede = perfil.puedeComprar(a.precio);
                        return _TarjetaAvatar(
                          avatar: a,
                          tiene: tiene,
                          activo: activo,
                          puede: puede,
                          onTap: () => _comprar(a),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final Perfil perfil;
  const _Cabecera({required this.perfil});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.close_rounded,
                    color: KidsColors.texto, size: 24),
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Tienda',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD93D), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: sombraSuave,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 4),
                Text(
                  '${perfil.puntos}',
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaAvatar extends StatelessWidget {
  final AvatarPremium avatar;
  final bool tiene;
  final bool activo;
  final bool puede;
  final VoidCallback onTap;

  const _TarjetaAvatar({
    required this.avatar,
    required this.tiene,
    required this.activo,
    required this.puede,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: activo ? 8 : 4,
      shadowColor: activo
          ? KidsColors.exito.withValues(alpha: 0.6)
          : Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: activo
                  ? KidsColors.exito
                  : tiene
                      ? const Color(0xFF7BC76B)
                      : Colors.transparent,
              width: 4,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: (tiene
                                ? KidsColors.exito
                                : KidsColors.estrella)
                            .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!tiene && !puede)
                      ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.33, 0.33, 0.33, 0, 0,
                          0.33, 0.33, 0.33, 0, 0,
                          0.33, 0.33, 0.33, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: IconKid(avatar.emoji, size: 64),
                      )
                    else
                      IconKid(avatar.emoji, size: 64, sombra: true),
                    if (!tiene && !puede)
                      const Positioned(
                        bottom: 4,
                        right: 4,
                        child: Icon(Icons.lock_rounded,
                            color: Color(0xFF555577), size: 22),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                avatar.nombre,
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: KidsColors.texto,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (activo)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: KidsColors.exito,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'En uso',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (tiene)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7BC76B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Usar',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded,
                        color: puede
                            ? KidsColors.estrella
                            : KidsColors.textoSuave,
                        size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '${avatar.precio}',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: puede
                            ? KidsColors.texto
                            : KidsColors.textoSuave,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
