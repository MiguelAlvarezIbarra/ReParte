import 'package:image_picker/image_picker.dart';

/// De dónde obtiene el donante la foto de la donación (T34).
enum OrigenFoto { camara, galeria }

/// Servicio para tomar una foto con la cámara o elegirla de la galería,
/// reduciendo su tamaño antes de usarla o subirla (T34).
/// Desacopla `image_picker` del ViewModel para permitir pruebas unitarias.
abstract class SelectorFotoService {
  /// Abre la cámara o la galería según [origen] y devuelve la ruta de la
  /// foto ya reducida de tamaño, o `null` si el usuario canceló.
  Future<String?> seleccionarFoto(OrigenFoto origen);

  /// Toma una foto con la cámara del teléfono.
  Future<String?> tomarFoto() => seleccionarFoto(OrigenFoto.camara);

  /// Elige una foto de la galería del teléfono.
  Future<String?> elegirDeGaleria() => seleccionarFoto(OrigenFoto.galeria);
}

/// Implementación real con `image_picker` que reduce las dimensiones y
/// comprime la imagen antes de entregarla.
class ImagePickerSelectorFotoService implements SelectorFotoService {
  const ImagePickerSelectorFotoService({ImagePicker? picker})
      : _picker = picker;

  /// Límite de dimensiones en píxeles para reducir la foto antes de subirla.
  static const double anchoMaximo = 800;
  static const double altoMaximo = 800;

  /// Calidad JPEG (0 a 100) para mantener la foto ligera (~100-150 KB).
  static const int calidad = 70;

  final ImagePicker? _picker;

  ImagePicker get _pickerInstance => _picker ?? ImagePicker();

  @override
  Future<String?> seleccionarFoto(OrigenFoto origen) async {
    final fuente = switch (origen) {
      OrigenFoto.camara => ImageSource.camera,
      OrigenFoto.galeria => ImageSource.gallery,
    };
    final archivo = await _pickerInstance.pickImage(
      source: fuente,
      maxWidth: anchoMaximo,
      maxHeight: altoMaximo,
      imageQuality: calidad,
    );
    if (archivo == null) return null;
    final ruta = archivo.path.trim();
    return ruta.isEmpty ? null : ruta;
  }

  @override
  Future<String?> tomarFoto() => seleccionarFoto(OrigenFoto.camara);

  @override
  Future<String?> elegirDeGaleria() => seleccionarFoto(OrigenFoto.galeria);
}
