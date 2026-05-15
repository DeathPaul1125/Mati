import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../state/perfiles_service.dart';

/// Codepoints que solo se distribuyen en el set Fluent (caras de emociones
/// que no están en el pack Twemoji incluido).
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
  // Comida y frutas para palabras silábicas
  '1f350', // pera
  '1f34b', // limón
  '1f34d', // piña
  '1f345', // tomate
  '1f36f', // miel
  '1f33d', // maíz
  '1f344', // hongo
  '1f955', // zanahoria
  '1f95a', // huevo
  '1f954', // papa
  '1f438', // rana
  '1f331', // semilla
  '1fa91', // silla
  '1f938', // gimnasta
  '1f41b', // gusano
  '1f9b4', // hueso
  // Partes del cuerpo
  '1f440', '1f442', '1f443', '1f444',
  '1f590', '1f9b6', '1f9b5', '1f9b7',
  // Profesiones
  '1f692', '1f693', '1f373', '1f680',
  '1fa7a', '1f33e', '1f527',
  // Círculos de colores (Patrones)
  '1f534', '1f535', '1f7e2', '1f7e1',
  // Otros
  '1f4d6', '1f4a1',
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
        } else {
          // Twemoji (cualquier valor distinto a fluent cae acá)
          asset = 'assets/twemoji/$codeLower.svg';
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
