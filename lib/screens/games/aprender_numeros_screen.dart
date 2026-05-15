import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class AprenderNumerosScreen extends StatefulWidget {
  const AprenderNumerosScreen({super.key});

  @override
  State<AprenderNumerosScreen> createState() =>
      _AprenderNumerosScreenState();
}

class _AprenderNumerosScreenState extends State<AprenderNumerosScreen> {
  static const _palabras = [
    '',
    'uno', 'dos', 'tres', 'cuatro', 'cinco',
    'seis', 'siete', 'ocho', 'nueve', 'diez',
  ];

  static const _emojis = [
    '🍎', '🎈', '⭐', '🌸', '🦋',
    '🍓', '🐝', '🍒', '🌟', '🐠',
  ];

  int? _seleccionado;

  Future<void> _tocar(int n) async {
    setState(() => _seleccionado = n);
    await AudioService.instancia.numero(n);
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  String _emojiPara(int n) => _emojis[(n - 1) % _emojis.length];

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Números',
      categoria: 'aprender_numeros',
      color: KidsColors.matematicas,
      simbolosTema: const ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
      audioInstruccion: 'instr_numeros_aprender',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          children: [
            const Text(
              'Toca un número para escucharlo',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(height: 10),
            if (_seleccionado != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: sombraSuave,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: gradienteCategoria(
                                KidsColors.matematicas),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$_seleccionado',
                            style: const TextStyle(
                              fontFamily: kFuente,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _palabras[_seleccionado!],
                          style: const TextStyle(
                            fontFamily: kFuente,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: KidsColors.texto,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: () => _tocar(_seleccionado!),
                          icon: const Icon(Icons.volume_up_rounded,
                              size: 32,
                              color: KidsColors.matematicas),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: List.generate(
                        _seleccionado!,
                        (_) => IconKid(_emojiPara(_seleccionado!),
                            size: 36),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: 10,
                itemBuilder: (context, i) {
                  final n = i + 1;
                  final activa = _seleccionado == n;
                  return GestureDetector(
                    onTap: () => _tocar(n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: activa
                            ? gradienteCategoria(KidsColors.matematicas)
                            : null,
                        color: activa ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: activa ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: activa ? sombraTarjeta : sombraSuave,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontFamily: kFuente,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: activa ? Colors.white : KidsColors.texto,
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
