import 'dart:io';
import 'package:flutter/material.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../services/ubicacion_service.dart';

/// Pantalla de Detalle de Pedido (SQLite).
/// Permite visualizar toda la información del pedido, geolocalización,
/// fotografía del comprobante, actualizar su estado y eliminarlo.
class DetallePedidoScreen extends StatefulWidget {
  final Pedido? pedido;

  const DetallePedidoScreen({super.key, this.pedido});

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  late Pedido _pedidoActual;
  final PedidoRepository _repo = PedidoRepository();
  bool _fueModificado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pedido != null) {
      _pedidoActual = widget.pedido!;
    } else {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Pedido) {
        _pedidoActual = args;
      }
    }
  }

  Color _colorPorEstado(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return Colors.orange;
      case EstadoPedido.confirmado:
        return Colors.blue;
      case EstadoPedido.enCamino:
        return Colors.purple;
      case EstadoPedido.entregado:
        return Colors.green;
      case EstadoPedido.cancelado:
        return Colors.red;
    }
  }

  Future<void> _cambiarEstado(EstadoPedido nuevoEstado) async {
    if (_pedidoActual.id == null) return;
    await _repo.actualizarEstado(_pedidoActual.id!, nuevoEstado);
    setState(() {
      _pedidoActual = _pedidoActual.copyWith(estado: nuevoEstado);
      _fueModificado = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a: ${nuevoEstado.name.toUpperCase()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmarEliminacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar pedido?'),
        content: Text(
          'Esta acción eliminará permanentemente el pedido ${_pedidoActual.codigo} de la base de datos SQLite y su foto comprobante asociada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );

    if (confirmar == true && _pedidoActual.id != null) {
      await _repo.eliminarPedido(_pedidoActual.id!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final distanciaKm = (_pedidoActual.latitud != null && _pedidoActual.longitud != null)
        ? UbicacionService.calcularDistanciaPlazaDeArmas(
            _pedidoActual.latitud!,
            _pedidoActual.longitud!,
          )
        : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_fueModificado);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pedido ${_pedidoActual.codigo}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Eliminar pedido de SQLite',
              onPressed: _confirmarEliminacion,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarjeta de Estado y Fecha
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Registro',
                          style: tema.textTheme.bodySmall?.copyWith(
                            color: tema.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_pedidoActual.fecha.day.toString().padLeft(2, '0')}/'
                          '${_pedidoActual.fecha.month.toString().padLeft(2, '0')}/'
                          '${_pedidoActual.fecha.year} '
                          '${_pedidoActual.fecha.hour.toString().padLeft(2, '0')}:'
                          '${_pedidoActual.fecha.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _colorPorEstado(_pedidoActual.estado).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _colorPorEstado(_pedidoActual.estado),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _pedidoActual.estado.name.toUpperCase(),
                        style: TextStyle(
                          color: _colorPorEstado(_pedidoActual.estado),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cambiar Estado Dropdown
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.sync_alt_rounded),
                    const SizedBox(width: 12),
                    const Text('Actualizar estado:'),
                    const Spacer(),
                    DropdownButton<EstadoPedido>(
                      value: _pedidoActual.estado,
                      underline: const SizedBox(),
                      items: EstadoPedido.values.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (nuevo) {
                        if (nuevo != null && nuevo != _pedidoActual.estado) {
                          _cambiarEstado(nuevo);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta Datos del Cliente
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: tema.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Datos del Cliente',
                          style: tema.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _itemFila('Cliente:', _pedidoActual.clienteNombre),
                    _itemFila('Teléfono:', _pedidoActual.clienteTelefono),
                    _itemFila('Correo:', _pedidoActual.clienteCorreo),
                    _itemFila('Distrito:', _pedidoActual.distrito),
                    _itemFila('Dirección:', _pedidoActual.direccion),
                    if (_pedidoActual.referencia != null &&
                        _pedidoActual.referencia!.isNotEmpty)
                      _itemFila('Referencia:', _pedidoActual.referencia!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta Productos y Pago
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag, color: tema.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Resumen de Productos',
                          style: tema.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      _pedidoActual.resumenItems,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    _itemFila('Método de Pago:', _pedidoActual.metodoPago),
                    _itemFila('Subtotal:', 'S/ ${_pedidoActual.subtotal.toStringAsFixed(2)}'),
                    _itemFila('Costo de Envío:', 'S/ ${_pedidoActual.costoEnvio.toStringAsFixed(2)}'),
                    if (_pedidoActual.descuento > 0)
                      _itemFila('Descuento:', '-S/ ${_pedidoActual.descuento.toStringAsFixed(2)}'),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL PAGADO:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'S/ ${_pedidoActual.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: tema.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta Sensores: GPS y Distancia a Plaza de Armas
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Geolocalización GPS (Sensor)',
                          style: tema.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_pedidoActual.latitud != null && _pedidoActual.longitud != null) ...[
                      _itemFila('Latitud:', _pedidoActual.latitud!.toStringAsFixed(6)),
                      _itemFila('Longitud:', _pedidoActual.longitud!.toStringAsFixed(6)),
                      if (distanciaKm != null)
                        _itemFila(
                          'Distancia al centro:',
                          '${distanciaKm.toStringAsFixed(2)} km de la Plaza de Armas del Cusco',
                        ),
                    ] else ...[
                      const Text(
                        'Sin coordenadas registradas.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta Comprobante de Pago (Cámara)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.camera_alt, color: tema.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Comprobante Digital (Cámara)',
                          style: tema.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_pedidoActual.fotoComprobantePath != null &&
                        File(_pedidoActual.fotoComprobantePath!).existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pedidoActual.fotoComprobantePath!),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: tema.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: tema.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: tema.colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pago verificado electrónicamente / Sin imagen adjunta',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _itemFila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              etiqueta,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }
}
