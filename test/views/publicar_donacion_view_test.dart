import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/viewmodels/publicar_donacion_viewmodel.dart';
import 'package:reparte/views/donaciones/publicar_donacion_view.dart';

void main() {
  DatosDonacion? resultado;

  setUp(() => resultado = null);

  /// Abre el formulario desde un boton, como lo hace la pantalla del donante.
  Future<void> abrirFormulario(WidgetTester tester) async {
    // Pantalla alta para que todos los campos queden a la vista.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: TemaApp.claro,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  resultado = await PublicarDonacionView.abrir(context);
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);
  Finder botonPublicar() =>
      find.widgetWithText(FilledButton, 'Publicar donación');

  testWidgets('muestra los campos del formulario', (tester) async {
    await abrirFormulario(tester);

    expect(campo('Descripción'), findsOneWidget);
    expect(campo('Cantidad (kg)'), findsOneWidget);
    expect(campo('Fecha de caducidad'), findsOneWidget);
    expect(campo('Nombre del punto de entrega'), findsOneWidget);
    expect(campo('Dirección'), findsOneWidget);
    expect(botonPublicar(), findsOneWidget);
  });

  testWidgets('valida los campos vacios y no cierra el formulario',
      (tester) async {
    await abrirFormulario(tester);

    await tester.tap(botonPublicar());
    await tester.pump();

    expect(find.text('Describe qué vas a donar'), findsOneWidget);
    expect(find.text('Escribe la cantidad'), findsOneWidget);
    expect(find.text('Elige la fecha de caducidad'), findsOneWidget);
    expect(find.text('Escribe el nombre del punto de entrega'), findsOneWidget);
    expect(find.text('Escribe la dirección de entrega'), findsOneWidget);
    expect(botonPublicar(), findsOneWidget);
    expect(resultado, isNull);
  });

  testWidgets('rechaza una cantidad que no es numero', (tester) async {
    await abrirFormulario(tester);

    await tester.enterText(campo('Cantidad (kg)'), 'mucho');
    await tester.tap(botonPublicar());
    await tester.pump();

    expect(find.text('Escribe un número válido'), findsOneWidget);
  });

  testWidgets('con datos validos devuelve la donacion capturada',
      (tester) async {
    await abrirFormulario(tester);

    await tester.enterText(campo('Descripción'), 'Pan del dia');
    await tester.enterText(campo('Cantidad (kg)'), '3,5');
    await tester.tap(campo('Fecha de caducidad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.enterText(
        campo('Nombre del punto de entrega'), 'Panaderia La Espiga');
    await tester.enterText(campo('Dirección'), 'Calle Hidalgo 12');
    await tester.tap(botonPublicar());
    await tester.pumpAndSettle();

    // El formulario se cerro y devolvio lo capturado.
    expect(botonPublicar(), findsNothing);
    expect(resultado, isNotNull);
    expect(resultado!.descripcion, 'Pan del dia');
    expect(resultado!.cantidadKg, 3.5);
    expect(resultado!.puntoNombre, 'Panaderia La Espiga');
    expect(resultado!.puntoDireccion, 'Calle Hidalgo 12');
    expect(resultado!.caducidad.isAfter(DateTime.now()), isTrue);
  });
}
