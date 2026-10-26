import 'package:shared_preferences/shared_preferences.dart';

/// Servicio singleton para la persistencia de preferencias de usuario con SharedPreferences.
/// Requerido en la Sesión 7 para persistir tema, filtros y datos de contacto.
class PreferenciasService {
  static const String _keyModoOscuro = 'pref_modo_oscuro';
  static const String _keyOrdenCatalogo = 'pref_orden_catalogo';
  static const String _keyUltimaCategoria = 'pref_ultima_categoria';
  static const String _keyDistritoPredeterminado = 'pref_distrito_predeterminado';
  static const String _keyUltimoNombre = 'pref_ultimo_nombre';
  static const String _keyUltimoTelefono = 'pref_ultimo_telefono';
  static const String _keyUltimoCorreo = 'pref_ultimo_correo';
  static const String _keyRecordarContacto = 'pref_recordar_contacto';
  static const String _keyNotificaciones = 'pref_notificaciones';

  static PreferenciasService? _instancia;
  late SharedPreferences _prefs;

  PreferenciasService._();

  static PreferenciasService get instance {
    if (_instancia == null) {
      throw StateError(
        'PreferenciasService debe ser inicializado con inicializar() antes de usarse.',
      );
    }
    return _instancia!;
  }

  static Future<PreferenciasService> inicializar() async {
    if (_instancia == null) {
      final servicio = PreferenciasService._();
      servicio._prefs = await SharedPreferences.getInstance();
      _instancia = servicio;
    }
    return _instancia!;
  }

  // --- Modo Oscuro ---
  bool get modoOscuro => _prefs.getBool(_keyModoOscuro) ?? false;
  Future<bool> setModoOscuro(bool valor) => _prefs.setBool(_keyModoOscuro, valor);

  // --- Orden del Catálogo ---
  String get ordenCatalogo => _prefs.getString(_keyOrdenCatalogo) ?? 'destacados';
  Future<bool> setOrdenCatalogo(String valor) =>
      _prefs.setString(_keyOrdenCatalogo, valor);

  // --- Última Categoría Seleccionada ---
  String get ultimaCategoria => _prefs.getString(_keyUltimaCategoria) ?? 'Todos';
  Future<bool> setUltimaCategoria(String valor) =>
      _prefs.setString(_keyUltimaCategoria, valor);

  // --- Distrito Predeterminado ---
  String get distritoPredeterminado =>
      _prefs.getString(_keyDistritoPredeterminado) ?? 'Cusco Centro';
  Future<bool> setDistritoPredeterminado(String valor) =>
      _prefs.setString(_keyDistritoPredeterminado, valor);

  // --- Datos de Contacto Recordados ---
  bool get recordarContacto => _prefs.getBool(_keyRecordarContacto) ?? true;
  Future<bool> setRecordarContacto(bool valor) =>
      _prefs.setBool(_keyRecordarContacto, valor);

  String get ultimoNombre => _prefs.getString(_keyUltimoNombre) ?? '';
  Future<bool> setUltimoNombre(String valor) =>
      _prefs.setString(_keyUltimoNombre, valor);

  String get ultimoTelefono => _prefs.getString(_keyUltimoTelefono) ?? '';
  Future<bool> setUltimoTelefono(String valor) =>
      _prefs.setString(_keyUltimoTelefono, valor);

  String get ultimoCorreo => _prefs.getString(_keyUltimoCorreo) ?? '';
  Future<bool> setUltimoCorreo(String valor) =>
      _prefs.setString(_keyUltimoCorreo, valor);

  // --- Notificaciones ---
  bool get notificaciones => _prefs.getBool(_keyNotificaciones) ?? true;
  Future<bool> setNotificaciones(bool valor) =>
      _prefs.setBool(_keyNotificaciones, valor);

  // Guardar datos completos de contacto
  Future<void> guardarDatosContacto({
    required String nombre,
    required String telefono,
    required String correo,
  }) async {
    if (recordarContacto) {
      await setUltimoNombre(nombre);
      await setUltimoTelefono(telefono);
      await setUltimoCorreo(correo);
    }
  }

  // Limpiar todas las preferencias guardadas
  Future<bool> restablecerPreferencias() async {
    return await _prefs.clear();
  }
}
