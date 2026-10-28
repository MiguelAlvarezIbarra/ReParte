import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utilidades/validadores.dart';
import '../../repositories/donacion_repository.dart';
import '../../viewmodels/publicar_donacion_viewmodel.dart';
import '../../widgets/mensaje_error.dart';

/// Formulario con el que un donante publica una donacion.
/// Guarda la donacion y se cierra devolviendo true; si cancela, devuelve false.
class PublicarDonacionView extends StatefulWidget {
  const PublicarDonacionView({super.key});

  /// Abre el formulario con su propio ViewModel, a nombre de [donanteId].
  static Future<bool> abrir(
    BuildContext context, {
    required String donanteId,
  }) async {
    final repo = context.read<DonacionRepository>();
    final publicada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PublicarDonacionViewModel(repo, donanteId: donanteId),
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

  Future<void> _publicar() async {
    if (!_formulario.currentState!.validate()) return;
    final ok = await context.read<PublicarDonacionViewModel>().publicar(
          descripcion: _descripcion.text,
          cantidad: _cantidad.text,
          fechaCaducidad: _fechaCaducidad,
          puntoNombre: _puntoNombre.text,
          puntoDireccion: _puntoDireccion.text,
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
                  onFieldSubmitted: (_) => _publicar(),
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) => Validadores.obligatorio(
                      v, 'Escribe la dirección de entrega'),
                ),
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
