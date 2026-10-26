// ============================================================================
// CATÁLOGO DE VALIDADORES REUTILIZABLES — SESIÓN 7 (Capítulo 5.3)
// Centraliza las validaciones para garantizar consistencia y mensajes
// explicativos claros en toda la aplicación según la rúbrica oficial UNSAAC.
// ============================================================================

class Validadores {
  /// Valida que el texto no sea nulo ni esté vacío tras recortar espacios.
  static String? requerido(String? v, {String campo = 'Este campo'}) {
    if (v == null || v.trim().isEmpty) {
      return '$campo es obligatorio.';
    }
    return null;
  }

  /// Valida longitud mínima y máxima del campo de texto.
  static String? longitud(
    String? v, {
    int min = 3,
    int max = 120,
    String campo = 'Este campo',
  }) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$campo es obligatorio.';
    if (t.length < min) {
      return '$campo debe tener al menos $min caracteres.';
    }
    if (t.length > max) {
      return '$campo no debe exceder los $max caracteres.';
    }
    return null;
  }

  /// Valida formato de correo electrónico estándar mediante expresión regular.
  static String? correo(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'El correo electrónico es obligatorio.';
    final re = RegExp(r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]{2,}$');
    if (!re.hasMatch(t)) {
      return 'Ingrese un correo válido (ej. usuario@dominio.com).';
    }
    return null;
  }

  /// Valida formato de número de celular en Perú (9 dígitos iniciando con 9).
  static String? telefonoPeru(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'El teléfono celular es obligatorio.';
    if (!RegExp(r'^9\d{8}$').hasMatch(t)) {
      return 'Ingrese un celular peruano de 9 dígitos (inicia con 9).';
    }
    return null;
  }

  /// Valida valor numérico dentro de un rango opcional [min, max].
  static String? numero(
    String? v, {
    double? min,
    double? max,
    String campo = 'Este valor',
  }) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$campo es obligatorio.';
    final n = double.tryParse(t);
    if (n == null) return 'Ingrese un valor numérico válido.';
    if (min != null && n < min) return '$campo mínimo permitido es $min.';
    if (max != null && n > max) return '$campo máximo permitido es $max.';
    return null;
  }

  /// Valida selección obligatoria de listas desplegables.
  static String? seleccionObligatoria(dynamic v, {String mensaje = 'Seleccione una opción.'}) {
    if (v == null) return mensaje;
    if (v is String && v.trim().isEmpty) return mensaje;
    return null;
  }

  // --- Métodos de validación directa para formularios de compra ---
  static String? validarNombre(String? v) => longitud(v, min: 3, max: 80, campo: 'El nombre completo');
  static String? validarTelefono(String? v) => telefonoPeru(v);
  static String? validarCorreo(String? v) => correo(v);
  static String? validarDistrito(String? v) => seleccionObligatoria(v, mensaje: 'Seleccione un distrito de entrega');
  static String? validarDireccion(String? v) => longitud(v, min: 5, max: 150, campo: 'La dirección exacta');
}
