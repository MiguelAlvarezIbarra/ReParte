import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../widgets/encabezado_inicio.dart';
import '../donaciones/lista_donaciones.dart';

/// Pantalla principal de la asociacion: donaciones disponibles cerca.
class InicioAsociacionView extends StatelessWidget {
  const InicioAsociacionView({super.key, required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EncabezadoInicio(nombre: usuario.nombre, subtitulo: 'Asociación'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              'Donaciones disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(child: ListaDonaciones(asociacionId: usuario.id)),
        ],
      ),
    );
  }
}
