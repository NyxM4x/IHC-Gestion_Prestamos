import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_prestamos/screens/home_shell.dart';
import 'package:gestion_prestamos/ui/breakpoints.dart';

// Deja la pantalla del tamano pedido y limpia al terminar la prueba.
Future<void> pantallaDe(WidgetTester tester, double ancho, double alto) async {
  tester.view.physicalSize = Size(ancho, alto);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('cortes de tamano', () {
    test('un celular es compacto', () {
      expect(tamanoDe(390), Tamano.compacto);
      expect(tamanoDe(599), Tamano.compacto);
    });

    test('una tablet es mediana', () {
      expect(tamanoDe(600), Tamano.mediano);
      expect(tamanoDe(1023), Tamano.mediano);
    });

    test('un monitor es amplio', () {
      expect(tamanoDe(1024), Tamano.amplio);
      expect(tamanoDe(1920), Tamano.amplio);
    });

    test('la cantidad de columnas crece con la pantalla', () {
      expect(columnasPara(Tamano.compacto), 1);
      expect(columnasPara(Tamano.mediano), 2);
      expect(columnasPara(Tamano.amplio), 3);
    });
  });

  group('la navegacion cambia de forma', () {
    testWidgets('en celular el menu va abajo', (tester) async {
      await pantallaDe(tester, 390, 844);
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('en tablet el menu va al costado', (tester) async {
      await pantallaDe(tester, 800, 1000);
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('en monitor el menu lateral se muestra extendido',
        (tester) async {
      await pantallaDe(tester, 1440, 900);
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
    });

    testWidgets('las tres secciones estan en cualquier tamano', (tester) async {
      await pantallaDe(tester, 390, 844);
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));

      final barra = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(barra.destinations.length, 3);
    });
  });

  testWidgets('el contenido no se estira de borde a borde en monitor',
      (tester) async {
    await pantallaDe(tester, 1920, 1080);
    const llave = Key('contenido');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContenidoCentrado(
            // Pide todo el ancho que le den, para medir el techo real.
            child: SizedBox(key: llave, width: double.infinity, height: 40),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(llave)).width, 840);
  });
}
