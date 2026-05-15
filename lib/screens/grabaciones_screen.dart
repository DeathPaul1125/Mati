import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/audio_service.dart';
import '../state/grabaciones_service.dart';
import '../theme.dart';

class FraseInfo {
  final String clave;
  final String texto;
  const FraseInfo(this.clave, this.texto);
}

class _Seccion {
  final String titulo;
  final IconData icono;
  final Color color;
  final List<FraseInfo> frases;
  const _Seccion(this.titulo, this.icono, this.color, this.frases);
}

const _secciones = <_Seccion>[
  _Seccion('Frases importantes', Icons.favorite_rounded, Color(0xFFEC407A), [
    FraseInfo('muy_bien', '¡Muy bien!'),
    FraseInfo('muy_bien_largo', '¡Excelente! ¡Lo lograste!'),
    FraseInfo('intentalo_otra_vez', 'Inténtalo otra vez.'),
    FraseInfo('hola', '¡Hola! ¿Vamos a jugar?'),
    FraseInfo('lo_encontraste', '¡Lo encontraste!'),
  ]),
  _Seccion('Instrucciones de juegos', Icons.school_rounded, Color(0xFF5B8DEF), [
    FraseInfo('instr_letras_aprender', 'Toca una letra para escucharla.'),
    FraseInfo('instr_numeros_aprender', 'Toca un número para escucharlo.'),
    FraseInfo('instr_colores', 'Toca un color para escucharlo.'),
    FraseInfo('instr_formas', 'Toca una forma para escucharla.'),
    FraseInfo('instr_animales', 'Toca un animal para escucharlo.'),
    FraseInfo('instr_donde_esta', 'Escucha y toca el dibujo correcto.'),
    FraseInfo('instr_contar', '¿Cuántos hay? Arrastra el número correcto.'),
    FraseInfo('instr_memoria', 'Encuentra las parejas.'),
    FraseInfo('instr_logica', '¿Cuál es diferente? Arrástralo a la papelera.'),
    FraseInfo('instr_lectura', '¿Con qué letra empieza?'),
    FraseInfo('instr_clasificar', 'Coloca cada cosa en su caja.'),
    FraseInfo('instr_sombras', 'Encuentra la sombra de cada dibujo.'),
    FraseInfo('instr_pintar', 'Pinta lo que tú quieras.'),
    FraseInfo('instr_trazar', 'Desliza el dedo sobre la letra.'),
  ]),
  _Seccion('Letras', Icons.text_fields_rounded, Color(0xFFFFAE3D), [
    FraseInfo('letra_a', 'A. Árbol'),
    FraseInfo('letra_b', 'B. Banana'),
    FraseInfo('letra_c', 'C. Cachorro'),
    FraseInfo('letra_d', 'D. Dulce'),
    FraseInfo('letra_e', 'E. Elefante'),
    FraseInfo('letra_f', 'F. Fresa'),
    FraseInfo('letra_g', 'G. Gato'),
    FraseInfo('letra_h', 'H. Helado'),
    FraseInfo('letra_i', 'I. Iguana'),
    FraseInfo('letra_j', 'J. Jirafa'),
    FraseInfo('letra_k', 'K. Koala'),
    FraseInfo('letra_l', 'L. León'),
    FraseInfo('letra_m', 'M. Manzana'),
    FraseInfo('letra_n', 'N. Nube'),
    FraseInfo('letra_nn', 'Ñ. Ñandú'),
    FraseInfo('letra_o', 'O. Oso'),
    FraseInfo('letra_p', 'P. Pizza'),
    FraseInfo('letra_q', 'Q. Queso'),
    FraseInfo('letra_r', 'R. Ratón'),
    FraseInfo('letra_s', 'S. Sol'),
    FraseInfo('letra_t', 'T. Tigre'),
    FraseInfo('letra_u', 'U. Uva'),
    FraseInfo('letra_v', 'V. Vaca'),
    FraseInfo('letra_w', 'W. Wifi'),
    FraseInfo('letra_x', 'X. Xilófono'),
    FraseInfo('letra_y', 'Y. Yate'),
    FraseInfo('letra_z', 'Z. Zorro'),
  ]),
  _Seccion('Números', Icons.tag_rounded, Color(0xFF7C4DFF), [
    FraseInfo('numero_1', '1. Uno'),
    FraseInfo('numero_2', '2. Dos'),
    FraseInfo('numero_3', '3. Tres'),
    FraseInfo('numero_4', '4. Cuatro'),
    FraseInfo('numero_5', '5. Cinco'),
    FraseInfo('numero_6', '6. Seis'),
    FraseInfo('numero_7', '7. Siete'),
    FraseInfo('numero_8', '8. Ocho'),
    FraseInfo('numero_9', '9. Nueve'),
    FraseInfo('numero_10', '10. Diez'),
  ]),
  _Seccion('Colores', Icons.palette_rounded, Color(0xFFA855F7), [
    FraseInfo('color_rojo', 'Rojo'),
    FraseInfo('color_azul', 'Azul'),
    FraseInfo('color_verde', 'Verde'),
    FraseInfo('color_amarillo', 'Amarillo'),
    FraseInfo('color_naranja', 'Naranja'),
    FraseInfo('color_morado', 'Morado'),
    FraseInfo('color_rosa', 'Rosa'),
    FraseInfo('color_negro', 'Negro'),
    FraseInfo('color_blanco', 'Blanco'),
    FraseInfo('color_cafe', 'Café'),
  ]),
  _Seccion('Formas', Icons.category_rounded, Color(0xFF22C55E), [
    FraseInfo('forma_circulo', 'Círculo'),
    FraseInfo('forma_cuadrado', 'Cuadrado'),
    FraseInfo('forma_triangulo', 'Triángulo'),
    FraseInfo('forma_estrella', 'Estrella'),
    FraseInfo('forma_corazon', 'Corazón'),
    FraseInfo('forma_rombo', 'Rombo'),
    FraseInfo('forma_rectangulo', 'Rectángulo'),
    FraseInfo('forma_ovalo', 'Óvalo'),
  ]),
  _Seccion('Animales', Icons.pets_rounded, Color(0xFFFF8A65), [
    FraseInfo('animal_perro', 'Perro'),
    FraseInfo('animal_gato', 'Gato'),
    FraseInfo('animal_raton', 'Ratón'),
    FraseInfo('animal_conejo', 'Conejo'),
    FraseInfo('animal_zorro', 'Zorro'),
    FraseInfo('animal_oso', 'Oso'),
    FraseInfo('animal_panda', 'Panda'),
    FraseInfo('animal_leon', 'León'),
    FraseInfo('animal_tigre', 'Tigre'),
    FraseInfo('animal_elefante', 'Elefante'),
    FraseInfo('animal_jirafa', 'Jirafa'),
    FraseInfo('animal_koala', 'Koala'),
    FraseInfo('animal_vaca', 'Vaca'),
    FraseInfo('animal_pollito', 'Pollito'),
    FraseInfo('animal_mariposa', 'Mariposa'),
    FraseInfo('animal_pez', 'Pez'),
    FraseInfo('animal_pajaro', 'Pájaro'),
    FraseInfo('animal_abeja', 'Abeja'),
  ]),
  _Seccion('¿Dónde está?', Icons.search_rounded, Color(0xFFFF8FB1), [
    FraseInfo('donde_perro', '¿Dónde está el perro?'),
    FraseInfo('donde_gato', '¿Dónde está el gato?'),
    FraseInfo('donde_conejo', '¿Dónde está el conejo?'),
    FraseInfo('donde_zorro', '¿Dónde está el zorro?'),
    FraseInfo('donde_oso', '¿Dónde está el oso?'),
    FraseInfo('donde_leon', '¿Dónde está el león?'),
    FraseInfo('donde_elefante', '¿Dónde está el elefante?'),
    FraseInfo('donde_mariposa', '¿Dónde está la mariposa?'),
    FraseInfo('donde_manzana', '¿Dónde está la manzana?'),
    FraseInfo('donde_banana', '¿Dónde está la banana?'),
    FraseInfo('donde_fresa', '¿Dónde está la fresa?'),
    FraseInfo('donde_pelota', '¿Dónde está la pelota?'),
    FraseInfo('donde_sol', '¿Dónde está el sol?'),
    FraseInfo('donde_luna', '¿Dónde está la luna?'),
    FraseInfo('donde_estrella', '¿Dónde está la estrella?'),
    FraseInfo('donde_flor', '¿Dónde está la flor?'),
    FraseInfo('donde_carro', '¿Dónde está el carro?'),
    FraseInfo('donde_avion', '¿Dónde está el avión?'),
  ]),
];

class GrabacionesScreen extends StatelessWidget {
  const GrabacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: GrabacionesService.instancia,
          builder: (context, _) {
            final grabadas = GrabacionesService.instancia.todasLasClaves.length;
            final total =
                _secciones.fold<int>(0, (a, s) => a + s.frases.length);
            return Column(
              children: [
                _Cabecera(grabadas: grabadas, total: total),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
                    children: _secciones
                        .map((s) => _SeccionExpandible(seccion: s))
                        .toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final int grabadas;
  final int total;
  const _Cabecera({required this.grabadas, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Material(
                color: const Color(0xFFF7F8FB),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.arrow_back_rounded,
                        color: KidsColors.texto, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Grabar mi voz',
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: KidsColors.texto,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: KidsColors.exito.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$grabadas / $total',
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: KidsColors.exito,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca 🎙️ para grabar tu voz para una frase. La voz que grabes reemplaza la voz del sistema cuando juegues. Toca 🗑 para volver a la voz del sistema.',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: KidsColors.textoSuave,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionExpandible extends StatelessWidget {
  final _Seccion seccion;
  const _SeccionExpandible({required this.seccion});

  @override
  Widget build(BuildContext context) {
    final hechas = seccion.frases
        .where((f) => GrabacionesService.instancia.tieneGrabacion(f.clave))
        .length;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: seccion.color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(seccion.icono, color: seccion.color, size: 22),
        ),
        title: Text(
          seccion.titulo,
          style: const TextStyle(
            fontFamily: kFuente,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: KidsColors.texto,
          ),
        ),
        subtitle: Text(
          '$hechas / ${seccion.frases.length} grabadas',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: hechas > 0 ? KidsColors.exito : KidsColors.textoSuave,
          ),
        ),
        children: seccion.frases
            .map((f) => _FilaFrase(frase: f, color: seccion.color))
            .toList(),
      ),
    );
  }
}

class _FilaFrase extends StatelessWidget {
  final FraseInfo frase;
  final Color color;
  const _FilaFrase({required this.frase, required this.color});

  Future<void> _grabar(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoGrabar(frase: frase, color: color),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grabación guardada'),
          backgroundColor: KidsColors.exito,
          duration: Duration(milliseconds: 1200),
        ),
      );
    }
  }

  Future<void> _escuchar() async {
    final path = GrabacionesService.instancia.rutaGrabacion(frase.clave);
    if (path != null) {
      await AudioService.instancia.reproducirArchivo(path);
    } else {
      await AudioService.instancia.reproducir('audio/${frase.clave}.mp3');
    }
  }

  Future<void> _borrar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Borrar grabación?'),
        content: Text(
            'Se restaurará la voz del sistema para "${frase.texto}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: KidsColors.error),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await GrabacionesService.instancia.borrarGrabacion(frase.clave);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiene = GrabacionesService.instancia.tieneGrabacion(frase.clave);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.15), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frase.texto,
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: KidsColors.texto,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      tiene ? Icons.mic_rounded : Icons.volume_up_rounded,
                      size: 14,
                      color: tiene ? KidsColors.exito : KidsColors.textoSuave,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tiene ? 'Tu voz' : 'Voz del sistema',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tiene
                            ? KidsColors.exito
                            : KidsColors.textoSuave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _BotonChico(
            icono: Icons.play_arrow_rounded,
            color: const Color(0xFF5B8DEF),
            onTap: _escuchar,
          ),
          const SizedBox(width: 4),
          _BotonChico(
            icono: Icons.mic_rounded,
            color: color,
            onTap: () => _grabar(context),
          ),
          if (tiene) ...[
            const SizedBox(width: 4),
            _BotonChico(
              icono: Icons.delete_outline_rounded,
              color: KidsColors.error,
              onTap: () => _borrar(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _BotonChico extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  const _BotonChico(
      {required this.icono, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icono, color: color, size: 20),
        ),
      ),
    );
  }
}

class _DialogoGrabar extends StatefulWidget {
  final FraseInfo frase;
  final Color color;
  const _DialogoGrabar({required this.frase, required this.color});

  @override
  State<_DialogoGrabar> createState() => _DialogoGrabarState();
}

class _DialogoGrabarState extends State<_DialogoGrabar> {
  bool _grabando = false;
  bool _terminado = false;
  DateTime? _inicio;
  Duration _duracion = Duration.zero;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _empezar();
      _tick();
    });
  }

  void _tick() async {
    while (mounted && _grabando) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _duracion = DateTime.now().difference(_inicio ?? DateTime.now());
      });
    }
  }

  Future<void> _empezar() async {
    final ok = await GrabacionesService.instancia
        .empezarGrabacion(widget.frase.clave);
    if (!mounted) return;
    if (!ok) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _grabando = true;
      _inicio = DateTime.now();
    });
  }

  Future<void> _parar() async {
    if (!_grabando) return;
    final ok = await GrabacionesService.instancia.detenerGrabacion();
    if (!mounted) return;
    setState(() {
      _grabando = false;
      _terminado = ok;
    });
  }

  Future<void> _escucharPreview() async {
    final path =
        GrabacionesService.instancia.rutaGrabacion(widget.frase.clave);
    if (path != null) {
      await AudioService.instancia.reproducirArchivo(path);
    }
  }

  Future<void> _descartar() async {
    if (_grabando) {
      await GrabacionesService.instancia.cancelarGrabacion();
    } else if (_terminado) {
      await GrabacionesService.instancia.borrarGrabacion(widget.frase.clave);
    }
    if (!mounted) return;
    Navigator.of(context).pop(false);
  }

  String _dur() {
    final s = _duracion.inSeconds;
    final ms = (_duracion.inMilliseconds % 1000) ~/ 100;
    return '${s.toString().padLeft(2, '0')}.$ms s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Grabando:',
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KidsColors.textoSuave,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '"${widget.frase.texto}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _grabando ? KidsColors.error : widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_grabando ? KidsColors.error : widget.color)
                        .withValues(alpha: 0.45),
                    blurRadius: _grabando ? 22 : 12,
                    spreadRadius: _grabando ? 4 : 0,
                  ),
                ],
              ),
              child: Icon(
                _grabando ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _grabando ? _dur() : (_terminado ? '¡Listo!' : 'Preparando…'),
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _grabando ? KidsColors.error : KidsColors.texto,
              ),
            ),
            const SizedBox(height: 18),
            if (_grabando)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _parar,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text(
                    'Parar',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KidsColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              )
            else if (_terminado) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _escucharPreview,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Escuchar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5B8DEF),
                        side: const BorderSide(
                            color: Color(0xFF5B8DEF), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _empezar();
                        _tick();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Regrabar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Guardar',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KidsColors.exito,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: _descartar,
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KidsColors.textoSuave,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
