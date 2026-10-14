import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/main.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';

import 'viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  testWidgets('La app arranca y muestra el inicio de sesion',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(MockUsuarioRepository()),
        child: const ReParteApp(),
      ),
    );

    expect(find.text('ReParte'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
