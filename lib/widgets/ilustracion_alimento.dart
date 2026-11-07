import 'package:flutter/material.dart';

/// Cuadro de color con un icono segun el tipo de comida.
/// Sustituye a las fotos mientras no se suban imagenes de las donaciones.
class IlustracionAlimento extends StatelessWidget {
  const IlustracionAlimento({
    super.key,
    required this.descripcion,
    this.tamano = 92,
    this.radio = 16,
    this.etiqueta,
  });

  final String descripcion;
  final double tamano;
  final double radio;

  /// Texto en la esquina, por ejemplo los kilos.
  final String? etiqueta;

  /// Colores e icono que corresponden a la descripcion de la comida.
  static ({Color fondo, Color trazo, IconData icono}) estilo(String texto) {
    final t = texto.toLowerCase();
    bool tiene(List<String> palabras) => palabras.any(t.contains);
    if (tiene(['pan', 'bolillo', 'pastel', 'galleta', 'concha'])) {
      return (
        fondo: const Color(0xFFF4DDB4),
        trazo: const Color(0xFF7A4E17),
        icono: Icons.bakery_dining_outlined,
      );
    }
    if (tiene([
      'fruta',
      'verdura',
      'manzana',
      'platano',
      'plátano',
      'jitomate',
      'tomate',
      'lechuga',
      'naranja',
      'zanahoria'
    ])) {
      return (
        fondo: const Color(0xFFF6D2C4),
        trazo: const Color(0xFF8E3417),
        icono: Icons.eco_outlined,
      );
    }
    if (tiene(['leche', 'yogur', 'queso', 'lacteo', 'lácteo'])) {
      return (
        fondo: const Color(0xFFDCE6F2),
        trazo: const Color(0xFF2E4A6B),
        icono: Icons.local_drink_outlined,
      );
    }
    return (
      fondo: const Color(0xFFCFE6D8),
      trazo: const Color(0xFF1F5C50),
      icono: Icons.restaurant_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = estilo(descripcion);
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: e.fondo,
        borderRadius: BorderRadius.circular(radio),
      ),
      child: Stack(
        children: [
          Center(child: Icon(e.icono, size: tamano * 0.48, color: e.trazo)),
          if (etiqueta != null)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  etiqueta!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
