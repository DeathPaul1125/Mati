import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/zona_infantil_screen.dart';
import 'state/grabaciones_service.dart';
import 'state/perfiles_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configurarOrientacion();
  await PerfilesService.instancia.cargar();
  await GrabacionesService.instancia.inicializar();
  runApp(const JuegosKidsApp());
}

void _configurarOrientacion() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final size = view.physicalSize / view.devicePixelRatio;
  final ladoCorto = size.shortestSide;
  if (ladoCorto >= 600) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

bool esTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

bool esLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

class JuegosKidsApp extends StatelessWidget {
  const JuegosKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juegos Kids',
      debugShowCheckedModeBanner: false,
      theme: buildKidsTheme(),
      home: const ZonaInfantilScreen(),
    );
  }
}
