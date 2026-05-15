import 'dart:async';
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
  Completer<void>? _playerCompleter;

  Future<void> _inicializarPlayer() async {
    if (_playerListo) return;
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(1.0);
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    // Escuchar el estado para resolver el completer al terminar el audio.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed || state == PlayerState.stopped) {
        final c = _playerCompleter;
        if (c != null && !c.isCompleted) c.complete();
      }
    });
    _playerListo = true;
  }

  Future<void> reproducir(String assetFile, {String? textoFallback}) async {
    try {
      await _inicializarPlayer();
      // Si había algo sonando, resolvemos su completer antes de interrumpir.
      final previo = _playerCompleter;
      if (previo != null && !previo.isCompleted) previo.complete();
      await _player.stop();

      // 1) Si hay grabación del usuario para esta clave, úsala
      final clave = assetFile
          .replaceAll('audio/', '')
          .replaceAll('.mp3', '');
      final rutaUser = GrabacionesService.instancia.rutaGrabacion(clave);

      _playerCompleter = Completer<void>();
      if (rutaUser != null) {
        await _player.play(
          DeviceFileSource(rutaUser),
          volume: 1.0,
          mode: PlayerMode.mediaPlayer,
        );
      } else {
        // 2) Si no, usa el asset bundleado
        await _player.play(
          AssetSource(assetFile),
          volume: 1.0,
          mode: PlayerMode.mediaPlayer,
        );
      }
      // Esperar a que termine el audio (o sea interrumpido).
      await _playerCompleter!.future;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('AudioService error reproduciendo $assetFile: $e\n$st');
      }
      // Liberar completer si quedó pendiente.
      final c = _playerCompleter;
      if (c != null && !c.isCompleted) c.complete();
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
    // El fallback dice solo la palabra (antes decía "2. dos" → sonaba duplicado).
    await reproducir(
      'audio/numero_$n.mp3',
      textoFallback: palabras[n],
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
    // Que speak() devuelva la promesa cuando termina de hablar, no antes.
    await _ttsFallback.awaitSpeakCompletion(true);
    _ttsListo = true;
  }

  // ---------------------------------------------------------------------
  // Helpers para evitar que "¡Muy bien!" se solape con la palabra final.
  // Reproduce muyBien, espera que termine, y luego dice el texto/letra/número.
  // ---------------------------------------------------------------------

  Future<void> celebrarYDecir(String texto) async {
    await muyBien();
    await hablar(texto);
  }

  Future<void> celebrarYLetra(String letra, {String? palabraEjemplo}) async {
    await muyBien();
    await this.letra(letra, palabraEjemplo: palabraEjemplo);
  }

  Future<void> celebrarConNumero(int n) async {
    await muyBien();
    await numero(n);
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
