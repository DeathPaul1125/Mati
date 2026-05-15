import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../state/perfiles_service.dart';

/// Codepoints que solo se distribuyen en el set Fluent (caras de emociones
/// que no están en los packs Twemoji/OpenMoji incluidos).
const Set<String> _soloFluent = {
  '1f600', // feliz
  '1f60d', // enamorado
  '1f622', // triste
  '1f62d', // llorando
  '1f620', // enojado
  '1f632', // sorprendido
  '1f634', // cansado
  '1f628', // asustado
  '1f642', // sonrisa leve (card de Emociones)
  '1f552', // reloj de las tres (card de Reloj)
  '1f524', // letras latinas (card de Sílabas)
  '1f3af', // diana (card de Caza letra)
};

String _codepointFromEmoji(String emoji) {
  final runes = emoji.runes.where((r) => r != 0xFE0F).toList();
  return runes
      .map((r) => r.toRadixString(16).toUpperCase().padLeft(4, '0'))
      .join('-');
}

class IconKid extends StatelessWidget {
  final String emoji;
  final double size;
  final bool sombra;

  const IconKid(
    this.emoji, {
    super.key,
    this.size = 48,
    this.sombra = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PerfilesService.instancia,
      builder: (context, _) {
        final estilo = PerfilesService.instancia.estiloIconos;
        final code = _codepointFromEmoji(emoji);
        final codeLower = code.toLowerCase();
        final String asset;
        // Algunos iconos (caras de emociones, etc.) solo existen en Fluent,
        // así que se fuerza Fluent para esos codepoints.
        if (_soloFluent.contains(codeLower) ||
            estilo == PerfilesService.estiloFluent) {
          asset = 'assets/fluent/$codeLower.svg';
        } else if (estilo == PerfilesService.estiloTwemoji) {
          asset = 'assets/twemoji/$codeLower.svg';
        } else {
          asset = 'assets/openmoji/$code.svg';
        }
        final svg = SvgPicture.asset(
          asset,
          width: size,
          height: size,
          placeholderBuilder: (_) =>
              Text(emoji, style: TextStyle(fontSize: size)),
        );
        if (!sombra) return svg;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: -size * 0.06,
              child: Container(
                width: size * 0.7,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(size),
                ),
              ),
            ),
            svg,
          ],
        );
      },
    );
  }
}

class IconKidSilueta extends StatelessWidget {
  final String emoji;
  final double size;
  final Color color;

  const IconKidSilueta(
    this.emoji, {
    super.key,
    this.size = 64,
    this.color = const Color(0xCC2A3A55),
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: IconKid(emoji, size: size),
    );
  }
}
