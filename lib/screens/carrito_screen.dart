import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_carrito.dart';
import '../providers/carrito_provider.dart';

/// Pantalla del carrito: lista editable (cantidades) con total y checkout.
class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mi Carrito',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!carrito.vacio)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vaciar carrito',
              onPressed: () => _confirmarVaciar(context),
            ),
        ],
      ),
      body: carrito.vacio
          ? const _CarritoVacio()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: carrito.lineas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _LineaCarrito(item: carrito.lineas[i]),
                  ),
                ),
                _ResumenTotal(total: carrito.total),
              ],
            ),
    );
  }

  Future<void> _confirmarVaciar(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Deseas eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CarritoProvider>().vaciar();
    }
  }
}

/// Una línea del carrito con controles de cantidad.
class _LineaCarrito extends StatelessWidget {
  final ItemCarrito item;
  const _LineaCarrito({required this.item});

  @override
  Widget build(BuildContext context) {
    final carrito = context.read<CarritoProvider>();
    final p = item.producto;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              p.imagenUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 64,
                height: 64,
                color: const Color(0xFFEFEBE9),
                child: const Icon(Icons.coffee, color: Colors.black26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('S/ ${p.precioActual.toStringAsFixed(2)} c/u',
                    style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _BotonCantidad(
                      icono: Icons.remove,
                      onTap: () => carrito.decrementar(p.id),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.cantidad}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    _BotonCantidad(
                      icono: Icons.add,
                      onTap: () => carrito.incrementar(p.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('S/ ${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF7A1F2B))),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.black38),
                tooltip: 'Quitar',
                onPressed: () => carrito.quitar(p.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  const _BotonCantidad({required this.icono, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1ECE4),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icono, size: 18, color: const Color(0xFF7A1F2B)),
        ),
      ),
    );
  }
}

/// Barra inferior con total y botón de checkout.
class _ResumenTotal extends StatelessWidget {
  final double total;
  const _ResumenTotal({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4DDD4))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total', style: TextStyle(fontSize: 12, color: Colors.black54)),
                Text('S/ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A1F2B))),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A1F2B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Realizar pedido',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  const _CarritoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          const Text('Tu carrito está vacío',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 4),
          const Text('Agrega productos desde el catálogo.',
              style: TextStyle(fontSize: 12.5, color: Colors.black45)),
        ],
      ),
    );
  }
}
