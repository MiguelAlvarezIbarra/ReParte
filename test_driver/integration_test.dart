import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

/// Recibe las capturas que toma la prueba en el telefono y las guarda
/// en docs/pruebas/capturas como evidencia (T25).
///
/// Si el nombre dice barra_de_notificaciones, la captura se toma con adb,
/// porque la barra es del sistema y no se ve en una captura de la app.
Future<void> main() => integrationDriver(
      onScreenshot: (nombre, bytes, [args]) async {
        final archivo = File('docs/pruebas/capturas/$nombre.png');
        await archivo.create(recursive: true);
        if (nombre.contains('barra_de_notificaciones')) {
          await _adb(['shell', 'cmd', 'statusbar', 'expand-notifications']);
          await Future<void>.delayed(const Duration(seconds: 2));
          final captura = await Process.run(
            _rutaAdb,
            ['exec-out', 'screencap', '-p'],
            stdoutEncoding: null,
          );
          await archivo.writeAsBytes(captura.stdout as List<int>);
          await _adb(['shell', 'cmd', 'statusbar', 'collapse']);
        } else {
          await archivo.writeAsBytes(bytes);
        }
        return true;
      },
    );

/// adb del SDK de Android; se puede cambiar con la variable ADB.
final _rutaAdb = Platform.environment['ADB'] ?? 'adb';

Future<void> _adb(List<String> argumentos) => Process.run(_rutaAdb, argumentos);
