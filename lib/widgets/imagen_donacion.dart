import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Muestra la foto de una donación (archivo local, URL remota o base64)
/// y, si no tiene foto o no se puede cargar, muestra [respaldo] (T34/T35).
class ImagenDonacion extends StatelessWidget {
  const ImagenDonacion({
    super.key,
    required this.fotoUrl,
    required this.respaldo,
    this.fit = BoxFit.cover,
  });

  final String? fotoUrl;
  final Widget respaldo;
  final BoxFit fit;

  static Uint8List? _decodificarDataUri(String uri) {
    final coma = uri.indexOf(',');
    if (coma == -1 || coma + 1 >= uri.length) return null;
    try {
      return base64Decode(uri.substring(coma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fuente = fotoUrl?.trim();
    if (fuente == null || fuente.isEmpty) return respaldo;

    if (fuente.startsWith('http://') || fuente.startsWith('https://')) {
      return Image.network(
        fuente,
        key: const Key('imagen_donacion'),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => respaldo,
      );
    }

    if (fuente.startsWith('data:image')) {
      final bytes = _decodificarDataUri(fuente);
      if (bytes == null) return respaldo;
      return Image.memory(
        bytes,
        key: const Key('imagen_donacion'),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => respaldo,
      );
    }

    return Image.file(
      File(fuente),
      key: const Key('imagen_donacion'),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => respaldo,
    );
  }
}
