import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../providers/favoritos_provider.dart';

/// ============================================================================
/// TARJETA DE PRODUCTO (ahora con estado: favoritos y carrito)
/// - El corazón alterna el favorito (FavoritosProvider) y refleja su estado.
/// - El botón "+" agrega al carrito (CarritoProvider) y muestra la cantidad.
/// Se usa context.select para reconstruir solo cuando cambia ESTE producto.
/// ============================================================================

class TarjetaProducto extends StatelessWidget {
  final Producto producto;

  const TarjetaProducto({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    final esFavorito = context.select<FavoritosProvider, bool>(
      (p) => p.esFavorito(producto.id),
    );
    final cantidadEnCarrito = context.select<CarritoProvider, int>(
      (p) => p.cantidadDe(producto.id),
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pushNamed(
            '/producto/detalle',
            arguments: producto,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // 1. Imagen con insignia de descuento y botón de favorito
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    producto.imagenUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFEFEBE9),
                      child: const Center(
                        child: Icon(Icons.coffee, size: 40, color: Colors.black26),
                      ),
                    ),
                  ),
                ),

                // Insignia de descuento o novedad
                if (producto.tieneDescuento)
                  _Insignia(texto: producto.descuento!, color: const Color(0xFFC62828))
                else if (producto.esNovedad)
                  const _Insignia(texto: 'NUEVO', color: Color(0xFF2E7D32)),

                // Botón de favorito (toggle) con zona táctil de 48x48 dp
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context
                          .read<FavoritosProvider>()
                          .alternar(producto.id),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            esFavorito ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                            color: esFavorito
                                ? const Color(0xFFC62828)
                                : const Color(0xFF7A1F2B),
                            semanticLabel: esFavorito
                                ? 'Quitar de favoritos'
                                : 'Agregar a favoritos',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Información del producto
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.categoria.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF8D6E63),
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFFFA000)),
                          const SizedBox(width: 3),
                          Text(
                            producto.puntuacion.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${producto.resenas})',
                            style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Precios y botón de agregar al carrito
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (producto.precioAnterior != null)
                              Text(
                                'S/ ${producto.precioAnterior!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              'S/ ${producto.precioActual.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7A1F2B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      _BotonAgregar(
                        producto: producto,
                        cantidad: cantidadEnCarrito,
                      ),
                    ],
                  ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Insignia superior izquierda (descuento / novedad).
class _Insignia extends StatelessWidget {
  final String texto;
  final Color color;
  const _Insignia({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10.5,
          ),
        ),
      ),
    );
  }
}

/// Botón de agregar al carrito con badge de cantidad.
class _BotonAgregar extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  const _BotonAgregar({required this.producto, required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          context.read<CarritoProvider>().agregar(producto);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('«${producto.nombre}» agregado al carrito'),
                duration: const Duration(milliseconds: 1200),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF3E2723),
              ),
            );
        },
        child: Badge(
          isLabelVisible: cantidad > 0,
          label: Text('$cantidad'),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF7A1F2B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
