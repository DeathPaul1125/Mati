import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logros.dart';
import 'perfil.dart';

class PerfilesService extends ChangeNotifier {
  PerfilesService._();
  static final PerfilesService instancia = PerfilesService._();

  static const _keyPerfiles = 'perfiles_v1';
  static const _keyActivo = 'perfil_activo_v1';
  static const _keyPin = 'pin_padres_v1';
  static const _keyEstiloIconos = 'estilo_iconos_v1';
  static const _pinPorDefecto = '1234';
  static const estiloOpenMoji = 'openmoji';
  static const estiloTwemoji = 'twemoji';
  static const estiloFluent = 'fluent';

  List<Perfil> _perfiles = [];
  String? _activoId;
  bool _cargado = false;
  String _estiloIconos = estiloTwemoji;

  List<Perfil> get perfiles => List.unmodifiable(_perfiles);
  bool get cargado => _cargado;
  String get estiloIconos => _estiloIconos;

  Perfil? get activo {
    if (_activoId == null) return null;
    for (final p in _perfiles) {
      if (p.id == _activoId) return p;
    }
    return _perfiles.isNotEmpty ? _perfiles.first : null;
  }

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_keyPerfiles) ?? [];
    _perfiles = lista.map(Perfil.deserializar).toList();
    _activoId = prefs.getString(_keyActivo);
    _estiloIconos = prefs.getString(_keyEstiloIconos) ?? estiloFluent;
    // Ya no creamos un perfil por defecto: si la lista está vacía la app
    // muestra el onboarding la primera vez. Solo nos aseguramos de que
    // _activoId apunte a alguno cuando sí hay perfiles.
    if (_perfiles.isNotEmpty) {
      _activoId ??= _perfiles.first.id;
    }
    _cargado = true;
    notifyListeners();
  }

  Future<void> _persistir() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _keyPerfiles, _perfiles.map((p) => p.serializar()).toList());
    if (_activoId != null) {
      await prefs.setString(_keyActivo, _activoId!);
    }
  }

  Future<void> seleccionar(String id) async {
    _activoId = id;
    await _persistir();
    notifyListeners();
  }

  Future<void> agregar(Perfil p) async {
    _perfiles.add(p);
    await _persistir();
    notifyListeners();
  }

  Future<void> actualizar(Perfil p) async {
    final idx = _perfiles.indexWhere((x) => x.id == p.id);
    if (idx >= 0) {
      _perfiles[idx] = p;
      await _persistir();
      notifyListeners();
    }
  }

  Future<void> eliminar(String id) async {
    _perfiles.removeWhere((p) => p.id == id);
    if (_activoId == id) {
      _activoId = _perfiles.isNotEmpty ? _perfiles.first.id : null;
    }
    await _persistir();
    notifyListeners();
  }

  Future<void> registrarTiempoActivo(String categoria, int segundos) async {
    final p = activo;
    if (p == null || segundos <= 0) return;
    p.registrarTiempo(categoria, segundos);
    await _persistir();
    notifyListeners();
  }

  Future<List<Logro>> sumarEstrellaActivo(String categoria) async {
    final p = activo;
    if (p == null) return [];
    p.sumarEstrella(categoria);
    final nuevos = _evaluarLogrosNuevos(p);
    for (final l in nuevos) {
      p.logrosDesbloqueados.add(l.id);
      p.puntos += l.puntosBonus;
    }
    await _persistir();
    notifyListeners();
    return nuevos;
  }

  Future<void> romperRachaActivo() async {
    final p = activo;
    if (p == null) return;
    p.romperRacha();
    await _persistir();
    notifyListeners();
  }

  List<Logro> _evaluarLogrosNuevos(Perfil p) {
    final todos = EvaluadorLogros.evaluarTodos(
      totalEstrellas: p.totalEstrellas,
      totalSegundos: p.totalSegundos,
      diasJugados: p.diasJugados.length,
      rachaMaxima: p.rachaMaxima,
      categoriasJugadas: p.categoriasJugadas,
      estrellasPorCategoria: p.estrellas,
    );
    return todos
        .where((l) => !p.logrosDesbloqueados.contains(l.id))
        .toList();
  }

  Future<void> marcarTutorialVisto(String tutorial) async {
    final p = activo;
    if (p == null) return;
    if (p.tutorialesVistos.contains(tutorial)) return;
    p.tutorialesVistos.add(tutorial);
    await _persistir();
    notifyListeners();
  }

  Future<String> obtenerPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin) ?? _pinPorDefecto;
  }

  Future<void> establecerPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
  }

  Future<void> setEstiloIconos(String estilo) async {
    _estiloIconos = estilo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEstiloIconos, estilo);
    notifyListeners();
  }
}
