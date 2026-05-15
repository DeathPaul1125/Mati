import 'package:flutter_test/flutter_test.dart';

import 'package:juegos_kids/main.dart';

void main() {
  testWidgets('La pantalla principal muestra las 4 categorías',
      (WidgetTester tester) async {
    await tester.pumpWidget(const JuegosKidsApp());
    await tester.pumpAndSettle();

    expect(find.text('¡Hola!'), findsOneWidget);
    expect(find.text('Matemáticas'), findsOneWidget);
    expect(find.text('Memoria'), findsOneWidget);
    expect(find.text('Lógica'), findsOneWidget);
    expect(find.text('Lectura'), findsOneWidget);
  });
}
