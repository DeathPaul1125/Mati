import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();
  static final TtsService instancia = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _listo = false;

  Future<void> _inicializar() async {
    if (_listo) return;
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
    _listo = true;
  }

  Future<void> hablar(String texto) async {
    await _inicializar();
    await _tts.stop();
    await _tts.speak(texto);
  }

  Future<void> detener() async {
    await _tts.stop();
  }
}
