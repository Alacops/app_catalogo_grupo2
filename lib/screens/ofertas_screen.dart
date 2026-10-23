import 'package:flutter/material.dart';

import '../data/catalogo_data.dart';
import '../widgets/grilla_productos.dart';

/// Pantalla de ofertas: muestra solo los productos con descuento.
class OfertasScreen extends StatelessWidget {
  const OfertasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ofertas = CatalogoData.productos
        .where((p) => p.esOferta || p.tieneDescuento)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Ofertas',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ofertas.isEmpty
          ? const Center(child: Text('No hay ofertas por ahora.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    '${ofertas.length} productos en oferta',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),
                Expanded(
                  child: GrillaProductos(productos: ofertas, propioScroll: true),
                ),
              ],
            ),
    );
  }
}
