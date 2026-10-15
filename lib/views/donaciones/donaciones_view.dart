import 'package:flutter/material.dart';

/// Pantalla con la lista de donaciones disponibles.
/// Solo muestra lo que le indica el DonacionesViewModel (tarea T16).
class DonacionesView extends StatelessWidget {
  const DonacionesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donaciones disponibles')),
      body: const Center(child: Text('Pendiente: tarea T16')),
    );
  }
}
