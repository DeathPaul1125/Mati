import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/juego_layout.dart';

class ColoresScreen extends StatefulWidget {
  const ColoresScreen({super.key});

  @override
  State<ColoresScreen> createState() => _ColoresScreenState();
}

class _ColorItem {
  final String clave;
  final String nombre;
  final Color color;
  const _ColorItem(this.clave, this.nombre, this.color);
}

class _ColoresScreenState extends State<ColoresScreen> {
  static const _colores = [
    _ColorItem('rojo', 'Rojo', Color(0xFFEF4444)),
    _ColorItem('azul', 'Azul', Color(0xFF3B82F6)),
    _ColorItem('verde', 'Verde', Color(0xFF22C55E)),
    _ColorItem('amarillo', 'Amarillo', Color(0xFFFCD34D)),
    _ColorItem('naranja', 'Naranja', Color(0xFFFB923C)),
    _ColorItem('morado', 'Morado', Color(0xFFA855F7)),
    _ColorItem('rosa', 'Rosa', Color(0xFFEC4899)),
    _ColorItem('negro', 'Negro', Color(0xFF1F2937)),
    _ColorItem('blanco', 'Blanco', Color(0xFFF9FAFB)),
    _ColorItem('cafe', 'Café', Color(0xFF92400E)),
  ];

  _ColorItem? _seleccionado;

  Future<void> _tocar(_ColorItem c) async {
    setState(() => _seleccionado = c);
    await AudioService.instancia.color(c.clave, c.nombre);
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Colores',
      categoria: 'aprender_colores',
      color: const Color(0xFFA855F7),
      simbolosTema: const ['●', '◆', '★'],
      audioInstruccion: 'instr_colores',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const Text(
              'Toca un color para escucharlo',
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
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _seleccionado!.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _seleccionado!.color
                                .withValues(alpha: 0.55),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        _seleccionado!.nombre,
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 30,
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
                  childAspectRatio: 1.05,
                ),
                itemCount: _colores.length,
                itemBuilder: (context, i) {
                  final c = _colores[i];
                  final activo = _seleccionado?.clave == c.clave;
                  return GestureDetector(
                    onTap: () => _tocar(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: c.color,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: activo ? Colors.white : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: c.color.withValues(alpha: 0.5),
                            blurRadius: activo ? 14 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c.nombre,
                          style: const TextStyle(
                            fontFamily: kFuente,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: KidsColors.texto,
                          ),
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
