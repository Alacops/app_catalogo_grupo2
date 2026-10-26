import 'package:flutter/material.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';

/// Pantalla de Historial de Pedidos persistidos en SQLite.
/// Cumple con la rúbrica de persistencia y navegación con paso y retorno de resultados.
class HistorialPedidosScreen extends StatefulWidget {
  const HistorialPedidosScreen({super.key});

  @override
  State<HistorialPedidosScreen> createState() => _HistorialPedidosScreenState();
}

class _HistorialPedidosScreenState extends State<HistorialPedidosScreen> {
  final PedidoRepository _repo = PedidoRepository();
  final TextEditingController _busquedaController = TextEditingController();

  String _filtroEstado = 'TODOS';
  late Future<List<Pedido>> _pedidosFuture;

  final List<String> _estadosFiltro = [
    'TODOS',
    'PENDIENTE',
    'CONFIRMADO',
    'EN_CAMINO',
    'ENTREGADO',
    'CANCELADO',
  ];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _cargarPedidos() {
    setState(() {
      _pedidosFuture = _repo.obtenerPedidos(
        filtroEstado: _filtroEstado,
        busqueda: _busquedaController.text,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pedidos (SQLite)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar lista',
            onPressed: _cargarPedidos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda en SQLite
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por código, cliente o teléfono...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaController.clear();
                          _cargarPedidos();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (_) => _cargarPedidos(),
            ),
          ),

          // Chips de filtro por estado
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _estadosFiltro.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final estado = _estadosFiltro[index];
                final seleccionado = _filtroEstado == estado;
                return ChoiceChip(
                  label: Text(estado),
                  selected: seleccionado,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _filtroEstado = estado;
                        _cargarPedidos();
                      });
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Lista reactiva con FutureBuilder y Pull to Refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _cargarPedidos(),
              child: FutureBuilder<List<Pedido>>(
                future: _pedidosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Error al consultar SQLite: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final pedidos = snapshot.data ?? [];

                  if (pedidos.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 72,
                                color: tema.colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron pedidos',
                                style: tema.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Los pedidos registrados desde el carrito o checkout se almacenan aquí en SQLite de forma permanente.',
                                textAlign: TextAlign.center,
                                style: tema.textTheme.bodyMedium?.copyWith(
                                  color: tema.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) {
                      final pedido = pedidos[index];
                      final colorEstado = _colorPorEstado(pedido.estado);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final huboCambios = await Navigator.of(context).pushNamed(
                              '/pedidos/detalle',
                              arguments: pedido,
                            );
                            if (huboCambios == true) {
                              _cargarPedidos();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pedido.codigo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorEstado.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorEstado,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        pedido.estado.name.toUpperCase(),
                                        style: TextStyle(
                                          color: colorEstado,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Cliente: ${pedido.clienteNombre} (${pedido.distrito})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: tema.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pedido.resumenItems,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: tema.textTheme.bodySmall?.copyWith(
                                    color: tema.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${pedido.fecha.day.toString().padLeft(2, '0')}/'
                                      '${pedido.fecha.month.toString().padLeft(2, '0')}/'
                                      '${pedido.fecha.year}',
                                      style: tema.textTheme.bodySmall?.copyWith(
                                        color: tema.colorScheme.outline,
                                      ),
                                    ),
                                    Text(
                                      'Total: S/ ${pedido.total.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: tema.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
