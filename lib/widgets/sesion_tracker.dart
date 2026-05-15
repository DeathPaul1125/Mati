import 'package:flutter/material.dart';
import '../state/perfiles_service.dart';

class SesionTracker extends StatefulWidget {
  final String categoria;
  final Widget child;

  const SesionTracker({
    super.key,
    required this.categoria,
    required this.child,
  });

  @override
  State<SesionTracker> createState() => _SesionTrackerState();
}

class _SesionTrackerState extends State<SesionTracker>
    with WidgetsBindingObserver {
  DateTime? _inicio;
  int _acumulado = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _finalizar();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _detener();
    } else if (state == AppLifecycleState.resumed) {
      _iniciar();
    }
  }

  void _iniciar() {
    _inicio = DateTime.now();
  }

  void _detener() {
    if (_inicio == null) return;
    _acumulado += DateTime.now().difference(_inicio!).inSeconds;
    _inicio = null;
  }

  void _finalizar() {
    _detener();
    if (_acumulado > 0) {
      PerfilesService.instancia
          .registrarTiempoActivo(widget.categoria, _acumulado);
      _acumulado = 0;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
