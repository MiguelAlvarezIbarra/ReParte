import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../core/utilidades/formato.dart';
import '../../models/donacion.dart';
import '../../repositories/donacion_repository.dart';
import '../../repositories/usuario_repository.dart';
import '../../viewmodels/detalle_donacion_viewmodel.dart';
import '../../widgets/etiqueta.dart';
import '../../widgets/boton_como_llegar.dart';
import '../../widgets/boton_ver_ruta.dart';
import '../../widgets/ilustracion_alimento.dart';
import '../../widgets/imagen_donacion.dart';
import '../../widgets/mensaje_error.dart';
import 'reserva_confirmada_view.dart';

/// Todos los datos de una donacion: la comida, quien la dona y donde se recoge.
class DetalleDonacionView extends StatelessWidget {
  const DetalleDonacionView({super.key});

  /// Abre el detalle de [donacion] con su propio ViewModel.
  /// Necesita un DonacionRepository y un UsuarioRepository en el Provider.
  /// Con [asociacionId] muestra el boton para reservarla; con [usuarioId]
  /// (el donante o la asociacion) permite marcarla como entregada.
  static Future<void> abrir(
    BuildContext context,
    Donacion donacion, {
    String? asociacionId,
    String? usuarioId,
  }) {
    final donaciones = context.read<DonacionRepository>();
    final usuarios = context.read<UsuarioRepository>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => DetalleDonacionViewModel(
            donacion: donacion,
            donaciones: donaciones,
            usuarios: usuarios,
            asociacionId: asociacionId,
            usuarioId: usuarioId,
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
    final texto = Theme.of(context).textTheme;
    final estilo = IlustracionAlimento.estilo(donacion.descripcion);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la donación'),
        backgroundColor: estilo.fondo,
      ),
      bottomNavigationBar: vm.usuarioId == null ? null : const _PanelReserva(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              color: estilo.fondo,
              child: ImagenDonacion(
                fotoUrl: donacion.fotoUrl,
                respaldo: Center(
                  child: Icon(estilo.icono, size: 104, color: estilo.trazo),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          donacion.descripcion,
                          style: texto.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Formato.kilos(donacion.cantidadKg),
                        style: texto.headlineSmall?.copyWith(
                          color: TemaApp.verde,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Etiqueta(
                        Formato.estado(donacion.estado),
                        icono: Icons.info_outline,
                      ),
                      if (Formato.esHoy(donacion.caducidad))
                        const Etiqueta.destacada('Caduca hoy')
                      else
                        Etiqueta(
                          'Caduca el ${Formato.fecha(donacion.caducidad)}',
                          icono: Icons.event_outlined,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Dato(
                    icono: Icons.today_outlined,
                    etiqueta: 'Publicada',
                    valor: Formato.fecha(donacion.creadaEn),
                  ),
                  const SizedBox(height: 12),
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
                        if (BotonComoLlegar.tieneUbicacion(punto)) ...[
                          const SizedBox(height: 8),
                          BotonVerRuta(punto: punto),
                          const SizedBox(height: 8),
                          BotonComoLlegar(punto: punto),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Parte de abajo del detalle segun quien la mira y en que estado esta:
/// reservar, marcar como entregada o el aviso de que ya se entrego.
class _PanelReserva extends StatelessWidget {
  const _PanelReserva();

  Future<void> _reservar(BuildContext context) async {
    final vm = context.read<DetalleDonacionViewModel>();
    final ok = await vm.reservar();
    if (!ok || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReservaConfirmadaView(
          donacion: vm.donacion,
          punto: vm.punto,
          donante: vm.donante,
        ),
      ),
    );
  }

  Future<void> _entregar(BuildContext context) async {
    final vm = context.read<DetalleDonacionViewModel>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('¿Marcar como entregada?'),
        content: const Text(
          'La donación quedará cerrada con la fecha de hoy y ya no se podrá '
          'cambiar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Sí, se entregó'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    final ok = await vm.marcarEntregada();
    if (!ok || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donación entregada. ¡Gracias!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleDonacionViewModel>();
    final donacion = vm.donacion;
    final esDonante = vm.usuarioId == donacion.donanteId;
    final reservada = donacion.estado == EstadoDonacion.reservada;
    final error = vm.errorReserva ?? vm.errorEntrega;

    final hijos = <Widget>[
      if (error != null) ...[
        MensajeError(error),
        const SizedBox(height: 12),
      ],
    ];
    if (donacion.estado == EstadoDonacion.entregada) {
      hijos.add(_Aviso(
        icono: Icons.verified_outlined,
        texto: donacion.entregadaEn == null
            ? 'Donación entregada.'
            : 'Entregada el ${Formato.fecha(donacion.entregadaEn!)}. '
                'Se rescataron ${Formato.kilos(donacion.cantidadKg)} de comida.',
      ));
    } else if (vm.reservadaPorMi) {
      hijos.add(const _Aviso(
        icono: Icons.check_circle,
        texto: 'Reservada por ti. Pasa a recogerla al punto de entrega.',
      ));
    } else if (esDonante && reservada) {
      hijos.add(const _Aviso(
        icono: Icons.bookmark,
        texto: 'Reservada. La asociación pasará a recogerla.',
      ));
    } else if (vm.asociacionId != null) {
      hijos.add(FilledButton.icon(
        onPressed: vm.puedeReservar ? () => _reservar(context) : null,
        icon: vm.reservando
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.bookmark_add_outlined),
        label: const Text('Reservar donación'),
      ));
    }
    if (vm.puedeEntregar || vm.entregando) {
      hijos
        ..add(const SizedBox(height: 12))
        ..add(FilledButton.icon(
          onPressed: vm.puedeEntregar ? () => _entregar(context) : null,
          icon: vm.entregando
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.task_alt),
          label: const Text('Marcar como entregada'),
        ));
    }
    if (hijos.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: hijos,
        ),
      ),
    );
  }
}

/// Recuadro verde claro con un mensaje de estado.
class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colores.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icono, color: colores.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(texto)),
        ],
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
              style: const TextStyle(color: TemaApp.gris),
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
    return Text(mensaje, style: const TextStyle(color: TemaApp.gris));
  }
}
