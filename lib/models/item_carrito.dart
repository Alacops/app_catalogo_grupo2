import 'producto.dart';

/// Representa una línea del carrito: un producto con su cantidad.
///
/// Proyecto Integrador 2 — Desarrollo de Software II (IF616BIN) — UNSAAC
/// Equipo: Grupo 2 (Saire, Condori, Aranibar)
class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({
    required this.producto,
    this.cantidad = 1,
  });

  /// Subtotal de la línea (precio × cantidad).
  double get subtotal => producto.precioActual * cantidad;

  Map<String, dynamic> toJson() => {
        'producto': producto.toJson(),
        'cantidad': cantidad,
      };

  factory ItemCarrito.fromJson(Map<String, dynamic> json) => ItemCarrito(
        producto: Producto.fromJson(json['producto'] as Map<String, dynamic>),
        cantidad: json['cantidad'] as int,
      );
}
