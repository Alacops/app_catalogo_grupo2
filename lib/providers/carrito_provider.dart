import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item_carrito.dart';
import '../models/producto.dart';

/// Estado compartido del carrito de compras.
///
/// Maneja las líneas de carrito (producto + cantidad), expone totales y
/// persiste todo en [SharedPreferences] como JSON.
class CarritoProvider extends ChangeNotifier {
  static const String _clave = 'carrito_items';

  /// Líneas del carrito indexadas por id de producto.
  final Map<String, ItemCarrito> _items = {};

  CarritoProvider() {
    _cargar();
  }

  List<ItemCarrito> get lineas => _items.values.toList();
  bool get vacio => _items.isEmpty;

  /// Cantidad total de unidades (para el badge).
  int get cantidadTotal =>
      _items.values.fold(0, (suma, item) => suma + item.cantidad);

  /// Importe total del carrito.
  double get total =>
      _items.values.fold(0.0, (suma, item) => suma + item.subtotal);

  bool estaEnCarrito(String id) => _items.containsKey(id);
  int cantidadDe(String id) => _items[id]?.cantidad ?? 0;

  /// Agrega un producto (o incrementa si ya estaba).
  void agregar(Producto producto) {
    final existente = _items[producto.id];
    if (existente != null) {
      existente.cantidad++;
    } else {
      _items[producto.id] = ItemCarrito(producto: producto);
    }
    notifyListeners();
    _guardar();
  }

  void incrementar(String id) {
    final item = _items[id];
    if (item == null) return;
    item.cantidad++;
    notifyListeners();
    _guardar();
  }

  /// Disminuye la cantidad; si llega a 0, elimina la línea.
  void decrementar(String id) {
    final item = _items[id];
    if (item == null) return;
    item.cantidad--;
    if (item.cantidad <= 0) _items.remove(id);
    notifyListeners();
    _guardar();
  }

  void quitar(String id) {
    _items.remove(id);
    notifyListeners();
    _guardar();
  }

  void vaciar() {
    _items.clear();
    notifyListeners();
    _guardar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_clave);
    if (raw == null) return;
    final List<dynamic> lista = jsonDecode(raw);
    _items.clear();
    for (final e in lista) {
      final item = ItemCarrito.fromJson(e as Map<String, dynamic>);
      _items[item.producto.id] = item;
    }
    notifyListeners();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        jsonEncode(_items.values.map((item) => item.toJson()).toList());
    await prefs.setString(_clave, data);
  }
}
