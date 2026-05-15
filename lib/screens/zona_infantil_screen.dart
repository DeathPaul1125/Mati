import 'package:flutter/material.dart';
import '../state/perfil.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/fondo_decorativo.dart';
import '../widgets/icon_kid.dart';
import 'editar_perfil_screen.dart';
import 'home_screen.dart';
import 'zona_padres_screen.dart';

class ZonaInfantilScreen extends StatelessWidget {
  const ZonaInfantilScreen({super.key});

  Future<void> _entrar(BuildContext context, Perfil p) async {
    await PerfilesService.instancia.seleccionar(p.id);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDecorativo(
        colores: const [Color(0xFFE7EDFF), Color(0xFFD4DCFF)],
        cantidadEstrellas: 10,
        child: SafeArea(
          child: ListenableBuilder(
            listenable: PerfilesService.instancia,
            builder: (context, _) {
              final perfiles = PerfilesService.instancia.perfiles;
              return Column(
                children: [
                  _Header(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final p in perfiles)
                            _TarjetaPerfil(
                              perfil: p,
                              onTap: () => _entrar(context, p),
                              onEditar: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditarPerfilScreen(perfil: p),
                                ),
                              ),
                            ),
                          _BotonAgregar(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const EditarPerfilScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Zona infantil',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: KidsColors.texto,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ZonaPadresScreen(),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded, size: 22, color: KidsColors.texto),
                    SizedBox(width: 6),
                    Text(
                      'Para los padres',
                      style: TextStyle(
                        fontFamily: kFuente,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: KidsColors.texto,
                      ),
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

class _TarjetaPerfil extends StatelessWidget {
  final Perfil perfil;
  final VoidCallback onTap;
  final VoidCallback onEditar;

  const _TarjetaPerfil({
    required this.perfil,
    required this.onTap,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final activo = PerfilesService.instancia.activo?.id == perfil.id;
    return SizedBox(
      width: 150,
      child: Material(
        color: Colors.white,
        elevation: activo ? 8 : 4,
        shadowColor: perfil.color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: activo ? perfil.color : Colors.transparent,
                width: 4,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: perfil.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: IconKid(perfil.avatar, size: 70),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: KidsColors.estrella,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${perfil.nivel()}',
                        style: const TextStyle(
                          fontFamily: kFuente,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  perfil.nombre,
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: KidsColors.texto,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${perfil.edad} años',
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KidsColors.textoSuave,
                  ),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text(
                    'Editar',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: perfil.color,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonAgregar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Material(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: KidsColors.texto.withValues(alpha: 0.25),
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B8DEF).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.add_rounded,
                      size: 44, color: Color(0xFF5B8DEF)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Agregar un\nperfil infantil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kFuente,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: KidsColors.texto,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
