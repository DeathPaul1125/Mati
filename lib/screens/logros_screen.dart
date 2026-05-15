import 'package:flutter/material.dart';
import '../state/logros.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/fondo_decorativo.dart';

class LogrosScreen extends StatelessWidget {
  const LogrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDecorativo(
        colores: const [Color(0xFFFFE7B5), Color(0xFFFFC5D6)],
        cantidadEstrellas: 14,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: PerfilesService.instancia,
            builder: (context, _) {
              final perfil = PerfilesService.instancia.activo;
              if (perfil == null) return const SizedBox.shrink();
              final conseguidos =
                  perfil.logrosDesbloqueados.length;
              final total = logrosDisponibles.length;
              return Column(
                children: [
                  _Cabecera(
                    conseguidos: conseguidos,
                    total: total,
                    rachaActual: perfil.rachaActual,
                    rachaMaxima: perfil.rachaMaxima,
                    onCerrar: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: logrosDisponibles.length,
                      itemBuilder: (context, i) {
                        final l = logrosDisponibles[i];
                        final tiene =
                            perfil.logrosDesbloqueados.contains(l.id);
                        return _TarjetaLogro(logro: l, conseguido: tiene);
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
  final int conseguidos;
  final int total;
  final int rachaActual;
  final int rachaMaxima;
  final VoidCallback onCerrar;

  const _Cabecera({
    required this.conseguidos,
    required this.total,
    required this.rachaActual,
    required this.rachaMaxima,
    required this.onCerrar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onCerrar,
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
                'Logros',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: KidsColors.texto,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Chip(
                emoji: '🏆',
                texto: '$conseguidos / $total',
                color: const Color(0xFFFFC83D),
              ),
              const SizedBox(width: 10),
              _Chip(
                emoji: '🔥',
                texto: 'Racha máx: $rachaMaxima',
                color: const Color(0xFFFF6B7A),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String emoji;
  final String texto;
  final Color color;

  const _Chip({
    required this.emoji,
    required this.texto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraSuave,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaLogro extends StatelessWidget {
  final Logro logro;
  final bool conseguido;

  const _TarjetaLogro({required this.logro, required this.conseguido});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: conseguido ? KidsColors.exito : Colors.transparent,
          width: 4,
        ),
        boxShadow: conseguido ? sombraTarjeta : sombraSuave,
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: (conseguido
                      ? KidsColors.exito
                      : KidsColors.textoSuave)
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: conseguido
                ? Text(logro.emoji, style: const TextStyle(fontSize: 32))
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.33, 0.33, 0.33, 0, 0,
                      0.33, 0.33, 0.33, 0, 0,
                      0.33, 0.33, 0.33, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Text(logro.emoji,
                        style: const TextStyle(fontSize: 32)),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  logro.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: conseguido
                        ? KidsColors.texto
                        : KidsColors.textoSuave,
                  ),
                ),
                Text(
                  logro.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KidsColors.textoSuave,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 14,
                        color: conseguido
                            ? KidsColors.estrella
                            : KidsColors.textoSuave),
                    Text(
                      '+${logro.puntosBonus}',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: conseguido
                            ? KidsColors.texto
                            : KidsColors.textoSuave,
                      ),
                    ),
                    if (conseguido) ...[
                      const Spacer(),
                      const Icon(Icons.check_circle_rounded,
                          color: KidsColors.exito, size: 18),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
