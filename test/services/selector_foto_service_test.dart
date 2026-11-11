import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reparte/services/selector_foto_service.dart';

class _ImagePickerEspia extends ImagePicker {
  ImageSource? fuenteRecibida;
  double? maxWidthRecibido;
  double? maxHeightRecibido;
  int? imageQualityRecibida;
  XFile? respuesta = XFile('/tmp/pan_reducido.jpg');

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    fuenteRecibida = source;
    maxWidthRecibido = maxWidth;
    maxHeightRecibido = maxHeight;
    imageQualityRecibida = imageQuality;
    return respuesta;
  }
}

void main() {
  late _ImagePickerEspia picker;
  late ImagePickerSelectorFotoService servicio;

  setUp(() {
    picker = _ImagePickerEspia();
    servicio = ImagePickerSelectorFotoService(picker: picker);
  });

  test('tomarFoto usa la camara y reduce el tamano de la imagen (T34)',
      () async {
    final ruta = await servicio.tomarFoto();

    expect(ruta, '/tmp/pan_reducido.jpg');
    expect(picker.fuenteRecibida, ImageSource.camera);
    expect(
      picker.maxWidthRecibido,
      ImagePickerSelectorFotoService.anchoMaximo,
    );
    expect(
      picker.maxHeightRecibido,
      ImagePickerSelectorFotoService.altoMaximo,
    );
    expect(
      picker.imageQualityRecibida,
      ImagePickerSelectorFotoService.calidad,
    );
  });

  test('elegirDeGaleria usa la galeria y reduce el tamano de la imagen (T34)',
      () async {
    final ruta = await servicio.elegirDeGaleria();

    expect(ruta, '/tmp/pan_reducido.jpg');
    expect(picker.fuenteRecibida, ImageSource.gallery);
    expect(
      picker.maxWidthRecibido,
      ImagePickerSelectorFotoService.anchoMaximo,
    );
    expect(
      picker.maxHeightRecibido,
      ImagePickerSelectorFotoService.altoMaximo,
    );
    expect(
      picker.imageQualityRecibida,
      ImagePickerSelectorFotoService.calidad,
    );
  });

  test('devuelve null cuando el usuario cancela', () async {
    picker.respuesta = null;

    expect(await servicio.tomarFoto(), isNull);
  });
}
