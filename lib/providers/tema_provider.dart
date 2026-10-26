import 'package:flutter/material.dart';
import '../services/preferencias_service.dart';

/// Proveedor de estado para el tema visual (Claro / Oscuro) de la aplicación.
/// Persiste la elección mediante SharedPreferences a través de PreferenciasService.
class TemaProvider extends ChangeNotifier {
  late bool _modoOscuro;

  TemaProvider() {
    _modoOscuro = PreferenciasService.instance.modoOscuro;
  }

  bool get modoOscuro => _modoOscuro;
  ThemeMode get themeMode => _modoOscuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> alternarTema(bool valor) async {
    if (_modoOscuro == valor) return;
    _modoOscuro = valor;
    await PreferenciasService.instance.setModoOscuro(valor);
    notifyListeners();
  }
}
