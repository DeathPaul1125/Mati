import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/perfiles_service.dart';
import '../theme.dart';

class PinDialog extends StatefulWidget {
  const PinDialog({super.key});

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  String _pin = '';
  String? _esperado;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    PerfilesService.instancia.obtenerPin().then((p) {
      if (mounted) setState(() => _esperado = p);
    });
  }

  void _agregar(String d) {
    if (_pin.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _verificar);
    }
  }

  void _borrar() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _verificar() {
    if (_pin == _esperado) {
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded,
                size: 48, color: KidsColors.texto),
            const SizedBox(height: 8),
            const Text(
              'Zona de padres',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _error ? 'PIN incorrecto, intenta otra vez' : 'Ingresa el PIN de 4 dígitos',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _error ? KidsColors.error : KidsColors.textoSuave,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final lleno = i < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: lleno ? KidsColors.texto : Colors.transparent,
                    border: Border.all(color: KidsColors.texto, width: 2),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                for (var i = 1; i <= 9; i++)
                  _Tecla(label: '$i', onTap: () => _agregar('$i')),
                _Tecla(label: '', onTap: () {}),
                _Tecla(label: '0', onTap: () => _agregar('0')),
                _Tecla(label: '⌫', onTap: _borrar),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'PIN por defecto: 1234',
              style: TextStyle(
                fontFamily: kFuente,
                fontSize: 12,
                color: KidsColors.textoSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tecla extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Tecla({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Material(
      color: const Color(0xFFF0F2FB),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: kFuente,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: KidsColors.texto,
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> pedirPin(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const PinDialog(),
  );
  return ok ?? false;
}
