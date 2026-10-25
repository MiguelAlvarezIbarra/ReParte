import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/utilidades/formato.dart';

void main() {
  test('fecha usa dia/mes/anio con ceros', () {
    expect(Formato.fecha(DateTime(2026, 11, 5)), '05/11/2026');
    expect(Formato.fecha(DateTime(2026, 12, 25)), '25/12/2026');
  });

  test('kilos quita el decimal si es entero', () {
    expect(Formato.kilos(3), '3 kg');
    expect(Formato.kilos(2.5), '2.5 kg');
  });
}
