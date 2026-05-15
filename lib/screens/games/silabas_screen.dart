import 'package:flutter/material.dart';
import '../../state/audio_service.dart';
import '../../theme.dart';
import '../../widgets/icon_kid.dart';
import '../../widgets/juego_layout.dart';

class SilabasScreen extends StatefulWidget {
  const SilabasScreen({super.key});

  @override
  State<SilabasScreen> createState() => _SilabasScreenState();
}

class _Silaba {
  final String silaba;
  final String? ejemplo;
  final String? emoji;
  const _Silaba(this.silaba, [this.ejemplo, this.emoji]);
}

class _Consonante {
  final String letra;
  final Color color;
  final List<_Silaba> silabas;
  const _Consonante(this.letra, this.color, this.silabas);
}

class _SilabasScreenState extends State<SilabasScreen> {
  static const _consonantes = <_Consonante>[
    _Consonante('M', Color(0xFFFF6B7A), [
      _Silaba('MA', 'Mariposa', '🦋'),
      _Silaba('ME', 'Media', '🧦'),
      _Silaba('MI', 'Miel', '🍯'),
      _Silaba('MO', 'Moto', '🛵'),
      _Silaba('MU', 'Música', '🎵'),
    ]),
    _Consonante('P', Color(0xFF5B8DEF), [
      _Silaba('PA', 'Papa', '🥔'),
      _Silaba('PE', 'Perro', '🐶'),
      _Silaba('PI', 'Piña', '🍍'),
      _Silaba('PO', 'Pollito', '🐥'),
      _Silaba('PU', 'Pulpo', '🐙'),
    ]),
    _Consonante('S', Color(0xFF22C55E), [
      _Silaba('SA', 'Sandía', '🍉'),
      _Silaba('SE', 'Semilla', '🌱'),
      _Silaba('SI', 'Silla', '🪑'),
      _Silaba('SO', 'Sol', '🌞'),
      _Silaba('SU', 'Suma', '➕'),
    ]),
    _Consonante('L', Color(0xFFA855F7), [
      _Silaba('LA', 'Lagarto', '🦎'),
      _Silaba('LE', 'León', '🦁'),
      _Silaba('LI', 'Libro', '📚'),
      _Silaba('LO', 'Locomotora', '🚂'),
      _Silaba('LU', 'Luna', '🌙'),
    ]),
    _Consonante('G', Color(0xFFFFAE3D), [
      _Silaba('GA', 'Gato', '🐱'),
      _Silaba('GE', 'Gente', '👤'),
      _Silaba('GI', 'Gimnasta', '🤸'),
      _Silaba('GO', 'Gorra', '🧢'),
      _Silaba('GU', 'Gusano', '🐛'),
    ]),
  ];

  int _consonanteIdx = 0;
  _Silaba? _seleccionada;

  _Consonante get _consonante => _consonantes[_consonanteIdx];

  Future<void> _tocar(_Silaba s) async {
    setState(() => _seleccionada = s);
    final ejemplo = s.ejemplo;
    final texto = ejemplo != null ? '${s.silaba}. de $ejemplo' : s.silaba;
    await AudioService.instancia.hablar(texto);
  }

  void _cambiarConsonante(int i) {
    setState(() {
      _consonanteIdx = i;
      _seleccionada = null;
    });
  }

  @override
  void dispose() {
    AudioService.instancia.detener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JuegoLayout(
      titulo: 'Sílabas',
      categoria: 'lectura',
      color: _consonante.color,
      simbolosTema: const ['ma', 'pe', 'si', 'lo', 'gu'],
      audioInstruccion: 'instr_silabas',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          children: [
            _TabsConsonantes(
              consonantes: _consonantes,
              indice: _consonanteIdx,
              onTap: _cambiarConsonante,
            ),
            const SizedBox(height: 10),
            if (_seleccionada != null)
              _TarjetaEjemplo(
                silaba: _seleccionada!,
                color: _consonante.color,
                onRepetir: () => _tocar(_seleccionada!),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                shrinkWrap: true,
                children: [
                  for (final s in _consonante.silabas)
                    _CardSilaba(
                      silaba: s,
                      color: _consonante.color,
                      activa: _seleccionada?.silaba == s.silaba,
                      onTap: () => _tocar(s),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsConsonantes extends StatelessWidget {
  final List<_Consonante> consonantes;
  final int indice;
  final ValueChanged<int> onTap;
  const _TabsConsonantes({
    required this.consonantes,
    required this.indice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < consonantes.length; i++)
          GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: i == indice
                    ? gradienteCategoria(consonantes[i].color)
                    : null,
                color: i == indice ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: i == indice
                      ? Colors.white
                      : consonantes[i].color.withValues(alpha: 0.4),
                  width: 3,
                ),
                boxShadow: i == indice ? sombraTarjeta : sombraSuave,
              ),
              alignment: Alignment.center,
              child: Text(
                consonantes[i].letra,
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: i == indice ? Colors.white : consonantes[i].color,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TarjetaEjemplo extends StatelessWidget {
  final _Silaba silaba;
  final Color color;
  final VoidCallback onRepetir;
  const _TarjetaEjemplo({
    required this.silaba,
    required this.color,
    required this.onRepetir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: sombraSuave,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: gradienteCategoria(color),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              silaba.silaba,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (silaba.emoji != null) ...[
            IconKid(silaba.emoji!, size: 50),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              silaba.ejemplo ?? '¡Es la sílaba ${silaba.silaba}!',
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
          ),
          IconButton(
            onPressed: onRepetir,
            icon: Icon(Icons.volume_up_rounded, color: color, size: 30),
          ),
        ],
      ),
    );
  }
}

class _CardSilaba extends StatelessWidget {
  final _Silaba silaba;
  final Color color;
  final bool activa;
  final VoidCallback onTap;
  const _CardSilaba({
    required this.silaba,
    required this.color,
    required this.activa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: activa ? gradienteCategoria(color) : null,
          color: activa ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: activa ? Colors.white : color.withValues(alpha: 0.4),
            width: 3,
          ),
          boxShadow: activa ? sombraTarjeta : sombraSuave,
        ),
        alignment: Alignment.center,
        child: Text(
          silaba.silaba,
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: activa ? Colors.white : color,
            letterSpacing: 2,
            shadows: activa
                ? const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
