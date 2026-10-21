import 'package:flutter/material.dart';
import '../models/producto.dart';

/// ============================================================================
/// SECCIÓN «TAMBIÉN TE PUEDE INTERESAR» (Requerimiento 5)
/// Carrusel horizontal con ListView que presenta tarjetas compactas de recomendación
/// ============================================================================

class SeccionInteresar extends StatelessWidget {
  final List<Producto> productos;

  const SeccionInteresar({
    super.key,
    required this.productos,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 14, bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Imagen cuadrada
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    producto.imagenUrl,
                    width: 90,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        color: const Color(0xFFEFEBE9),
                        child: const Icon(Icons.coffee, color: Colors.black26),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Información textual
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9971F).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          producto.origen.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF946A00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 13, color: Color(0xFFFFA000)),
                          const SizedBox(width: 3),
                          Text(
                            producto.puntuacion.toString(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'S/ ${producto.precioActual.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7A1F2B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
