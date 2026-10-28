import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/services/firestore_service.dart';

import 'donacion_repository_test.mocks.dart';

@GenerateMocks([FirestoreService])
void main() {
  late MockFirestoreService firestore;
  late DonacionRepository repo;

  final donacion = Donacion(
    id: '',
    donanteId: 'u1',
    descripcion: '12 porciones de comida corrida',
    cantidadKg: 6.5,
    caducidad: DateTime(2026, 11, 2, 23, 59),
    puntoEntregaId: 'p1',
    creadaEn: DateTime(2026, 10, 28, 18),
  );

  setUp(() {
    firestore = MockFirestoreService();
    repo = DonacionRepository(firestore: firestore);
  });

  test('crear guarda la donacion en la coleccion donaciones', () async {
    when(firestore.agregarDocumento(any, any)).thenAnswer((_) async => 'd9');

    final id = await repo.crear(donacion);

    expect(id, 'd9');
    verify(firestore.agregarDocumento('donaciones', donacion.toMap()))
        .called(1);
  });

  test('crearPuntoEntrega guarda en puntos_entrega y devuelve el id', () async {
    const punto = PuntoEntrega(
      id: '',
      donanteId: 'u1',
      nombre: 'La Esquina',
      direccion: 'Av. Universidad 210',
      latitud: 0,
      longitud: 0,
    );
    when(firestore.agregarDocumento(any, any)).thenAnswer((_) async => 'p7');

    expect(await repo.crearPuntoEntrega(punto), 'p7');
    verify(firestore.agregarDocumento('puntos_entrega', punto.toMap()))
        .called(1);
  });

  test('observarDisponibles consulta solo las disponibles y las convierte',
      () async {
    when(firestore.observarDonde(
      'donaciones',
      campo: 'estado',
      valor: 'disponible',
    )).thenAnswer((_) => Stream.value([
          (id: 'd1', datos: donacion.toMap()),
        ]));

    final lista = await repo.observarDisponibles().first;

    expect(lista, hasLength(1));
    expect(lista.single.id, 'd1');
    expect(lista.single.descripcion, donacion.descripcion);
  });

  test('un documento mal formado no tira la lista', () async {
    when(firestore.observarDonde(any,
            campo: anyNamed('campo'), valor: anyNamed('valor')))
        .thenAnswer((_) => Stream.value([
              (id: 'roto', datos: {'descripcion': 'sin los demas campos'}),
              (id: 'd1', datos: donacion.toMap()),
            ]));

    final lista = await repo.observarDisponibles().first;

    expect(lista.map((d) => d.id), ['d1']);
  });

  test('obtenerPuntoEntrega lee el punto o devuelve null', () async {
    when(firestore.leerDocumento('puntos_entrega', 'p1')).thenAnswer(
      (_) async => {
        'donanteId': 'u1',
        'nombre': 'La Esquina',
        'direccion': 'Av. Universidad 210',
        'latitud': 21.15,
        'longitud': -100.93,
        'horario': '18:00 a 20:30',
      },
    );
    when(firestore.leerDocumento('puntos_entrega', 'nada'))
        .thenAnswer((_) async => null);

    final punto = await repo.obtenerPuntoEntrega('p1');

    expect(punto?.direccion, 'Av. Universidad 210');
    expect(await repo.obtenerPuntoEntrega('nada'), isNull);
  });
}
