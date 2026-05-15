import 'package:flutter/material.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';
import '../widgets/fondo_decorativo.dart';
import '../widgets/icon_kid.dart';
import '../widgets/pin_dialog.dart';

class LimiteAlcanzadoScreen extends StatelessWidget {
  const LimiteAlcanzadoScreen({super.key});

  Future<void> _desbloquear(BuildContext context) async {
    final ok = await pedirPin(context);
    if (ok && context.mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = PerfilesService.instancia.activo;
    return Scaffold(
      body: FondoDecorativo(
        colores: const [Color(0xFFFFE7B5), Color(0xFFFFC5D6)],
        cantidadEstrellas: 10,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: sombraTarjeta,
                  ),
                  alignment: Alignment.center,
                  child: const IconKid('🌙', size: 110),
                ),
                const SizedBox(height: 22),
                Text(
                  '¡Buen trabajo${p != null ? ", ${p.nombre}" : ""}!',
                  style: const TextStyle(
                    fontFamily: kFuente,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: KidsColors.texto,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ya jugaste ${p?.minutosHoy ?? 0} minutos hoy.\n¡Nos vemos mañana para jugar más!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: kFuente,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: KidsColors.textoSuave,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'Volver al menú',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KidsColors.matematicas,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _desbloquear(context),
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text(
                    'Desbloquear (papás)',
                    style: TextStyle(
                      fontFamily: kFuente,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: KidsColors.textoSuave,
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
