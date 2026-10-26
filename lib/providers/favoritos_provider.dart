import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalogo_data.dart';
import '../models/producto.dart';

/// Estado compartido de los productos marcados como favoritos.
///
/// Demuestra manejo de estado con [ChangeNotifier] (provider) y
/// persistencia local con [SharedPreferences]. Los ids se guardan como
/// una lista de cadenas y se rehidratan desde el catálogo.
class FavoritosProvider extends ChangeNotifier {
  static const String _clave = 'favoritos_ids';

  final Set<String> _ids = <String>{};

  FavoritosProvider() {
    _cargar();
  }

  /// Cantidad de favoritos (para el badge).
  int get cantidad => _ids.length;

  /// ¿El producto está marcado como favorito?
  bool esFavorito(String id) => _ids.contains(id);

  /// Lista de productos favoritos, reconstruida desde el catálogo.
  List<Producto> get productos => _ids
      .map(CatalogoData.buscarPorId)
      .whereType<Producto>()
      .toList();

  /// Agrega o quita de favoritos y persiste el cambio.
  void alternar(String id) {
    if (!_ids.remove(id)) {
      _ids.add(id);
    }
    notifyListeners();
    _guardar();
  }

  void alternarFavorito(Producto producto) => alternar(producto.id);

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? const [];
    _ids
      ..clear()
      ..addAll(lista);
    notifyListeners();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_clave, _ids.toList());
  }
}
