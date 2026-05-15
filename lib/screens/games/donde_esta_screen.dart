import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../state/jugadores.dart';
import '../../state/perfiles_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class DondeEstaScreen extends StatefulWidget {
  const DondeEstaScreen({super.key});

  @override
  State<DondeEstaScreen> createState() => _DondeEstaScreenState();
}

class _Objeto {
  final String clave;
  final String nombre;
  final String emoji;
  final Color color;
  const _Objeto(this.clave, this.nombre, this.emoji, this.color);
}

class _DondeEstaScreenState extends State<DondeEstaScreen> {
  static const _objetos = [
    _Objeto('perro', 'el perro', '🐶', Color(0xFFCA9A6E)),
    _Objeto('gato', 'el gato', '🐱', Color(0xFFD8A86F)),
    _Objeto('conejo', 'el conejo', '🐰', Color(0xFFE5C4B7)),
    _Objeto('zorro', 'el zorro', '🦊', Color(0xFFFF8A65)),
    _Objeto('oso', 'el oso', '🐻', Color(0xFF9C6F4A)),
    _Objeto('leon', 'el león', '🦁', Color(0xFFFFB74D)),
    _Objeto('elefante', 'el elefante', '🐘', Color(0xFF90A4AE)),
    _Objeto('mariposa', 'la mariposa', '🦋', Color(0xFF7E57C2)),
    _Objeto('manzana', 'la manzana', '🍎', Color(0xFFE53935)),
    _Objeto('banana', 'la banana', '🍌', Color(0xFFFDD835)),
    _Objeto('fresa', 'la fresa', '🍓', Color(0xFFD32F2F)),
    _Objeto('pelota', 'la pelota', '🎈', Color(0xFFEC407A)),
    _Objeto('sol', 'el sol', '🌞', Color(0xFFFFB300)),
    _Objeto('luna', 'la luna', '🌙', Color(0xFF7986CB)),
    _Objeto('estrella', 'la estrella', '⭐', Color(0xFFFFC107)),
    _Objeto('flor', 'la flor', '🌹', Color(0xFFE91E63)),
    _Objeto('carro', 'el carro', '🚗', Color(0xFF42A5F5)),
    _Objeto('avion', 'el avión', '✈️', Color(0xFF5C6BC0)),
  ];

  final _rng = Random();
  late _Objeto _correcto;
  late List<_Objeto> _opciones;
  String? _previo;

  @override
  void initState() {
    super.initState();
    _nuevaRonda();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 700), _reproducirPregunta);
    });
  }

  void _nuevaRonda() {
    final edad = PerfilesService.instancia.activo?.edad ?? 4;
    final cantidadOpciones = edad <= 3 ? 2 : (edad <= 5 ? 3 : 4);

    var intentos = 0;
    do {
      _correcto = _objetos[_rng.nextInt(_objetos.length)];
      intentos++;
    } while (_correcto.clave == _previo && intentos < 5);
    _previo = _correcto.clave;

    final restantes = _objetos.where((o) => o.clave != _correcto.clave).toList()
      ..shuffle(_rng);
    _opciones = [_correcto, ...restantes.take(cantidadOpciones - 1)]
      ..shuffle(_rng);
  }

  void _reproducirPregunta() {
    AudioService.instancia.dondeEsta(_correcto.clave, _correcto.nombre);
  }

  Future<void> _tocar(_Objeto o) async {
    if (o.clave != _correcto.clave) {
      AudioService.instancia.intentalo();
      mostrarErrorSuave(context);
      return;
    }
    Jugadores.instancia.sumarYPasarTurno();
    PerfilesService.instancia.sumarEstrellaActivo('donde_esta');
    await AudioService.instancia.frase('lo_encontraste');
    if (!mounted) return;
    await mostrarCelebracion(context, subtitulo: '¡Era ${_correcto.nombre}!');
    if (!mounted) return;
    setState(_nuevaRonda);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _reproducirPregunta();
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: '¿Dónde está?',
      categoria: 'donde_esta',
      color: const Color(0xFFFF8FB1),
      simbolosTema: const ['❓', '👀', '👶'],
      audioInstruccion: 'instr_donde_esta',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _reproducirPregunta,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: sombraTarjeta,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8FB1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.volume_up_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tócame para escuchar',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: KidsColors.texto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  children: _opciones
                      .map((o) => _OpcionTarjeta(
                            objeto: o,
                            onTap: () => _tocar(o),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionTarjeta extends StatelessWidget {
  final _Objeto objeto;
  final VoidCallback onTap;

  const _OpcionTarjeta({required this.objeto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: objeto.color.withValues(alpha: 0.30),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: objeto.color.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: IconKid(objeto.emoji, size: 110, sombra: true),
      ),
    );
  }
}
