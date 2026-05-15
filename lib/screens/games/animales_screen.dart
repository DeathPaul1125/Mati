import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class AnimalesScreen extends StatefulWidget {
  const AnimalesScreen({super.key});

  @override
  State<AnimalesScreen> createState() => _AnimalesScreenState();
}

class _Animal {
  final String clave;
  final String nombre;
  final String emoji;
  final Color color;
  const _Animal(this.clave, this.nombre, this.emoji, this.color);
}

class _AnimalesScreenState extends State<AnimalesScreen> {
  static const _animales = [
    _Animal('perro', 'Perro', '🐶', Color(0xFFCA9A6E)),
    _Animal('gato', 'Gato', '🐱', Color(0xFFD8A86F)),
    _Animal('raton', 'Ratón', '🐭', Color(0xFFA3A8B5)),
    _Animal('conejo', 'Conejo', '🐰', Color(0xFFE5C4B7)),
    _Animal('zorro', 'Zorro', '🦊', Color(0xFFFF8A65)),
    _Animal('oso', 'Oso', '🐻', Color(0xFF9C6F4A)),
    _Animal('panda', 'Panda', '🐼', Color(0xFF424242)),
    _Animal('leon', 'León', '🦁', Color(0xFFFFB74D)),
    _Animal('tigre', 'Tigre', '🐯', Color(0xFFFF9F45)),
    _Animal('elefante', 'Elefante', '🐘', Color(0xFF90A4AE)),
    _Animal('jirafa', 'Jirafa', '🦒', Color(0xFFFFD180)),
    _Animal('koala', 'Koala', '🐨', Color(0xFFB0BEC5)),
    _Animal('vaca', 'Vaca', '🐮', Color(0xFFE0E0E0)),
    _Animal('pollito', 'Pollito', '🐥', Color(0xFFFFD93D)),
    _Animal('mariposa', 'Mariposa', '🦋', Color(0xFF7E57C2)),
    _Animal('pez', 'Pez', '🐟', Color(0xFF42C8E2)),
    _Animal('pajaro', 'Pájaro', '🐦', Color(0xFF5B8DEF)),
    _Animal('abeja', 'Abeja', '🐝', Color(0xFFFCD34D)),
  ];

  _Animal? _seleccionado;

  Future<void> _tocar(_Animal a) async {
    setState(() => _seleccionado = a);
    await AudioService.instancia.animal(a.clave, a.nombre);
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Animales',
      categoria: 'aprender_animales',
      color: const Color(0xFFFF8A65),
      simbolosTema: const ['🐾', '🌿'],
      audioInstruccion: 'instr_animales',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const Text(
              'Toca un animal para escucharlo',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            if (_seleccionado != null) ...[
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: sombraSuave,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: _seleccionado!.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: IconKid(_seleccionado!.emoji, size: 64),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        _seleccionado!.nombre,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: KidsColors.texto,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _tocar(_seleccionado!),
                      icon: Icon(Icons.volume_up_rounded,
                          size: 34, color: _seleccionado!.color),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _animales.length,
                itemBuilder: (context, i) {
                  final a = _animales[i];
                  final activo = _seleccionado?.clave == a.clave;
                  return GestureDetector(
                    onTap: () => _tocar(a),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: activo ? a.color : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: activo ? sombraTarjeta : sombraSuave,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: a.color.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: IconKid(a.emoji, size: 88, sombra: true),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.nombre,
                            style: const TextStyle(
                              fontFamily: kFuente,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: KidsColors.texto,
                            ),
                          ),
                        ],
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
