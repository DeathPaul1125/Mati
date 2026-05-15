import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class AprenderLetrasScreen extends StatefulWidget {
  const AprenderLetrasScreen({super.key});

  @override
  State<AprenderLetrasScreen> createState() => _AprenderLetrasScreenState();
}

class _Letra {
  final String letra;
  final String palabra;
  final String emoji;
  const _Letra(this.letra, this.palabra, this.emoji);
}

class _AprenderLetrasScreenState extends State<AprenderLetrasScreen> {
  static const _letras = <_Letra>[
    _Letra('A', 'Árbol', '🌳'),
    _Letra('B', 'Banana', '🍌'),
    _Letra('C', 'Cachorro', '🐶'),
    _Letra('D', 'Dulce', '🍩'),
    _Letra('E', 'Elefante', '🐘'),
    _Letra('F', 'Fresa', '🍓'),
    _Letra('G', 'Gato', '🐱'),
    _Letra('H', 'Helado', '🍦'),
    _Letra('I', 'Iguana', '🦎'),
    _Letra('J', 'Jirafa', '🦒'),
    _Letra('K', 'Koala', '🐨'),
    _Letra('L', 'León', '🦁'),
    _Letra('M', 'Manzana', '🍎'),
    _Letra('N', 'Nube', '☁️'),
    _Letra('Ñ', 'Ñandú', '🦤'),
    _Letra('O', 'Oso', '🐻'),
    _Letra('P', 'Pizza', '🍕'),
    _Letra('Q', 'Queso', '🧀'),
    _Letra('R', 'Ratón', '🐭'),
    _Letra('S', 'Sol', '🌞'),
    _Letra('T', 'Tigre', '🐯'),
    _Letra('U', 'Uva', '🍇'),
    _Letra('V', 'Vaca', '🐮'),
    _Letra('W', 'Wifi', '📶'),
    _Letra('X', 'Xilófono', '🎵'),
    _Letra('Y', 'Yate', '⛵'),
    _Letra('Z', 'Zorro', '🦊'),
  ];

  _Letra? _seleccionada;

  Future<void> _tocar(_Letra l) async {
    setState(() => _seleccionada = l);
    await AudioService.instancia.letra(l.letra, palabraEjemplo: l.palabra);
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Letras',
      categoria: 'aprender_letras',
      color: KidsColors.lectura,
      simbolosTema: const ['A', 'B', 'C', 'a', 'b', 'c'],
      audioInstruccion: 'instr_letras_aprender',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            const Text(
              'Toca una letra para escucharla',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            if (_seleccionada != null) ...[
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: sombraSuave,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: gradienteCategoria(KidsColors.lectura),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _seleccionada!.letra,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    IconKid(_seleccionada!.emoji, size: 50),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _seleccionada!.palabra,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: KidsColors.texto,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _tocar(_seleccionada!),
                      icon: const Icon(Icons.volume_up_rounded,
                          size: 32, color: KidsColors.lectura),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _letras.length,
                itemBuilder: (context, i) {
                  final l = _letras[i];
                  final activa = _seleccionada?.letra == l.letra;
                  return GestureDetector(
                    onTap: () => _tocar(l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: activa
                            ? gradienteCategoria(KidsColors.lectura)
                            : null,
                        color: activa ? null : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: activa
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: activa ? sombraTarjeta : sombraSuave,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l.letra,
                        style: TextStyle(
                          fontFamily: kFuente,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color:
                              activa ? Colors.white : KidsColors.texto,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
