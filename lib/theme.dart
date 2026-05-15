import 'package:flutter/material.dart';

class KidsColors {
  static const matematicas = Color(0xFF5B8DEF);
  static const memoria = Color(0xFF4ECDA4);
  static const logica = Color(0xFFFF6B7A);
  static const lectura = Color(0xFFFFAE3D);
  static const clasificar = Color(0xFFB47BD8);
  static const sombras = Color(0xFF42C8E2);
  static const pintar = Color(0xFFE94B86);

  static const fondo = Color(0xFFFFF8E7);
  static const tarjeta = Colors.white;
  static const exito = Color(0xFF66BB6A);
  static const error = Color(0xFFEF5350);
  static const estrella = Color(0xFFFFC83D);

  static const cieloTop = Color(0xFF92D9F2);
  static const cieloBottom = Color(0xFFCFEBF8);
  static const pasto = Color(0xFFA3DD8B);
  static const texto = Color(0xFF2E3656);
  static const textoSuave = Color(0xFF5C6680);
}

const kFuente = 'Fredoka';

LinearGradient gradienteCategoria(Color base) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(base, Colors.white, 0.28)!,
      base,
      Color.lerp(base, Colors.black, 0.12)!,
    ],
    stops: const [0.0, 0.55, 1.0],
  );
}

LinearGradient gradienteFondoSuave(Color base) {
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.lerp(base, Colors.white, 0.88)!,
      Color.lerp(base, Colors.white, 0.65)!,
    ],
  );
}

ThemeData buildKidsTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: KidsColors.fondo,
    fontFamily: kFuente,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KidsColors.matematicas,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontFamily: kFuente, fontSize: 52, fontWeight: FontWeight.w700,
          height: 1.1, color: KidsColors.texto),
      displayMedium: TextStyle(
          fontFamily: kFuente, fontSize: 38, fontWeight: FontWeight.w700,
          height: 1.1, color: KidsColors.texto),
      headlineMedium: TextStyle(
          fontFamily: kFuente, fontSize: 28, fontWeight: FontWeight.w700,
          color: KidsColors.texto),
      titleLarge: TextStyle(
          fontFamily: kFuente, fontSize: 24, fontWeight: FontWeight.w600,
          color: KidsColors.texto),
      bodyLarge: TextStyle(
          fontFamily: kFuente, fontSize: 20, fontWeight: FontWeight.w500,
          color: KidsColors.texto),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: kFuente,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
        shadows: [Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 5)],
      ),
      iconTheme: IconThemeData(size: 34, color: Colors.white),
    ),
  );
}

const sombraTarjeta = [
  BoxShadow(color: Color(0x33000000), blurRadius: 14, offset: Offset(0, 8)),
  BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1)),
];

const sombraSuave = [
  BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5)),
];

const sombraStickerColor = [
  BoxShadow(color: Color(0x44000000), blurRadius: 16, offset: Offset(0, 10)),
];

BoxDecoration tarjetaSticker({
  required Color color,
  double radius = 26,
  Color? borde,
}) {
  return BoxDecoration(
    gradient: gradienteCategoria(color),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borde ?? Colors.white, width: 4),
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.55),
        blurRadius: 14,
        offset: const Offset(0, 8),
      ),
      const BoxShadow(
        color: Color(0x22000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );
}

BoxDecoration tarjetaBlanca({double radius = 24}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white, width: 4),
    boxShadow: sombraTarjeta,
  );
}
