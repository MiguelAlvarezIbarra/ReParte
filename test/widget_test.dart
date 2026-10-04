import 'package:flutter_test/flutter_test.dart';

import 'package:reparte/main.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla inicial',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ReParteApp());

    expect(find.text('Pendiente: tarea T07'), findsOneWidget);
  });
}