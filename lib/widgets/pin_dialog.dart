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

/// Diálogo para cambiar el PIN. Asume que el usuario ya está autenticado
/// (en la Zona padres). Pide el nuevo PIN dos veces y lo guarda.
class CambiarPinDialog extends StatefulWidget {
  const CambiarPinDialog({super.key});

  @override
  State<CambiarPinDialog> createState() => _CambiarPinDialogState();
}

enum _PasoCambioPin { nuevo, confirmar }

class _CambiarPinDialogState extends State<CambiarPinDialog> {
  _PasoCambioPin _paso = _PasoCambioPin.nuevo;
  String _pinNuevo = '';
  String _pinConfirmar = '';
  bool _error = false;

  String get _pinActual =>
      _paso == _PasoCambioPin.nuevo ? _pinNuevo : _pinConfirmar;

  set _pinActual(String v) {
    if (_paso == _PasoCambioPin.nuevo) {
      _pinNuevo = v;
    } else {
      _pinConfirmar = v;
    }
  }

  void _agregar(String d) {
    if (_pinActual.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pinActual = _pinActual + d;
      _error = false;
    });
    if (_pinActual.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _avanzar);
    }
  }

  void _borrar() {
    if (_pinActual.isEmpty) return;
    setState(() => _pinActual = _pinActual.substring(0, _pinActual.length - 1));
  }

  Future<void> _avanzar() async {
    if (_paso == _PasoCambioPin.nuevo) {
      setState(() {
        _paso = _PasoCambioPin.confirmar;
        _error = false;
      });
    } else {
      if (_pinNuevo == _pinConfirmar) {
        await PerfilesService.instancia.establecerPin(_pinNuevo);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _error = true;
          _pinNuevo = '';
          _pinConfirmar = '';
          _paso = _PasoCambioPin.nuevo;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esConfirmar = _paso == _PasoCambioPin.confirmar;
    final titulo = esConfirmar ? 'Confirma el PIN nuevo' : 'PIN nuevo';
    final subtitulo = _error
        ? 'Los PIN no coinciden, intenta otra vez'
        : esConfirmar
            ? 'Vuelve a escribir el PIN nuevo'
            : 'Escribe 4 dígitos';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_reset_rounded,
                size: 48, color: KidsColors.texto),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontFamily: kFuente,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KidsColors.texto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
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
                final lleno = i < _pinActual.length;
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontFamily: kFuente,
                  fontSize: 14,
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

Future<bool> cambiarPin(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const CambiarPinDialog(),
  );
  return ok ?? false;
}
