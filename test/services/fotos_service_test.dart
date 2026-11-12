import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/services/fotos_service.dart';

void main() {
  late Directory carpeta;

  setUp(() => carpeta = Directory.systemTemp.createTempSync('fotos_test'));
  tearDown(() => carpeta.deleteSync(recursive: true));

  File crear(String nombre, List<int> bytes) =>
      File('${carpeta.path}/$nombre')..writeAsBytesSync(bytes);

  test('convierte la foto del telefono a una imagen en base64 (T35)', () async {
    final bytes = List<int>.generate(2000, (i) => i % 256);
    final foto = crear('foto.jpg', bytes);

    final guardada =
        await const FotosFirestoreService().prepararParaGuardar(foto.path);

    expect(guardada, startsWith('data:image/jpeg;base64,'));
    final recuperada = base64Decode(guardada.split(',').last);
    expect(recuperada, bytes);
  });

  test('respeta el tipo de imagen segun la extension', () async {
    final png = crear('foto.PNG', [1, 2, 3]);
    final webp = crear('foto.webp', [1, 2, 3]);

    const servicio = FotosFirestoreService();

    expect(await servicio.prepararParaGuardar(png.path),
        startsWith('data:image/png;base64,'));
    expect(await servicio.prepararParaGuardar(webp.path),
        startsWith('data:image/webp;base64,'));
  });

  test('un enlace o una imagen ya en base64 se devuelven igual', () async {
    const servicio = FotosFirestoreService();

    expect(await servicio.prepararParaGuardar(' https://x.mx/a.jpg '),
        'https://x.mx/a.jpg');
    expect(await servicio.prepararParaGuardar('data:image/png;base64,AAAA'),
        'data:image/png;base64,AAAA');
  });

  test('si la foto no existe lanza FotoNoValida', () async {
    expect(
      const FotosFirestoreService()
          .prepararParaGuardar('${carpeta.path}/no_existe.jpg'),
      throwsA(isA<FotoNoValida>()),
    );
  });

  test('si la foto esta vacia lanza FotoNoValida', () async {
    final vacia = crear('vacia.jpg', []);

    expect(
      const FotosFirestoreService().prepararParaGuardar(vacia.path),
      throwsA(isA<FotoNoValida>()),
    );
    expect(
      const FotosFirestoreService().prepararParaGuardar('   '),
      throwsA(isA<FotoNoValida>()),
    );
  });

  test('si pesa mas que el limite lanza FotoNoValida', () async {
    final grande = crear('grande.jpg', List<int>.filled(1001, 7));
    final justa = crear('justa.jpg', List<int>.filled(1000, 7));
    const servicio = FotosFirestoreService(maxBytes: 1000);

    await expectLater(
      servicio.prepararParaGuardar(grande.path),
      throwsA(isA<FotoNoValida>()),
    );
    expect(await servicio.prepararParaGuardar(justa.path),
        startsWith('data:image/jpeg;base64,'));
  });

  test('con el limite normal una foto de 150 KB cabe en un documento',
      () async {
    final foto = crear('normal.jpg', List<int>.filled(150 * 1024, 9));

    final guardada =
        await const FotosFirestoreService().prepararParaGuardar(foto.path);

    // Firestore admite 1 MiB por documento.
    expect(guardada.length, lessThan(1024 * 1024));
  });
}
