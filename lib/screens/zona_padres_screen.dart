import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../state/perfil.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/icon_kid.dart';
import '../widgets/pin_dialog.dart';
import 'grabaciones_screen.dart';

class ZonaPadresScreen extends StatefulWidget {
  const ZonaPadresScreen({super.key});

  @override
  State<ZonaPadresScreen> createState() => _ZonaPadresScreenState();
}

class _ZonaPadresScreenState extends State<ZonaPadresScreen> {
  bool _autorizado = false;
  Perfil? _seleccionado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pedirPin());
  }

  Future<void> _pedirPin() async {
    final ok = await pedirPin(context);
    if (!mounted) return;
    if (!ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _autorizado = true;
      _seleccionado = PerfilesService.instancia.activo;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_autorizado) {
      return Scaffold(
        backgroundColor: const Color(0xFFE7EDFF),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: PerfilesService.instancia,
          builder: (context, _) {
            final perfiles = PerfilesService.instancia.perfiles;
            _seleccionado ??= perfiles.first;
            final actual = perfiles.firstWhere(
              (p) => p.id == _seleccionado?.id,
              orElse: () => perfiles.first,
            );
            return Column(
              children: [
                _Encabezado(
                  onAtras: () => Navigator.of(context).pop(),
                ),
                _SelectorPerfil(
                  perfiles: perfiles,
                  seleccionadoId: actual.id,
                  onSeleccionar: (p) => setState(() => _seleccionado = p),
                ),
                Expanded(child: _ContenidoEstadisticas(perfil: actual)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  final VoidCallback onAtras;
  const _Encabezado({required this.onAtras});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onAtras,
            icon: const Icon(Icons.chevron_left_rounded,
                size: 30, color: Color(0xFF5B8DEF)),
          ),
          const Text(
            'Zona infantil',
            style: TextStyle(
              fontFamily: kFuente,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: KidsColors.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorPerfil extends StatelessWidget {
  final List<Perfil> perfiles;
  final String seleccionadoId;
  final void Function(Perfil) onSeleccionar;

  const _SelectorPerfil({
    required this.perfiles,
    required this.seleccionadoId,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: perfiles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = perfiles[i];
          final activo = p.id == seleccionadoId;
          return GestureDetector(
            onTap: () => onSeleccionar(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 96,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: activo
                    ? const Color(0xFFE5F4D8)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo ? const Color(0xFF7CB342) : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: IconKid(p.avatar, size: 44),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.nombre,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: kFuente,
                      fontSize: 13,
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
    );
  }
}

class _ContenidoEstadisticas extends StatelessWidget {
  final Perfil perfil;
  const _ContenidoEstadisticas({required this.perfil});

  @override
  Widget build(BuildContext context) {
    final categorias = <Map<String, dynamic>>[
      {'titulo': 'Matemáticas', 'cat': 'matematicas', 'color': KidsColors.matematicas, 'emoji': '🔢'},
      {'titulo': 'Memoria', 'cat': 'memoria', 'color': KidsColors.memoria, 'emoji': '🧠'},
      {'titulo': 'Lógica', 'cat': 'logica', 'color': KidsColors.logica, 'emoji': '🧩'},
      {'titulo': 'Lectura', 'cat': 'lectura', 'color': KidsColors.lectura, 'emoji': '📚'},
      {'titulo': 'Clasificar', 'cat': 'clasificar', 'color': KidsColors.clasificar, 'emoji': '📦'},
      {'titulo': 'Sombras', 'cat': 'sombras', 'color': KidsColors.sombras, 'emoji': '👤'},
      {'titulo': 'Pintar', 'cat': 'pintar', 'color': KidsColors.pintar, 'emoji': '🎨'},
    ];
    final segHoy = perfil.segundosHoy;
    final progreso = perfil.progresoDiario;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        const Text(
          'Hoy',
          style: TextStyle(
            fontFamily: kFuente,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: KidsColors.texto,
          ),
        ),
        Text(
          progreso >= 1.0
              ? '¡Meta del día completada! 🎉'
              : 'Meta del día no completada',
          style: const TextStyle(
            fontFamily: kFuente,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: KidsColors.textoSuave,
          ),
        ),
        const SizedBox(height: 16),
        for (final c in categorias)
          _FilaCategoria(
            titulo: c['titulo'] as String,
            emoji: c['emoji'] as String,
            color: c['color'] as Color,
            segundos:
                perfil.segundosPorCategoria[c['cat'] as String] ?? 0,
            estrellas: perfil.estrellas[c['cat'] as String] ?? 0,
          ),
        const SizedBox(height: 18),
        _BarraProgreso(progreso: progreso, segHoy: segHoy, meta: perfil.metaDiariaMin),
        const SizedBox(height: 14),
        _CalendarioMes(diasJugados: perfil.diasJugados.toSet()),
        const SizedBox(height: 18),
        const _BotonGrabaciones(),
        const SizedBox(height: 14),
        const _BotonCambiarPin(),
        const SizedBox(height: 14),
        const _BotonBackup(),
        const SizedBox(height: 14),
        const _SelectorEstiloIconos(),
        const SizedBox(height: 14),
        const _BotonAcercaDe(),
      ],
    );
  }
}

class _BotonGrabaciones extends StatelessWidget {
  const _BotonGrabaciones();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF8FB1),
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: const Color(0x55FF8FB1),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GrabacionesScreen()),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Grabar mi voz',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Reemplaza la voz del sistema con la tuya',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonCambiarPin extends StatelessWidget {
  const _BotonCambiarPin();

  Future<void> _abrir(BuildContext context) async {
    final ok = await cambiarPin(context);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: KidsColors.exito,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: const Text(
              'PIN cambiado correctamente',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF7C4DFF),
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: const Color(0x557C4DFF),
      child: InkWell(
        onTap: () => _abrir(context),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.lock_reset_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Cambiar PIN',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Elige una nueva clave de 4 dígitos',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorEstiloIconos extends StatelessWidget {
  const _SelectorEstiloIconos();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PerfilesService.instancia,
      builder: (context, _) {
        final actual = PerfilesService.instancia.estiloIconos;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: const Color(0xFFE0E5F5), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estilo de iconos',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KidsColors.texto,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Elige cómo se ven los dibujos en los juegos',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KidsColors.textoSuave,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OpcionEstilo(
                      titulo: 'Fluent',
                      subtitulo: 'Moderno',
                      assetMuestra: 'assets/fluent/1f98a.svg',
                      seleccionado:
                          actual == PerfilesService.estiloFluent,
                      onTap: () => PerfilesService.instancia
                          .setEstiloIconos(
                              PerfilesService.estiloFluent),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OpcionEstilo(
                      titulo: 'Twemoji',
                      subtitulo: 'Colorido',
                      assetMuestra: 'assets/twemoji/1f98a.svg',
                      seleccionado:
                          actual == PerfilesService.estiloTwemoji,
                      onTap: () => PerfilesService.instancia
                          .setEstiloIconos(
                              PerfilesService.estiloTwemoji),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OpcionEstilo extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String assetMuestra;
  final bool seleccionado;
  final VoidCallback onTap;

  const _OpcionEstilo({
    required this.titulo,
    required this.subtitulo,
    required this.assetMuestra,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: seleccionado
              ? KidsColors.exito.withValues(alpha: 0.10)
              : const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: seleccionado
                ? KidsColors.exito
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          children: [
            SvgPicture.asset(assetMuestra, width: 56, height: 56),
            const SizedBox(height: 6),
            Text(
              titulo,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            Text(
              subtitulo,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: KidsColors.textoSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaCategoria extends StatelessWidget {
  final String titulo;
  final String emoji;
  final Color color;
  final int segundos;
  final int estrellas;

  const _FilaCategoria({
    required this.titulo,
    required this.emoji,
    required this.color,
    required this.segundos,
    required this.estrellas,
  });

  String _formato(int s) {
    if (s < 60) return '$s segundos';
    final m = s ~/ 60;
    return m == 1 ? '1 minuto' : '$m minutos';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: IconKid(emoji, size: 38),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: KidsColors.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formato(segundos),
                    style: const TextStyle(
                      fontFamily: kFuente,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KidsColors.textoSuave,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (estrellas > 0)
            Row(
              children: [
                const Icon(Icons.star_rounded,
                    color: KidsColors.estrella, size: 22),
                const SizedBox(width: 2),
                Text(
                  '$estrellas',
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: KidsColors.texto,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BarraProgreso extends StatelessWidget {
  final double progreso;
  final int segHoy;
  final int meta;

  const _BarraProgreso({
    required this.progreso,
    required this.segHoy,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progreso * 100).round();
    final m = segHoy ~/ 60;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7C8FF5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso total',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 14,
              value: progreso,
              backgroundColor: const Color(0xFF6172D5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(KidsColors.estrella),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$m / $meta minutos hoy',
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarioMes extends StatelessWidget {
  final Set<String> diasJugados;
  const _CalendarioMes({required this.diasJugados});

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final primer = DateTime(ahora.year, ahora.month, 1);
    final diasMes = DateTime(ahora.year, ahora.month + 1, 0).day;
    final offset = primer.weekday % 7;
    final nombreMes = const [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ][ahora.month];

    String iso(int d) => '${ahora.year.toString().padLeft(4, '0')}-'
        '${ahora.month.toString().padLeft(2, '0')}-'
        '${d.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C8FF5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            '$nombreMes ${ahora.year}',
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              _Cabecera('Do'), _Cabecera('Lu'), _Cabecera('Ma'),
              _Cabecera('Mi'), _Cabecera('Ju'), _Cabecera('Vi'),
              _Cabecera('Sá'),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
            ),
            itemCount: diasMes + offset,
            itemBuilder: (context, i) {
              if (i < offset) return const SizedBox.shrink();
              final dia = i - offset + 1;
              final esHoy = dia == ahora.day;
              final jugado = diasJugados.contains(iso(dia));
              return Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: esHoy
                        ? Colors.white
                        : jugado
                            ? KidsColors.estrella
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dia',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: esHoy
                          ? KidsColors.texto
                          : jugado
                              ? KidsColors.texto
                              : Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  final String texto;
  const _Cabecera(this.texto);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          texto,
          style: const TextStyle(
            fontFamily: kFuente,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD0D7FA),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// Botón: Exportar / Importar progreso
// ===================================================================

class _BotonBackup extends StatelessWidget {
  const _BotonBackup();

  Future<void> _exportar(BuildContext context) async {
    final json = await PerfilesService.instancia.exportarJson();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Tu copia de seguridad',
            style: TextStyle(fontFamily: kFuente, fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Copiá este texto y guardalo en un lugar seguro '
                '(correo, notas, Drive). Sirve para restaurar tu progreso '
                'si reinstalás la app o cambiás de teléfono.',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 13,
                  color: KidsColors.textoSuave,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    json,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: KidsColors.texto,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  backgroundColor: KidsColors.exito,
                  content: Text('Copiado al portapapeles ✓',
                      style: TextStyle(
                          fontFamily: kFuente,
                          fontWeight: FontWeight.w800)),
                ));
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copiar'),
          ),
        ],
      ),
    );
  }

  Future<void> _importar(BuildContext context) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Restaurar progreso',
            style: TextStyle(fontFamily: kFuente, fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pegá la copia de seguridad. Esto va a REEMPLAZAR los perfiles '
                'que tengas ahora.',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 13,
                  color: KidsColors.textoSuave,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: InputDecoration(
                  hintText: 'Pegá aquí el texto exportado…',
                  filled: true,
                  fillColor: const Color(0xFFF0F2FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final clipboard = await Clipboard.getData('text/plain');
              if (clipboard?.text != null) {
                ctrl.text = clipboard!.text!;
              }
            },
            icon: const Icon(Icons.paste_rounded),
            label: const Text('Pegar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (ok != true || ctrl.text.trim().isEmpty) return;
    final exito = await PerfilesService.instancia.importarJson(ctrl.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: exito ? KidsColors.exito : KidsColors.error,
        content: Text(
          exito
              ? 'Progreso restaurado ✓'
              : 'No se pudo leer la copia. Revisá el texto.',
          style: const TextStyle(
              fontFamily: kFuente, fontWeight: FontWeight.w800),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF22C55E),
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: const Color(0x5522C55E),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.cloud_download_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Copia de seguridad',
                        style: TextStyle(
                          fontFamily: kFuente,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Guardá y restaurá perfiles y progreso',
                        style: TextStyle(
                          fontFamily: kFuente,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportar(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Exportar',
                        style: TextStyle(
                            fontFamily: kFuente,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _importar(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Restaurar',
                        style: TextStyle(
                            fontFamily: kFuente,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// Botón: Acerca de la app
// ===================================================================

class _BotonAcercaDe extends StatelessWidget {
  const _BotonAcercaDe();

  void _abrir(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: Color(0xFF7C4DFF)),
            SizedBox(width: 8),
            Text('Juegos Kids',
                style: TextStyle(
                    fontFamily: kFuente, fontWeight: FontWeight.w900)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aplicación educativa para niños de 3 a 7 años.',
                style: TextStyle(
                    fontFamily: kFuente, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 12),
              Text(
                '🔒 Privacidad',
                style: TextStyle(
                    fontFamily: kFuente,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                '• La app funciona 100% sin conexión a internet.\n'
                '• Ningún dato del niño se envía a servidores.\n'
                '• Todo (perfiles, voz grabada, progreso) se guarda solo '
                'en el teléfono.\n'
                '• No hay anuncios ni rastreadores.',
                style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 13,
                    color: KidsColors.textoSuave),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  '❤',
                  style: TextStyle(fontSize: 28),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  'Hecho para Matías Aceituno,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: KidsColors.texto,
                  ),
                ),
              ),
              SizedBox(height: 2),
              Center(
                child: Text(
                  'por su papá que lo ama mucho.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: KidsColors.textoSuave,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  '— Pablo Aceituno',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: KidsColors.texto,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: () => _abrir(context),
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFF6438D8), size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Acerca de la app',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: KidsColors.texto,
                      ),
                    ),
                    Text(
                      'Privacidad, créditos y versión',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KidsColors.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: KidsColors.textoSuave),
            ],
          ),
        ),
      ),
    );
  }
}
