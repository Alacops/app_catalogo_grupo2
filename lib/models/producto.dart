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

  /// Serializa el producto a un mapa JSON (para persistir el carrito).
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria,
        'precioActual': precioActual,
        'precioAnterior': precioAnterior,
        'descuento': descuento,
        'puntuacion': puntuacion,
        'resenas': resenas,
        'descripcion': descripcion,
        'imagenUrl': imagenUrl,
        'origen': origen,
        'esNovedad': esNovedad,
        'esOferta': esOferta,
      };

  /// Reconstruye un producto desde un mapa JSON.
  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        categoria: json['categoria'] as String,
        precioActual: (json['precioActual'] as num).toDouble(),
        precioAnterior: (json['precioAnterior'] as num?)?.toDouble(),
        descuento: json['descuento'] as String?,
        puntuacion: (json['puntuacion'] as num).toDouble(),
        resenas: json['resenas'] as int,
        descripcion: json['descripcion'] as String,
        imagenUrl: json['imagenUrl'] as String,
        origen: json['origen'] as String,
        esNovedad: json['esNovedad'] as bool? ?? false,
        esOferta: json['esOferta'] as bool? ?? false,
      );
}
