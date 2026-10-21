/// Modelo de Producto para el Catálogo de Emprendimiento Local Cusqueño.
///
/// Proyecto Integrador 2 — Desarrollo de Software II (IF616BIN) — UNSAAC
/// Equipo: Grupo 2 (Saire, Condori, Aranibar)
class Producto {
  final String id;
  final String nombre;
  final String categoria;
  final double precioActual;
  final double? precioAnterior;
  final String? descuento;
  final double puntuacion;
  final int resenas;
  final String descripcion;
  final String imagenUrl;
  final String origen;
  final bool esNovedad;
  final bool esOferta;

  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precioActual,
    this.precioAnterior,
    this.descuento,
    required this.puntuacion,
    required this.resenas,
    required this.descripcion,
    required this.imagenUrl,
    required this.origen,
    this.esNovedad = false,
    this.esOferta = false,
  });

  bool get tieneDescuento => precioAnterior != null && descuento != null;
}
