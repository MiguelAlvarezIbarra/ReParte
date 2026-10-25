import 'package:flutter/material.dart';
import 'lista_donaciones.dart';

/// Pantalla con la lista de donaciones disponibles.
/// Solo muestra lo que le indica el DonacionesViewModel (via ListaDonaciones).
class DonacionesView extends StatelessWidget {
  const DonacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donaciones disponibles')),
      body: const ListaDonaciones(),
    );
  }
}
