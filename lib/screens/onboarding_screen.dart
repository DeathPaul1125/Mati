import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/perfil.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/fondo_decorativo.dart';
import '../widgets/icon_kid.dart';
import 'home_screen.dart';

/// Wizard que aparece la PRIMERA vez que se instala la app.
/// Pide nombre, edad, género, color favorito y mascota.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _paginas = PageController();
  static const _totalPasos = 5;
  int _paso = 0;

  // Datos recolectados
  final _nombreCtrl = TextEditingController();
  int _edad = 4;
  String? _genero; // 'nino' | 'nina'
  int _colorValor = coloresPerfilesDisponibles.first;
  String _avatar = '🦊';

  @override
  void dispose() {
    _paginas.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  bool _pasoActualValido() {
    switch (_paso) {
      case 0:
        return _nombreCtrl.text.trim().isNotEmpty;
      case 1:
        return true; // edad siempre tiene valor
      case 2:
        return true; // género opcional
      case 3:
        return true; // color preseleccionado
      case 4:
        return true; // avatar preseleccionado
      default:
        return true;
    }
  }

  void _adelante() {
    if (!_pasoActualValido()) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text(
            'Escribí un nombre para continuar',
            style: TextStyle(fontFamily: kFuente, fontWeight: FontWeight.w800),
          ),
          backgroundColor: Color(0xFFFF9F45),
          behavior: SnackBarBehavior.floating,
        ));
      return;
    }
    if (_paso < _totalPasos - 1) {
      _paginas.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finalizar();
    }
  }

  void _atras() {
    if (_paso > 0) {
      _paginas.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finalizar() async {
    final perfil = Perfil(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreCtrl.text.trim(),
      edad: _edad,
      avatar: _avatar,
      colorValor: _colorValor,
      genero: _genero,
    );
    await PerfilesService.instancia.agregar(perfil);
    await PerfilesService.instancia.seleccionar(perfil.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_colorValor);
    return Scaffold(
      body: FondoDecorativo(
        colores: [
          Color.lerp(color, Colors.white, 0.78)!,
          Color.lerp(color, Colors.white, 0.55)!,
        ],
        cantidadEstrellas: 12,
        child: SafeArea(
          child: Column(
            children: [
              _PuntosProgreso(paso: _paso, total: _totalPasos, color: color),
              const SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _paginas,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _paso = i),
                  children: [
                    _PaginaNombre(controller: _nombreCtrl, color: color),
                    _PaginaEdad(
                      edad: _edad,
                      color: color,
                      onChange: (e) => setState(() => _edad = e),
                    ),
                    _PaginaGenero(
                      genero: _genero,
                      color: color,
                      onChange: (g) => setState(() {
                        _genero = g;
                        // Sugerir un avatar/color razonable
                        if (g == 'nino' && _avatar == '🦊') {
                          _avatar = '🦊';
                        } else if (g == 'nina' && _avatar == '🦊') {
                          _avatar = '🐱';
                        }
                      }),
                    ),
                    _PaginaColor(
                      colorValor: _colorValor,
                      onChange: (c) => setState(() => _colorValor = c),
                    ),
                    _PaginaAvatar(
                      avatar: _avatar,
                      color: color,
                      onChange: (a) => setState(() => _avatar = a),
                    ),
                  ],
                ),
              ),
              _BotonesNav(
                paso: _paso,
                total: _totalPasos,
                color: color,
                onAtras: _atras,
                onSiguiente: _adelante,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== Header con puntitos de progreso ==============

class _PuntosProgreso extends StatelessWidget {
  final int paso;
  final int total;
  final Color color;
  const _PuntosProgreso({
    required this.paso,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == paso ? 24 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i <= paso ? color : color.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
        ],
      ),
    );
  }
}

// ============== Botones de navegación ==============

class _BotonesNav extends StatelessWidget {
  final int paso;
  final int total;
  final Color color;
  final VoidCallback onAtras;
  final VoidCallback onSiguiente;

  const _BotonesNav({
    required this.paso,
    required this.total,
    required this.color,
    required this.onAtras,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    final esUltimo = paso == total - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (paso > 0)
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              elevation: 4,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: onAtras,
                borderRadius: BorderRadius.circular(28),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Icon(Icons.arrow_back_rounded,
                      color: KidsColors.texto, size: 24),
                ),
              ),
            ),
          const Spacer(),
          Material(
            color: color,
            borderRadius: BorderRadius.circular(28),
            elevation: 6,
            shadowColor: Colors.black38,
            child: InkWell(
              onTap: onSiguiente,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      esUltimo ? '¡Listo!' : 'Siguiente',
                      style: const TextStyle(
                        fontFamily: kFuente,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      esUltimo
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Página 1: Nombre ==============

class _PaginaNombre extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  const _PaginaNombre({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¡Hola! 👋',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '¿Cómo te llamas?',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KidsColors.textoSuave,
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: KidsColors.texto,
            ),
            decoration: InputDecoration(
              hintText: 'Mi nombre',
              hintStyle: TextStyle(
                fontFamily: kFuente,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: KidsColors.textoSuave.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: color, width: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Página 2: Edad ==============

class _PaginaEdad extends StatelessWidget {
  final int edad;
  final Color color;
  final ValueChanged<int> onChange;
  const _PaginaEdad({
    required this.edad,
    required this.color,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const Text(
            '¿Cuántos años tienes?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (var e = 2; e <= 10; e++)
                    _BotonEdad(
                      edad: e,
                      seleccionado: e == edad,
                      color: color,
                      onTap: () => onChange(e),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonEdad extends StatelessWidget {
  final int edad;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;
  const _BotonEdad({
    required this.edad,
    required this.seleccionado,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: seleccionado ? gradienteCategoria(color) : null,
          color: seleccionado ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: seleccionado ? Colors.white : color.withValues(alpha: 0.35),
            width: 3,
          ),
          boxShadow: seleccionado ? sombraTarjeta : sombraSuave,
        ),
        alignment: Alignment.center,
        child: Text(
          '$edad',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: seleccionado ? Colors.white : KidsColors.texto,
          ),
        ),
      ),
    );
  }
}

// ============== Página 3: Género ==============

class _PaginaGenero extends StatelessWidget {
  final String? genero;
  final Color color;
  final ValueChanged<String?> onChange;
  const _PaginaGenero({
    required this.genero,
    required this.color,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const Text(
            '¿Eres niño o niña?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _CardGenero(
                    titulo: 'Niño',
                    emoji: '👦',
                    color: const Color(0xFF5B8DEF),
                    seleccionado: genero == 'nino',
                    onTap: () => onChange('nino'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CardGenero(
                    titulo: 'Niña',
                    emoji: '👧',
                    color: const Color(0xFFE94B86),
                    seleccionado: genero == 'nina',
                    onTap: () => onChange('nina'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => onChange(null),
            child: Text(
              'Prefiero no decirlo',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: genero == null ? color : KidsColors.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardGenero extends StatelessWidget {
  final String titulo;
  final String emoji;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _CardGenero({
    required this.titulo,
    required this.emoji,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          gradient: seleccionado ? gradienteCategoria(color) : null,
          color: seleccionado ? null : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: seleccionado ? Colors.white : color.withValues(alpha: 0.30),
            width: 3,
          ),
          boxShadow: seleccionado ? sombraTarjeta : sombraSuave,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 96)),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: seleccionado ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============== Página 4: Color ==============

class _PaginaColor extends StatelessWidget {
  final int colorValor;
  final ValueChanged<int> onChange;
  const _PaginaColor({required this.colorValor, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const Text(
            'Elige tu color favorito',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  for (final c in coloresPerfilesDisponibles)
                    _CirculoColor(
                      colorValor: c,
                      seleccionado: c == colorValor,
                      onTap: () => onChange(c),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CirculoColor extends StatelessWidget {
  final int colorValor;
  final bool seleccionado;
  final VoidCallback onTap;
  const _CirculoColor({
    required this.colorValor,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Color(colorValor);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: seleccionado ? 6 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: c.withValues(alpha: 0.55),
              blurRadius: seleccionado ? 18 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: seleccionado
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 38)
            : null,
      ),
    );
  }
}

// ============== Página 5: Avatar ==============

class _PaginaAvatar extends StatelessWidget {
  final String avatar;
  final Color color;
  final ValueChanged<String> onChange;
  const _PaginaAvatar({
    required this.avatar,
    required this.color,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          const Text(
            'Elige tu mascota',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: KidsColors.texto,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: avataresDisponibles.length,
              itemBuilder: (context, i) {
                final a = avataresDisponibles[i];
                final esActivo = a == avatar;
                return GestureDetector(
                  onTap: () => onChange(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient:
                          esActivo ? gradienteCategoria(color) : null,
                      color: esActivo ? null : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: esActivo
                            ? Colors.white
                            : color.withValues(alpha: 0.30),
                        width: 3,
                      ),
                      boxShadow:
                          esActivo ? sombraTarjeta : sombraSuave,
                    ),
                    alignment: Alignment.center,
                    child: IconKid(a, size: 56, sombra: true),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
