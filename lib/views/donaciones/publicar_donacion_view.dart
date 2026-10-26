import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utilidades/validadores.dart';
import '../../viewmodels/publicar_donacion_viewmodel.dart';
import '../../widgets/mensaje_error.dart';

/// Formulario con el que un donante publica una donacion.
/// Al terminar devuelve los [DatosDonacion] capturados (o null si cancela).
class PublicarDonacionView extends StatefulWidget {
  const PublicarDonacionView({super.key});

  /// Abre el formulario con su propio ViewModel.
  static Future<DatosDonacion?> abrir(BuildContext context) {
    return Navigator.of(context).push<DatosDonacion>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PublicarDonacionViewModel(),
          child: const PublicarDonacionView(),
        ),
      ),
    );
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

  void _publicar() {
    if (!_formulario.currentState!.validate()) return;
    final vm = context.read<PublicarDonacionViewModel>();
    final ok = vm.preparar(
      descripcion: _descripcion.text,
      cantidad: _cantidad.text,
      fechaCaducidad: _fechaCaducidad,
      puntoNombre: _puntoNombre.text,
      puntoDireccion: _puntoDireccion.text,
    );
    if (ok) Navigator.of(context).pop(vm.borrador);
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
                  onPressed: _publicar,
                  child: const Text('Publicar donación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
