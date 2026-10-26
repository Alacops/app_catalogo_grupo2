import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../providers/favoritos_provider.dart';

/// Pantalla de Detalle de Producto con navegación tipada, selección de cantidad,
/// pestañas informativas (Descripción, Origen, Garantía) y acciones de compra.
class DetalleProductoScreen extends StatefulWidget {
  final Producto? producto;

  const DetalleProductoScreen({super.key, this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  int _cantidad = 1;

  Producto _resolverProducto(BuildContext context) {
    if (widget.producto != null) return widget.producto!;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Producto) return args;
    throw StateError('DetalleProductoScreen requiere un objeto Producto');
  }

  @override
  Widget build(BuildContext context) {
    final producto = _resolverProducto(context);
    final tema = Theme.of(context);
    final favProvider = context.watch<FavoritosProvider>();
    final carritoProvider = context.read<CarritoProvider>();
    final esFavorito = favProvider.esFavorito(producto.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar expandible con imagen y botones de acción
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    producto.imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: tema.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.coffee_rounded,
                        size: 96,
                        color: tema.colorScheme.primary,
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: tema.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            producto.categoria.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          producto.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 6,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: esFavorito ? Colors.redAccent : Colors.white,
                ),
                tooltip: esFavorito ? 'Quitar de favoritos' : 'Agregar a favoritos',
                onPressed: () => favProvider.alternarFavorito(producto),
              ),
            ],
          ),

          // Contenido del producto
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precios y puntuación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'S/ ${producto.precioActual.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: tema.colorScheme.primary,
                                ),
                              ),
                              if (producto.tieneDescuento) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'S/ ${producto.precioAnterior!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.lineThrough,
                                    color: tema.colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    producto.descuento!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Impuestos incluidos · Envío a todo Cusco',
                            style: tema.textTheme.bodySmall?.copyWith(
                              color: tema.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tema.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              producto.puntuacion.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ' (${producto.resenas})',
                              style: TextStyle(
                                fontSize: 12,
                                color: tema.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Selector de cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cantidad',
                        style: tema.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: tema.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _cantidad > 1
                                  ? () => setState(() => _cantidad--)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_cantidad',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _cantidad < 99
                                  ? () => setState(() => _cantidad++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pestañas informativas
                  DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: tema.colorScheme.primary,
                          indicatorColor: tema.colorScheme.primary,
                          tabs: const [
                            Tab(text: 'Descripción'),
                            Tab(text: 'Origen'),
                            Tab(text: 'Garantía'),
                          ],
                        ),
                        SizedBox(
                          height: 180,
                          child: TabBarView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  producto.descripcion,
                                  style: tema.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 18,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Zona de Cultivo: ${producto.origen}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Cosechado bajo sombra en valles cusqueños a más de 1,800 msnm. '
                                      'Apoyo directo a familias productoras de La Convención y Valle Sagrado.',
                                      style: TextStyle(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Certificación de Comercio Justo y Calidad UNSAAC.',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Garantía de frescura de tostado menor a 15 días. '
                                      'Cambio inmediato si el producto no cumple con tus expectativas de sabor.',
                                      style: TextStyle(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barra inferior con botón de agregar al carrito y comprar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tema.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Al Carrito'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: tema.colorScheme.primary),
                  ),
                  onPressed: () {
                    for (int i = 0; i < _cantidad; i++) {
                      carritoProvider.agregarProducto(producto);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '$_cantidad x ${producto.nombre} agregado al carrito',
                        ),
                        action: SnackBarAction(
                          label: 'VER CARRITO',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/carrito');
                          },
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.flash_on_rounded),
                  label: const Text('Comprar Ya'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    for (int i = 0; i < _cantidad; i++) {
                      carritoProvider.agregarProducto(producto);
                    }
                    Navigator.of(context).pushNamed('/checkout');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
