import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../core/tema/tema_app.dart';
import '../../widgets/encabezado_inicio.dart';
import '../../widgets/estado_vacio.dart';
import '../donaciones/publicar_donacion_view.dart';

/// Pantalla principal del donante: sus donaciones y el boton para publicar.
class InicioDonanteView extends StatelessWidget {
  const InicioDonanteView({super.key, required this.usuario});

  final Usuario usuario;

  Future<void> _publicar(BuildContext context) async {
    final publicada =
        await PublicarDonacionView.abrir(context, donanteId: usuario.id);
    if (!publicada || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donación publicada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EncabezadoInicio(
            nombre: usuario.nombre,
            subtitulo: 'Donante',
            accion: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: TemaApp.lima,
                foregroundColor: TemaApp.verdeOscuro,
              ),
              onPressed: () => _publicar(context),
              icon: const Icon(Icons.add),
              label: const Text('Publicar donación'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              'Mis donaciones',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          // TODO(T22): listar las donaciones del donante con su estado.
          const Expanded(
            child: EstadoVacio(
              icono: Icons.inventory_2_outlined,
              titulo: 'Aquí verás tus donaciones',
              mensaje: 'Cuando te sobre comida en buen estado, publícala '
                  'y las asociaciones cercanas podrán recogerla.',
            ),
          ),
        ],
      ),
    );
  }
}
