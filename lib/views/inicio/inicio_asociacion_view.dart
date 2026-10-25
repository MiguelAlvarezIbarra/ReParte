import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../widgets/boton_cerrar_sesion.dart';
import '../donaciones/lista_donaciones.dart';

/// Pantalla principal de la asociacion: donaciones disponibles cerca.
class InicioAsociacionView extends StatelessWidget {
  const InicioAsociacionView({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donaciones disponibles'),
        actions: const [BotonCerrarSesion()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              'Hola, ${usuario.nombre}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Expanded(child: ListaDonaciones()),
        ],
      ),
    );
  }
}
