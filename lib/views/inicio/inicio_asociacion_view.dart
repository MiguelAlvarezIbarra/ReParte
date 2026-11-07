import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../viewmodels/mis_donaciones_viewmodel.dart';
import '../../widgets/encabezado_inicio.dart';
import '../../widgets/titulo_pestana.dart';
import '../donaciones/lista_donaciones.dart';
import '../donaciones/mis_donaciones_view.dart';
import '../mapa/mapa_donaciones_view.dart';
import '../perfil/perfil_view.dart';

/// Pantalla principal de la asociacion, con barra inferior:
/// donaciones disponibles, mapa, sus reservas y su perfil.
class InicioAsociacionView extends StatefulWidget {
  const InicioAsociacionView({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<InicioAsociacionView> createState() => _InicioAsociacionViewState();
}

class _InicioAsociacionViewState extends State<InicioAsociacionView> {
  int _pestana = 0;

  Widget _contenido() {
    final usuario = widget.usuario;
    switch (_pestana) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloPestana('Mapa de donaciones'),
            Expanded(child: MapaDonacionesView(asociacionId: usuario.id)),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloPestana('Mis reservas'),
            Expanded(
              child: MisDonacionesView(
                usuarioId: usuario.id,
                dueno: DuenoLista.asociacion,
              ),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TituloPestana('Perfil'),
            Expanded(child: PerfilView(usuario: usuario)),
          ],
        );
      default:
        return Column(
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
            Expanded(
              child: ListaDonaciones(
                asociacionId: usuario.id,
                conBuscador: true,
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _contenido(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestana,
        onDestinationSelected: (i) => setState(() => _pestana = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Mis reservas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
