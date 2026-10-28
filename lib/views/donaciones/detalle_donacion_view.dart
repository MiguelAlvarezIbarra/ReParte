import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utilidades/formato.dart';
import '../../models/donacion.dart';
import '../../repositories/donacion_repository.dart';
import '../../repositories/usuario_repository.dart';
import '../../viewmodels/detalle_donacion_viewmodel.dart';

/// Todos los datos de una donacion: la comida, quien la dona y donde se recoge.
class DetalleDonacionView extends StatelessWidget {
  const DetalleDonacionView({super.key});

  /// Abre el detalle de [donacion] con su propio ViewModel.
  /// Necesita un DonacionRepository y un UsuarioRepository en el Provider.
  static Future<void> abrir(BuildContext context, Donacion donacion) {
    final donaciones = context.read<DonacionRepository>();
    final usuarios = context.read<UsuarioRepository>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => DetalleDonacionViewModel(
            donacion: donacion,
            donaciones: donaciones,
            usuarios: usuarios,
          )..cargar(),
          child: const DetalleDonacionView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleDonacionViewModel>();
    final donacion = vm.donacion;
    final donante = vm.donante;
    final punto = vm.punto;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la donación')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Seccion(
                titulo: 'Donación',
                hijos: [
                  Text(
                    donacion.descripcion,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _Dato(
                    icono: Icons.scale_outlined,
                    etiqueta: 'Cantidad',
                    valor: Formato.kilos(donacion.cantidadKg),
                  ),
                  _Dato(
                    icono: Icons.event_outlined,
                    etiqueta: 'Caduca',
                    valor: Formato.fecha(donacion.caducidad),
                  ),
                  _Dato(
                    icono: Icons.info_outline,
                    etiqueta: 'Estado',
                    valor: Formato.estado(donacion.estado),
                  ),
                  _Dato(
                    icono: Icons.today_outlined,
                    etiqueta: 'Publicada',
                    valor: Formato.fecha(donacion.creadaEn),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Seccion(
                titulo: 'Donante',
                hijos: [
                  if (vm.cargando)
                    const _Cargando()
                  else if (donante == null)
                    const _NoDisponible(
                      'No se pudo cargar la información del donante',
                    )
                  else ...[
                    _Dato(
                      icono: Icons.storefront_outlined,
                      etiqueta: 'Nombre',
                      valor: donante.nombre,
                    ),
                    if (donante.telefono.isNotEmpty)
                      _Dato(
                        icono: Icons.phone_outlined,
                        etiqueta: 'Teléfono',
                        valor: donante.telefono,
                      ),
                    _Dato(
                      icono: Icons.mail_outline,
                      etiqueta: 'Correo',
                      valor: donante.correo,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _Seccion(
                titulo: 'Ubicación de entrega',
                hijos: [
                  if (vm.cargando)
                    const _Cargando()
                  else if (punto == null)
                    const _NoDisponible(
                      'No se pudo cargar la ubicación de entrega',
                    )
                  else ...[
                    _Dato(
                      icono: Icons.place_outlined,
                      etiqueta: 'Lugar',
                      valor: punto.nombre,
                    ),
                    _Dato(
                      icono: Icons.map_outlined,
                      etiqueta: 'Dirección',
                      valor: punto.direccion,
                    ),
                    if (punto.horario.isNotEmpty)
                      _Dato(
                        icono: Icons.schedule_outlined,
                        etiqueta: 'Horario',
                        valor: punto.horario,
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bloque con titulo, con el mismo estilo de tarjeta que la lista.
class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12),
            ...hijos,
          ],
        ),
      ),
    );
  }
}

/// Una fila "icono  etiqueta  valor".
class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 84,
            child: Text(
              etiqueta,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _NoDisponible extends StatelessWidget {
  const _NoDisponible(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Text(mensaje, style: const TextStyle(color: Colors.black54));
  }
}
