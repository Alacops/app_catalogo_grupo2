import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favoritos_provider.dart';
import '../widgets/grilla_productos.dart';

/// Pantalla de favoritos: reacciona al [FavoritosProvider] y se actualiza
/// automáticamente cuando el usuario marca o desmarca productos.
class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mis Favoritos',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<FavoritosProvider>(
        builder: (context, favoritos, _) {
          final productos = favoritos.productos;
          if (productos.isEmpty) {
            return const _EstadoVacio();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Text(
                  '${productos.length} producto(s) guardado(s)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ),
              Expanded(
                child: GrillaProductos(productos: productos, propioScroll: true),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text('Aún no tienes favoritos',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          const Text('Toca el corazón ♥ de un producto para guardarlo aquí.',
              style: TextStyle(fontSize: 12.5, color: Colors.black45)),
        ],
      ),
    );
  }
}
