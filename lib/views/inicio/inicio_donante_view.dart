import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../widgets/boton_cerrar_sesion.dart';
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
      appBar: AppBar(
        title: const Text('Mis donaciones'),
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
          // TODO(T22): listar las donaciones del donante.
          const Expanded(
            child: EstadoVacio(
              icono: Icons.inventory_2_outlined,
              titulo: 'Aún no has publicado donaciones',
              mensaje: 'Cuando te sobre comida en buen estado, publícala '
                  'y las asociaciones cercanas podrán recogerla.',
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _publicar(context),
        icon: const Icon(Icons.add),
        label: const Text('Publicar donación'),
      ),
    );
  }
}
