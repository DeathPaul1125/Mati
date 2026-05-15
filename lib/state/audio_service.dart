import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'grabaciones_service.dart';

class AudioService {
  AudioService._();
  static final AudioService instancia = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _ttsFallback = FlutterTts();
  bool _ttsListo = false;
  bool _playerListo = false;

  Future<void> _inicializarPlayer() async {
    if (_playerListo) return;
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(1.0);
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    _playerListo = true;
  }

  Future<void> reproducir(String assetFile, {String? textoFallback}) async {
    try {
      await _inicializarPlayer();
      await _player.stop();

      // 1) Si hay grabación del usuario para esta clave, úsala
      final clave = assetFile
          .replaceAll('audio/', '')
          .replaceAll('.mp3', '');
      final rutaUser = GrabacionesService.instancia.rutaGrabacion(clave);
      if (rutaUser != null) {
        await _player.play(
          DeviceFileSource(rutaUser),
          volume: 1.0,
          mode: PlayerMode.mediaPlayer,
        );
        return;
      }

      // 2) Si no, usa el asset bundleado
      await _player.play(
        AssetSource(assetFile),
        volume: 1.0,
        mode: PlayerMode.mediaPlayer,
      );
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AudioService error reproduciendo $assetFile: $e\n$st');
      }
      if (textoFallback != null) {
        await hablar(textoFallback);
      }
    }
  }

  Future<void> reproducirArchivo(String path) async {
    try {
      await _inicializarPlayer();
      await _player.stop();
      await _player.play(
        DeviceFileSource(path),
        volume: 1.0,
        mode: PlayerMode.mediaPlayer,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Error reproduciendo archivo $path: $e');
      }
    }
  }

  Future<void> letra(String letra, {String? palabraEjemplo}) async {
    final fallback = palabraEjemplo != null
        ? '$letra. $palabraEjemplo'
        : letra;
    await reproducir(
      'audio/letra_${_claveLetra(letra)}.mp3',
      textoFallback: fallback,
    );
  }

  Future<void> numero(int n) async {
    if (n < 1 || n > 10) {
      await hablar('$n');
      return;
    }
    const palabras = ['', 'uno', 'dos', 'tres', 'cuatro', 'cinco',
        'seis', 'siete', 'ocho', 'nueve', 'diez'];
    await reproducir(
      'audio/numero_$n.mp3',
      textoFallback: '$n. ${palabras[n]}',
    );
  }

  Future<void> color(String clave, String nombre) async {
    await reproducir('audio/color_$clave.mp3', textoFallback: nombre);
  }

  Future<void> forma(String clave, String nombre) async {
    await reproducir('audio/forma_$clave.mp3', textoFallback: nombre);
  }

  Future<void> animal(String clave, String nombre) async {
    await reproducir('audio/animal_$clave.mp3', textoFallback: nombre);
  }

  Future<void> dondeEsta(String clave, String nombre) async {
    await reproducir(
      'audio/donde_$clave.mp3',
      textoFallback: '¿Dónde está $nombre?',
    );
  }

  Future<void> frase(String clave) async {
    await reproducir('audio/$clave.mp3');
  }

  Future<void> muyBien() => frase('muy_bien');
  Future<void> intentalo() => frase('intentalo_otra_vez');

  Future<void> hablar(String texto) async {
    try {
      await _inicializarTts();
      await _ttsFallback.stop();
      await _ttsFallback.speak(texto);
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('TTS fallback falló: $e');
      }
    }
  }

  Future<void> _inicializarTts() async {
    if (_ttsListo) return;
    await _ttsFallback.setLanguage('es-MX');
    await _ttsFallback.setSpeechRate(0.45);
    await _ttsFallback.setPitch(1.1);
    _ttsListo = true;
  }

  Future<void> detener() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _ttsFallback.stop();
    } catch (_) {}
  }

  String _claveLetra(String l) {
    final c = l.toLowerCase();
    if (c == 'ñ') return 'nn';
    return c;
  }
}
