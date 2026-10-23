import 'package:flutter/material.dart';

import '../models/producto.dart';
import 'tarjeta_producto.dart';

/// Rejilla adaptativa reutilizable de productos (DRY).
///
/// Reutiliza la lógica de columnas según el ancho (LayoutBuilder) en el
/// catálogo, las ofertas y los favoritos.
class GrillaProductos extends StatelessWidget {
  final List<Producto> productos;

  /// Si es true, la rejilla hace scroll por sí misma (pantallas dedicadas).
  final bool propioScroll;

  const GrillaProductos({
    super.key,
    required this.productos,
    this.propioScroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int crossAxisCount;
          final double childAspectRatio;
          if (constraints.maxWidth < 600) {
            crossAxisCount = 2;
            childAspectRatio = 0.66;
          } else if (constraints.maxWidth < 840) {
            crossAxisCount = 3;
            childAspectRatio = 0.70;
          } else {
            crossAxisCount = 4;
            childAspectRatio = 0.73;
          }

          return GridView.builder(
            shrinkWrap: !propioScroll,
            physics: propioScroll
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) =>
                TarjetaProducto(producto: productos[index]),
          );
        },
      ),
    );
  }
}
