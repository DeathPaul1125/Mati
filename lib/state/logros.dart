class Logro {
  final String id;
  final String titulo;
  final String descripcion;
  final String emoji;
  final int puntosBonus;
  final bool Function(PerfilStats stats) condicion;

  const Logro({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.emoji,
    required this.puntosBonus,
    required this.condicion,
  });
}

class PerfilStats {
  final int totalEstrellas;
  final int totalSegundos;
  final int diasJugados;
  final int rachaMaxima;
  final Set<String> categoriasJugadas;
  final Map<String, int> estrellasPorCategoria;

  const PerfilStats({
    required this.totalEstrellas,
    required this.totalSegundos,
    required this.diasJugados,
    required this.rachaMaxima,
    required this.categoriasJugadas,
    required this.estrellasPorCategoria,
  });
}

const logrosDisponibles = <Logro>[
  Logro(
    id: 'primera_estrella',
    titulo: 'Primera estrella',
    descripcion: 'Gana tu primera estrella',
    emoji: '⭐',
    puntosBonus: 5,
    condicion: _primeraEstrella,
  ),
  Logro(
    id: 'diez_estrellas',
    titulo: 'Pequeño aprendiz',
    descripcion: 'Junta 10 estrellas',
    emoji: '🌟',
    puntosBonus: 10,
    condicion: _diezEstrellas,
  ),
  Logro(
    id: 'cincuenta_estrellas',
    titulo: 'Estrella brillante',
    descripcion: 'Junta 50 estrellas',
    emoji: '💫',
    puntosBonus: 25,
    condicion: _cincuentaEstrellas,
  ),
  Logro(
    id: 'cien_estrellas',
    titulo: 'Maestro de estrellas',
    descripcion: 'Junta 100 estrellas',
    emoji: '✨',
    puntosBonus: 50,
    condicion: _cienEstrellas,
  ),
  Logro(
    id: 'racha_tres',
    titulo: 'En racha',
    descripcion: 'Acierta 3 seguidas',
    emoji: '🔥',
    puntosBonus: 10,
    condicion: _rachaTres,
  ),
  Logro(
    id: 'racha_cinco',
    titulo: 'Imparable',
    descripcion: 'Acierta 5 seguidas',
    emoji: '🚀',
    puntosBonus: 20,
    condicion: _rachaCinco,
  ),
  Logro(
    id: 'racha_diez',
    titulo: 'Súper imparable',
    descripcion: 'Acierta 10 seguidas',
    emoji: '⚡',
    puntosBonus: 40,
    condicion: _rachaDiez,
  ),
  Logro(
    id: 'tres_categorias',
    titulo: 'Curioso',
    descripcion: 'Juega 3 actividades distintas',
    emoji: '🧭',
    puntosBonus: 15,
    condicion: _tresCategorias,
  ),
  Logro(
    id: 'cinco_categorias',
    titulo: 'Explorador',
    descripcion: 'Juega 5 actividades distintas',
    emoji: '🗺️',
    puntosBonus: 25,
    condicion: _cincoCategorias,
  ),
  Logro(
    id: 'todas_categorias',
    titulo: 'Aventurero total',
    descripcion: 'Juega todas las actividades',
    emoji: '🏆',
    puntosBonus: 100,
    condicion: _todasCategorias,
  ),
  Logro(
    id: 'tres_dias',
    titulo: 'Constancia',
    descripcion: 'Juega 3 días distintos',
    emoji: '📅',
    puntosBonus: 20,
    condicion: _tresDias,
  ),
  Logro(
    id: 'siete_dias',
    titulo: 'Una semana',
    descripcion: 'Juega 7 días distintos',
    emoji: '🎯',
    puntosBonus: 50,
    condicion: _sieteDias,
  ),
  Logro(
    id: 'tiempo_30',
    titulo: 'Concentrado',
    descripcion: '30 minutos jugando en total',
    emoji: '⏰',
    puntosBonus: 15,
    condicion: _treintaMin,
  ),
  Logro(
    id: 'maestro_letras',
    titulo: 'Maestro de letras',
    descripcion: '20 estrellas en lectura o letras',
    emoji: '📚',
    puntosBonus: 30,
    condicion: _maestroLetras,
  ),
  Logro(
    id: 'maestro_numeros',
    titulo: 'Maestro de números',
    descripcion: '20 estrellas en matemáticas',
    emoji: '🔢',
    puntosBonus: 30,
    condicion: _maestroNumeros,
  ),
];

bool _primeraEstrella(PerfilStats s) => s.totalEstrellas >= 1;
bool _diezEstrellas(PerfilStats s) => s.totalEstrellas >= 10;
bool _cincuentaEstrellas(PerfilStats s) => s.totalEstrellas >= 50;
bool _cienEstrellas(PerfilStats s) => s.totalEstrellas >= 100;
bool _rachaTres(PerfilStats s) => s.rachaMaxima >= 3;
bool _rachaCinco(PerfilStats s) => s.rachaMaxima >= 5;
bool _rachaDiez(PerfilStats s) => s.rachaMaxima >= 10;
bool _tresCategorias(PerfilStats s) => s.categoriasJugadas.length >= 3;
bool _cincoCategorias(PerfilStats s) => s.categoriasJugadas.length >= 5;
bool _todasCategorias(PerfilStats s) => s.categoriasJugadas.length >= 10;
bool _tresDias(PerfilStats s) => s.diasJugados >= 3;
bool _sieteDias(PerfilStats s) => s.diasJugados >= 7;
bool _treintaMin(PerfilStats s) => s.totalSegundos >= 1800;
bool _maestroLetras(PerfilStats s) =>
    (s.estrellasPorCategoria['lectura'] ?? 0) +
        (s.estrellasPorCategoria['aprender_letras'] ?? 0) >=
    20;
bool _maestroNumeros(PerfilStats s) =>
    (s.estrellasPorCategoria['matematicas'] ?? 0) +
        (s.estrellasPorCategoria['aprender_numeros'] ?? 0) >=
    20;

class EvaluadorLogros {
  static PerfilStats _statsDe({
    required int totalEstrellas,
    required int totalSegundos,
    required int diasJugados,
    required int rachaMaxima,
    required Set<String> categoriasJugadas,
    required Map<String, int> estrellasPorCategoria,
  }) {
    return PerfilStats(
      totalEstrellas: totalEstrellas,
      totalSegundos: totalSegundos,
      diasJugados: diasJugados,
      rachaMaxima: rachaMaxima,
      categoriasJugadas: categoriasJugadas,
      estrellasPorCategoria: estrellasPorCategoria,
    );
  }

  static List<Logro> evaluarTodos({
    required int totalEstrellas,
    required int totalSegundos,
    required int diasJugados,
    required int rachaMaxima,
    required Set<String> categoriasJugadas,
    required Map<String, int> estrellasPorCategoria,
  }) {
    final stats = _statsDe(
      totalEstrellas: totalEstrellas,
      totalSegundos: totalSegundos,
      diasJugados: diasJugados,
      rachaMaxima: rachaMaxima,
      categoriasJugadas: categoriasJugadas,
      estrellasPorCategoria: estrellasPorCategoria,
    );
    return logrosDisponibles.where((l) => l.condicion(stats)).toList();
  }
}
