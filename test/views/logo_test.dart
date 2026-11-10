import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/widgets/encabezado_reparte.dart';
import 'package:reparte/widgets/logo_reparte.dart';

void main() {
  Future<void> mostrar(WidgetTester tester, Widget hijo) => tester.pumpWidget(
        MaterialApp(theme: TemaApp.claro, home: Scaffold(body: hijo)),
      );

  testWidgets('el inicio de sesion muestra el logo de ReParte', (tester) async {
    await mostrar(tester, const EncabezadoReParte());

    expect(find.byType(LogoReParte), findsOneWidget);
    expect(find.bySemanticsLabel('Logo de ReParte'), findsOneWidget);
    expect(find.text('ReParte'), findsOneWidget);
  });

  testWidgets('el logo se dibuja del tamano pedido, con y sin fondo',
      (tester) async {
    await mostrar(
      tester,
      const Row(children: [
        LogoReParte(tamano: 120),
        LogoReParte(tamano: 40, conFondo: false),
      ]),
    );

    final tamanos = tester
        .widgetList<LogoReParte>(find.byType(LogoReParte))
        .map((l) => tester.getSize(find.byWidget(l)).width);
    expect(tamanos, [120, 40]);
    expect(tester.takeException(), isNull);
  });

  test('el marcador contiene a la hoja', () {
    final contorno = marcador().getBounds();
    expect(contorno.contains(hoja().getBounds().center), isTrue);
    expect(marcador().getBounds().width, closeTo(56, 0.5));
  });
}
