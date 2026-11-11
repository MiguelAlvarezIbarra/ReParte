import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../core/utilidades/validadores.dart';
import '../../repositories/donacion_repository.dart';
import '../../services/selector_foto_service.dart';
import '../../services/ubicacion_service.dart';
import '../../viewmodels/publicar_donacion_viewmodel.dart';
import '../../widgets/imagen_donacion.dart';
import '../../widgets/mensaje_error.dart';
import '../mapa/seleccionar_ubicacion_view.dart';

/// Formulario con el que un donante publica una donacion.
/// Guarda la donacion con su foto opcional (T34) y su punto de entrega
/// (con coordenadas y direccion, T15).
class PublicarDonacionView extends StatefulWidget {
  const PublicarDonacionView({super.key});

  /// Abre el formulario con su propio ViewModel, a nombre de [donanteId].
  static Future<bool> abrir(
    BuildContext context, {
    required String donanteId,
    UbicacionService? ubicacionService,
    SelectorFotoService? selectorFotoService,
  }) async {
    final repo = context.read<DonacionRepository>();
    var ubicacion = ubicacionService;
    if (ubicacion == null) {
      try {
        ubicacion = context.read<UbicacionService>();
      } on ProviderNotFoundException {
        ubicacion = null;
      }
    }
    var selectorFoto = selectorFotoService;
    if (selectorFoto == null) {
      try {
        selectorFoto = context.read<SelectorFotoService>();
      } on ProviderNotFoundException {
        selectorFoto = null;
      }
    }
    final publicada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PublicarDonacionViewModel(
            repo,
            donanteId: donanteId,
            ubicacionService: ubicacion,
            selectorFotoService: selectorFoto,
          ),
          child: const PublicarDonacionView(),
        ),
      ),
    );
    return publicada ?? false;
  }

  @override
  State<PublicarDonacionView> createState() => _PublicarDonacionViewState();
}

class _PublicarDonacionViewState extends State<PublicarDonacionView> {
  final _formulario = GlobalKey<FormState>();
  final _descripcion = TextEditingController();
  final _cantidad = TextEditingController();
  final _fecha = TextEditingController();
  final _puntoNombre = TextEditingController();
  final _puntoDireccion = TextEditingController();
  DateTime? _fechaCaducidad;

  @override
  void dispose() {
    _descripcion.dispose();
    _cantidad.dispose();
    _fecha.dispose();
    _puntoNombre.dispose();
    _puntoDireccion.dispose();
    super.dispose();
  }

  String _formatear(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaCaducidad ?? hoy.add(const Duration(days: 1)),
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: 'Fecha de caducidad',
    );
    if (elegida == null) return;
    setState(() {
      _fechaCaducidad = elegida;
      _fecha.text = _formatear(elegida);
    });
  }

  Future<void> _usarMiUbicacion() async {
    final vm = context.read<PublicarDonacionViewModel>();
    final res = await vm.obtenerUbicacionActual();
    if (!mounted) return;
    if (res != null) {
      if (res.direccion != null && _puntoDireccion.text.trim().isEmpty) {
        _puntoDireccion.text = res.direccion!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación actual obtenida por GPS'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (vm.mensajeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.mensajeError!)),
      );
    }
  }

  Future<void> _seleccionarEnMapa() async {
    final vm = context.read<PublicarDonacionViewModel>();
    final res = await SeleccionarUbicacionView.abrir(
      context,
      latitudInicial: vm.latitud,
      longitudInicial: vm.longitud,
    );
    if (!mounted || res == null) return;
    vm.fijarUbicacion(lat: res.latitud, lng: res.longitud);
    if (res.direccion != null && _puntoDireccion.text.trim().isEmpty) {
      _puntoDireccion.text = res.direccion!;
    }
  }

  Future<void> _publicar() async {
    if (!_formulario.currentState!.validate()) return;
    final vm = context.read<PublicarDonacionViewModel>();
    final ok = await vm.publicar(
      descripcion: _descripcion.text,
      cantidad: _cantidad.text,
      fechaCaducidad: _fechaCaducidad,
      puntoNombre: _puntoNombre.text,
      puntoDireccion: _puntoDireccion.text,
      latitud: vm.latitud,
      longitud: vm.longitud,
      fotoUrl: vm.fotoUrl,
    );
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PublicarDonacionViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar donación')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Foto de la donación (opcional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (vm.tieneFoto) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        key: const Key('vista_previa_foto'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: TemaApp.verdeClaro,
                          child: ImagenDonacion(
                            fotoUrl: vm.fotoUrl,
                            respaldo: const Center(
                              child: Icon(
                                Icons.photo_outlined,
                                size: 64,
                                color: TemaApp.verde,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton.filled(
                          key: const Key('boton_quitar_foto'),
                          tooltip: 'Quitar foto',
                          style: IconButton.styleFrom(
                            backgroundColor: TemaApp.verdeOscuro,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: vm.quitarFoto,
                          icon: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('boton_tomar_foto'),
                      onPressed: vm.seleccionandoFoto ? null : vm.tomarFoto,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Tomar foto'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('boton_elegir_galeria'),
                      onPressed:
                          vm.seleccionandoFoto ? null : vm.elegirFotoDeGaleria,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Elegir de galería'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descripcion,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    helperText: 'Qué comida es y en qué estado está',
                    prefixIcon: Icon(Icons.restaurant_outlined),
                  ),
                  validator: (v) =>
                      Validadores.obligatorio(v, 'Describe qué vas a donar'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cantidad,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad (kg)',
                    prefixIcon: Icon(Icons.scale_outlined),
                  ),
                  validator: Validadores.cantidadKg,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fecha,
                  readOnly: true,
                  onTap: _elegirFecha,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de caducidad',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  validator: (_) => Validadores.caducidad(_fechaCaducidad),
                ),
                const SizedBox(height: 24),
                Text(
                  'Punto de entrega',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _puntoNombre,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del punto de entrega',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  validator: (v) => Validadores.obligatorio(
                      v, 'Escribe el nombre del punto de entrega'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _puntoDireccion,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) => Validadores.obligatorio(
                      v, 'Escribe la dirección de entrega'),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('boton_usar_mi_ubicacion'),
                      onPressed:
                          vm.obteniendoUbicacion ? null : _usarMiUbicacion,
                      icon: vm.obteniendoUbicacion
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: const Text('Mi ubicación'),
                    ),
                    OutlinedButton.icon(
                      key: const Key('boton_elegir_en_mapa'),
                      onPressed: _seleccionarEnMapa,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Elegir en el mapa'),
                    ),
                  ],
                ),
                if (vm.tieneCoordenadas) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: TemaApp.verdeClaro,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: TemaApp.verde.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: TemaApp.verde, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Coordenadas: ${vm.latitud!.toStringAsFixed(4)}, ${vm.longitud!.toStringAsFixed(4)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: TemaApp.verdeOscuro,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (vm.mensajeError != null) ...[
                  const SizedBox(height: 16),
                  MensajeError(vm.mensajeError!),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: vm.publicando ? null : _publicar,
                  child: vm.publicando
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publicar donación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
