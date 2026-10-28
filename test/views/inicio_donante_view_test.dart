import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/views/inicio/inicio_donante_view.dart';

import '../fakes/donacion_repository_falso.dart';

void main() {
  testWidgets('publicar desde el inicio guarda la donacion y lo avisa',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = DonacionRepositoryFalso();

    await tester.pumpWidget(
      Provider<DonacionRepository>.value(
        value: repo,
        child: MaterialApp(
          theme: TemaApp.claro,
          home: const InicioDonanteView(usuario: donanteDePrueba),
        ),
      ),
    );

    await tester.tap(find.text('Publicar donación'));
    await tester.pumpAndSettle();

    Finder campo(String etiqueta) =>
        find.widgetWithText(TextFormField, etiqueta);
    await tester.enterText(campo('Descripción'), 'Pan del dia');
    await tester.enterText(campo('Cantidad (kg)'), '4');
    await tester.tap(campo('Fecha de caducidad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(campo('Nombre del punto de entrega'), 'La Espiga');
    await tester.enterText(campo('Dirección'), 'Calle Hidalgo 12');
    await tester.tap(find.widgetWithText(FilledButton, 'Publicar donación'));
    await tester.pumpAndSettle();

    expect(find.text('Donación publicada'), findsOneWidget);
    expect(repo.creadas.single.donanteId, donanteDePrueba.id);
  });
}
