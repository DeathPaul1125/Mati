import 'package:flutter/material.dart';
import '../state/perfil.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/fondo_decorativo.dart';
import '../widgets/icon_kid.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Perfil? perfil;
  const EditarPerfilScreen({super.key, this.perfil});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController _nombreCtrl;
  late int _edad;
  late String _avatar;
  late int _colorValor;
  late int _metaDiaria;
  late bool _limiteEstricto;

  bool get _esNuevo => widget.perfil == null;

  @override
  void initState() {
    super.initState();
    final p = widget.perfil;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _edad = p?.edad ?? 4;
    _avatar = p?.avatar ?? avataresDisponibles.first;
    _colorValor = p?.colorValor ?? coloresPerfilesDisponibles.first;
    _metaDiaria = p?.metaDiariaMin ?? 15;
    _limiteEstricto = p?.limiteEstricto ?? false;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre')),
      );
      return;
    }
    if (_esNuevo) {
      await PerfilesService.instancia.agregar(Perfil(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        edad: _edad,
        avatar: _avatar,
        colorValor: _colorValor,
        metaDiariaMin: _metaDiaria,
        limiteEstricto: _limiteEstricto,
      ));
    } else {
      final p = widget.perfil!;
      p.nombre = nombre;
      p.edad = _edad;
      p.avatar = _avatar;
      p.colorValor = _colorValor;
      p.metaDiariaMin = _metaDiaria;
      p.limiteEstricto = _limiteEstricto;
      await PerfilesService.instancia.actualizar(p);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _eliminar() async {
    final p = widget.perfil!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Eliminar a ${p.nombre}'),
        content: const Text('Se borrará el progreso de este perfil.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: KidsColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await PerfilesService.instancia.eliminar(p.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_colorValor);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FondoDecorativo(
        colores: const [Color(0xFFE7EDFF), Color(0xFFD4DCFF)],
        cantidadEstrellas: 8,
        child: SafeArea(
          child: Column(
            children: [
              _BarraSuperior(
                titulo: _esNuevo ? 'Nuevo perfil' : 'Editar perfil',
                onCerrar: () => Navigator.of(context).pop(),
                onEliminar: _esNuevo ? null : _eliminar,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 4),
                        ),
                        alignment: Alignment.center,
                        child: IconKid(_avatar, size: 88),
                      ),
                      const SizedBox(height: 18),
                      _Etiqueta('Nombre'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: sombraSuave,
                        ),
                        child: TextField(
                          controller: _nombreCtrl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: kFuente,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12),
                            hintText: 'Nombre',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Etiqueta('Edad: $_edad años'),
                      Slider(
                        value: _edad.toDouble(),
                        min: 2,
                        max: 12,
                        divisions: 10,
                        activeColor: color,
                        label: '$_edad',
                        onChanged: (v) => setState(() => _edad = v.round()),
                      ),
                      const SizedBox(height: 6),
                      _Etiqueta('Avatar'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final a in avataresDisponibles)
                            _OpcionAvatar(
                              emoji: a,
                              seleccionado: _avatar == a,
                              color: color,
                              onTap: () => setState(() => _avatar = a),
                            ),
                          if (widget.perfil != null)
                            for (final a in widget.perfil!.avatarsDesbloqueados)
                              _OpcionAvatar(
                                emoji: a,
                                seleccionado: _avatar == a,
                                color: color,
                                onTap: () => setState(() => _avatar = a),
                              ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _Etiqueta('Color'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: coloresPerfilesDisponibles
                            .map((c) => _OpcionColor(
                                  color: Color(c),
                                  seleccionado: _colorValor == c,
                                  onTap: () => setState(() => _colorValor = c),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      _Etiqueta('Meta diaria: $_metaDiaria minutos'),
                      Slider(
                        value: _metaDiaria.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        activeColor: color,
                        label: '$_metaDiaria min',
                        onChanged: (v) =>
                            setState(() => _metaDiaria = v.round()),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: sombraSuave,
                        ),
                        child: SwitchListTile(
                          value: _limiteEstricto,
                          onChanged: (v) =>
                              setState(() => _limiteEstricto = v),
                          activeThumbColor: color,
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Bloquear al alcanzar la meta',
                            style: TextStyle(
                              fontFamily: kFuente,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: KidsColors.texto,
                            ),
                          ),
                          subtitle: const Text(
                            'Cuando se cumpla el tiempo de hoy, los juegos se pausan hasta mañana (los papás pueden desbloquear con PIN)',
                            style: TextStyle(
                              fontFamily: kFuente,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: KidsColors.textoSuave,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 6,
                          shadowColor: color.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          _esNuevo ? 'Crear perfil' : 'Guardar cambios',
                          style: const TextStyle(
                            fontFamily: kFuente,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  final String titulo;
  final VoidCallback onCerrar;
  final VoidCallback? onEliminar;

  const _BarraSuperior({
    required this.titulo,
    required this.onCerrar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          _BotonCircular(
            icono: Icons.close_rounded,
            onTap: onCerrar,
          ),
          Expanded(
            child: Center(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontFamily: kFuente,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: KidsColors.texto,
                ),
              ),
            ),
          ),
          if (onEliminar != null)
            _BotonCircular(
              icono: Icons.delete_outline_rounded,
              color: KidsColors.error,
              onTap: onEliminar!,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _BotonCircular extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  final Color? color;
  const _BotonCircular({required this.icono, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icono, color: color ?? KidsColors.textoSuave, size: 26),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  const _Etiqueta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texto,
          style: const TextStyle(
            fontFamily: kFuente,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: KidsColors.textoSuave,
          ),
        ),
      ),
    );
  }
}

class _OpcionAvatar extends StatelessWidget {
  final String emoji;
  final bool seleccionado;
  final Color color;
  final VoidCallback onTap;
  const _OpcionAvatar({
    required this.emoji,
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: seleccionado ? color : Colors.transparent,
            width: 4,
          ),
          boxShadow: seleccionado ? sombraTarjeta : sombraSuave,
        ),
        alignment: Alignment.center,
        child: IconKid(emoji, size: 40),
      ),
    );
  }
}

class _OpcionColor extends StatelessWidget {
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;
  const _OpcionColor({
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: seleccionado ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: seleccionado ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: seleccionado
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : null,
      ),
    );
  }
}
