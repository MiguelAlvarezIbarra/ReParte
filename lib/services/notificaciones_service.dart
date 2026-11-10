import 'dart:ui' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Muestra avisos en la barra de notificaciones del telefono.
/// Desacopla el paquete del sistema para poder probar sin el telefono.
abstract class NotificacionesService {
  /// Prepara el canal y pide permiso (Android 13 o superior).
  Future<void> inicializar();

  Future<void> mostrar({
    required int id,
    required String titulo,
    required String mensaje,
  });
}

/// Implementacion con flutter_local_notifications.
class LocalNotificacionesService implements NotificacionesService {
  LocalNotificacionesService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _listo = false;

  /// Silueta del logo (android/app/src/main/res/drawable), T33.
  static const icono = 'ic_notificacion';

  static const _canal = AndroidNotificationDetails(
    'reservas',
    'Reservas de donaciones',
    channelDescription: 'Avisa cuando una asociación reserva tu donación',
    importance: Importance.high,
    priority: Priority.high,
    icon: icono,
    color: Color(0xFF1F5C50), // verde de la app
  );

  @override
  Future<void> inicializar() async {
    if (_listo) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(icono),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _listo = true;
  }

  @override
  Future<void> mostrar({
    required int id,
    required String titulo,
    required String mensaje,
  }) async {
    await inicializar();
    await _plugin.show(
      id: id,
      title: titulo,
      body: mensaje,
      notificationDetails: const NotificationDetails(android: _canal),
    );
  }
}
