import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';
import '../services/conectividad_service.dart';

/// Franja arriba de toda la app cuando el telefono se queda sin red.
/// Firestore sigue mostrando lo ultimo que se guardo en el telefono.
class AvisoSinConexion extends StatefulWidget {
  const AvisoSinConexion({
    super.key,
    required this.conectividad,
    required this.child,
  });

  final ConectividadService conectividad;
  final Widget child;

  @override
  State<AvisoSinConexion> createState() => _AvisoSinConexionState();
}

class _AvisoSinConexionState extends State<AvisoSinConexion> {
  /// Se pide una sola vez: si se pidiera en cada build, cada redibujo
  /// abriria una suscripcion nueva y el aviso se quedaria atorado.
  late final Stream<bool> _enLinea = widget.conectividad.enLinea;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return StreamBuilder<bool>(
      stream: _enLinea,
      initialData: true,
      builder: (context, estado) {
        final sinRed = estado.data == false;
        return Column(
          children: [
            if (sinRed)
              Material(
                color: TemaApp.verdeOscuro,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: TemaApp.lima),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sin conexión a internet. Verás lo último que '
                            'se guardó y los cambios se enviarán al volver.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: sinRed,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}
