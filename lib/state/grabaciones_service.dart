import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class GrabacionesService extends ChangeNotifier {
  GrabacionesService._();
  static final GrabacionesService instancia = GrabacionesService._();

  final AudioRecorder _recorder = AudioRecorder();
  Directory? _dir;
  final Set<String> _clavesGrabadas = {};
  String? _grabandoClave;
  DateTime? _inicioGrabacion;

  String? get grabandoClave => _grabandoClave;
  Duration get duracionGrabacion =>
      _inicioGrabacion == null ? Duration.zero : DateTime.now().difference(_inicioGrabacion!);

  Future<void> inicializar() async {
    final docs = await getApplicationDocumentsDirectory();
    _dir = Directory('${docs.path}/grabaciones');
    if (!_dir!.existsSync()) _dir!.createSync(recursive: true);
    for (final f in _dir!.listSync()) {
      if (f is File && f.path.endsWith('.m4a')) {
        final nombre = f.uri.pathSegments.last.replaceAll('.m4a', '');
        _clavesGrabadas.add(nombre);
      }
    }
  }

  bool tieneGrabacion(String clave) => _clavesGrabadas.contains(clave);

  String? rutaGrabacion(String clave) {
    if (_dir == null || !tieneGrabacion(clave)) return null;
    return '${_dir!.path}/$clave.m4a';
  }

  Future<bool> puedeGrabar() async {
    return _recorder.hasPermission();
  }

  Future<bool> empezarGrabacion(String clave) async {
    if (_dir == null) await inicializar();
    final permitido = await _recorder.hasPermission();
    if (!permitido) return false;
    final path = '${_dir!.path}/$clave.m4a';
    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      _grabandoClave = clave;
      _inicioGrabacion = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Error iniciando grabación: $e');
      }
      return false;
    }
  }

  Future<bool> detenerGrabacion() async {
    if (_grabandoClave == null) return false;
    try {
      final path = await _recorder.stop();
      if (path != null) {
        _clavesGrabadas.add(_grabandoClave!);
      }
      _grabandoClave = null;
      _inicioGrabacion = null;
      notifyListeners();
      return path != null;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Error deteniendo grabación: $e');
      }
      _grabandoClave = null;
      _inicioGrabacion = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> cancelarGrabacion() async {
    if (_grabandoClave == null) return;
    try {
      await _recorder.cancel();
    } catch (_) {}
    _grabandoClave = null;
    _inicioGrabacion = null;
    notifyListeners();
  }

  Future<void> borrarGrabacion(String clave) async {
    final path = rutaGrabacion(clave);
    if (path == null) return;
    try {
      final f = File(path);
      if (f.existsSync()) await f.delete();
    } catch (_) {}
    _clavesGrabadas.remove(clave);
    notifyListeners();
  }

  Set<String> get todasLasClaves => Set.unmodifiable(_clavesGrabadas);
}
