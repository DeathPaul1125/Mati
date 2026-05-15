import 'dart:convert';
import 'package:flutter/material.dart';

class Perfil {
  final String id;
  String nombre;
  int edad;
  String avatar;
  int colorValor;
  String? genero; // 'nino', 'nina' o null (no especificado)
  int metaDiariaMin;
  bool limiteEstricto;
  int puntos;
  int rachaActual;
  int rachaMaxima;
  Set<String> avatarsDesbloqueados;
  Set<String> logrosDesbloqueados;
  Set<String> tutorialesVistos;
  Map<String, int> estrellas;
  Map<String, int> segundosPorCategoria;
  Map<String, int> segundosPorDia;

  Perfil({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.avatar,
    required this.colorValor,
    this.genero,
    this.metaDiariaMin = 15,
    this.limiteEstricto = false,
    this.puntos = 0,
    this.rachaActual = 0,
    this.rachaMaxima = 0,
    Set<String>? avatarsDesbloqueados,
    Set<String>? logrosDesbloqueados,
    Set<String>? tutorialesVistos,
    Map<String, int>? estrellas,
    Map<String, int>? segundosPorCategoria,
    Map<String, int>? segundosPorDia,
  })  : avatarsDesbloqueados = avatarsDesbloqueados ?? {},
        logrosDesbloqueados = logrosDesbloqueados ?? {},
        tutorialesVistos = tutorialesVistos ?? {},
        estrellas = estrellas ?? {},
        segundosPorCategoria = segundosPorCategoria ?? {},
        segundosPorDia = segundosPorDia ?? {};

  Color get color => Color(colorValor);

  int get segundosHoy => segundosPorDia[_hoy()] ?? 0;
  int get minutosHoy => segundosHoy ~/ 60;
  int get totalSegundos =>
      segundosPorCategoria.values.fold(0, (a, b) => a + b);
  int get totalEstrellas => estrellas.values.fold(0, (a, b) => a + b);
  double get progresoDiario => metaDiariaMin == 0
      ? 0
      : (minutosHoy / metaDiariaMin).clamp(0.0, 1.0);
  bool get limiteAlcanzado => minutosHoy >= metaDiariaMin;

  List<String> get diasJugados =>
      segundosPorDia.entries.where((e) => e.value > 0).map((e) => e.key).toList();

  /// Cuenta los días consecutivos jugados terminando hoy (o ayer, si todavía
  /// no jugó hoy). Si rompió la racha hace varios días, devuelve 0.
  int diasConsecutivos() {
    final dias = diasJugados.toSet();
    if (dias.isEmpty) return 0;
    final n = DateTime.now();
    var dia = DateTime(n.year, n.month, n.day);
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    // Si todavía no jugó HOY, dejamos pasar (la racha sigue viva si jugó ayer)
    if (!dias.contains(fmt(dia))) {
      dia = dia.subtract(const Duration(days: 1));
      if (!dias.contains(fmt(dia))) return 0;
    }
    var racha = 0;
    while (dias.contains(fmt(dia))) {
      racha++;
      dia = dia.subtract(const Duration(days: 1));
    }
    return racha;
  }

  int nivel() {
    final t = totalEstrellas;
    if (t < 10) return 1;
    if (t < 30) return 2;
    if (t < 60) return 3;
    if (t < 100) return 4;
    return 5 + ((t - 100) ~/ 50);
  }

  void registrarTiempo(String categoria, int segundos) {
    segundosPorCategoria[categoria] =
        (segundosPorCategoria[categoria] ?? 0) + segundos;
    final dia = _hoy();
    segundosPorDia[dia] = (segundosPorDia[dia] ?? 0) + segundos;
  }

  void sumarEstrella(String categoria) {
    estrellas[categoria] = (estrellas[categoria] ?? 0) + 1;
    rachaActual++;
    if (rachaActual > rachaMaxima) rachaMaxima = rachaActual;
    final mult = rachaActual >= 10
        ? 4
        : rachaActual >= 5
            ? 3
            : rachaActual >= 3
                ? 2
                : 1;
    puntos += 5 * mult;
  }

  void romperRacha() {
    rachaActual = 0;
  }

  int multiplicadorRacha() {
    if (rachaActual >= 10) return 4;
    if (rachaActual >= 5) return 3;
    if (rachaActual >= 3) return 2;
    return 1;
  }

  Set<String> get categoriasJugadas =>
      estrellas.entries.where((e) => e.value > 0).map((e) => e.key).toSet();

  bool puedeComprar(int precio) => puntos >= precio;

  bool comprarAvatar(String avatar, int precio) {
    if (!puedeComprar(precio)) return false;
    if (avatarsDesbloqueados.contains(avatar)) return false;
    puntos -= precio;
    avatarsDesbloqueados.add(avatar);
    return true;
  }

  bool tieneAvatar(String avatar) =>
      avatarsDesbloqueados.contains(avatar) || avataresDisponibles.contains(avatar);

  static String _hoy() {
    final n = DateTime.now();
    return '${n.year.toString().padLeft(4, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'edad': edad,
        'avatar': avatar,
        'colorValor': colorValor,
        'genero': genero,
        'metaDiariaMin': metaDiariaMin,
        'limiteEstricto': limiteEstricto,
        'puntos': puntos,
        'rachaActual': rachaActual,
        'rachaMaxima': rachaMaxima,
        'avatarsDesbloqueados': avatarsDesbloqueados.toList(),
        'logrosDesbloqueados': logrosDesbloqueados.toList(),
        'tutorialesVistos': tutorialesVistos.toList(),
        'estrellas': estrellas,
        'segundosPorCategoria': segundosPorCategoria,
        'segundosPorDia': segundosPorDia,
      };

  factory Perfil.fromJson(Map<String, dynamic> j) => Perfil(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        edad: j['edad'] as int,
        avatar: j['avatar'] as String,
        colorValor: j['colorValor'] as int,
        genero: j['genero'] as String?,
        metaDiariaMin: j['metaDiariaMin'] as int? ?? 15,
        limiteEstricto: j['limiteEstricto'] as bool? ?? false,
        puntos: j['puntos'] as int? ?? 0,
        rachaActual: j['rachaActual'] as int? ?? 0,
        rachaMaxima: j['rachaMaxima'] as int? ?? 0,
        avatarsDesbloqueados: Set<String>.from(
            (j['avatarsDesbloqueados'] as List?)?.cast<String>() ?? []),
        logrosDesbloqueados: Set<String>.from(
            (j['logrosDesbloqueados'] as List?)?.cast<String>() ?? []),
        tutorialesVistos: Set<String>.from(
            (j['tutorialesVistos'] as List?)?.cast<String>() ?? []),
        estrellas: Map<String, int>.from(j['estrellas'] ?? {}),
        segundosPorCategoria:
            Map<String, int>.from(j['segundosPorCategoria'] ?? {}),
        segundosPorDia: Map<String, int>.from(j['segundosPorDia'] ?? {}),
      );

  String serializar() => jsonEncode(toJson());
  factory Perfil.deserializar(String s) =>
      Perfil.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

const avataresDisponibles = ['🦊', '🐱', '🐶', '🐰', '🐼', '🦁', '🐻', '🐯', '🐹', '🐸', '🐧'];

class AvatarPremium {
  final String emoji;
  final String nombre;
  final int precio;
  const AvatarPremium(this.emoji, this.nombre, this.precio);
}

const avataresPremium = <AvatarPremium>[
  AvatarPremium('🐭', 'Ratón', 40),
  AvatarPremium('🐮', 'Vaca', 40),
  AvatarPremium('🐥', 'Pollito', 50),
  AvatarPremium('🦋', 'Mariposa', 50),
  AvatarPremium('🐠', 'Pez', 60),
  AvatarPremium('🐝', 'Abeja', 70),
  AvatarPremium('🐦', 'Pájaro', 70),
  AvatarPremium('🐨', 'Koala', 100),
  AvatarPremium('🦒', 'Jirafa', 100),
  AvatarPremium('🐢', 'Tortuga', 120),
  AvatarPremium('🦓', 'Cebra', 140),
  AvatarPremium('🐙', 'Pulpo', 160),
  AvatarPremium('🦩', 'Flamenco', 180),
  AvatarPremium('🦘', 'Canguro', 200),
  AvatarPremium('🦔', 'Erizo', 220),
  AvatarPremium('🐳', 'Ballena', 250),
  AvatarPremium('🐲', 'Dragón', 320),
  AvatarPremium('🦖', 'T-Rex', 400),
  AvatarPremium('🦄', 'Unicornio', 500),
];

const coloresPerfilesDisponibles = [
  0xFFFF8A65,
  0xFFE984D2,
  0xFF5B8DEF,
  0xFF4ECDA4,
  0xFFFFAE3D,
  0xFFB47BD8,
  0xFF42C8E2,
  0xFFFF6B7A,
];
