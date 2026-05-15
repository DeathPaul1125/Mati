import 'package:flutter/material.dart';

class Jugador {
  final String nombre;
  final String emoji;
  final Color color;
  const Jugador(this.nombre, this.emoji, this.color);
}

const jugadorMatias = Jugador('Matías', '🦊', Color(0xFFFF8A65));
const jugadorMichelle = Jugador('Michelle', '🌸', Color(0xFFE984D2));

class Jugadores extends ChangeNotifier {
  Jugadores._();
  static final Jugadores instancia = Jugadores._();

  bool _multijugador = false;
  int _turno = 0;
  final Map<String, int> _estrellas = {
    jugadorMatias.nombre: 0,
    jugadorMichelle.nombre: 0,
  };

  bool get multijugador => _multijugador;
  Jugador get activo =>
      _multijugador && _turno % 2 == 1 ? jugadorMichelle : jugadorMatias;
  int estrellasDe(Jugador j) => _estrellas[j.nombre] ?? 0;
  int estrellasActivo() => estrellasDe(activo);

  void toggleMultijugador() {
    _multijugador = !_multijugador;
    _turno = 0;
    notifyListeners();
  }

  void reiniciarRonda() {
    _turno = 0;
    notifyListeners();
  }

  void sumarYPasarTurno() {
    _estrellas[activo.nombre] = (_estrellas[activo.nombre] ?? 0) + 1;
    if (_multijugador) _turno++;
    notifyListeners();
  }
}
