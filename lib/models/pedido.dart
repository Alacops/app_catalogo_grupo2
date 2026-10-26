/// Estados posibles de un pedido según el flujo de negocio de Aroma Sagrado.
enum EstadoPedido {
  pendiente,
  confirmado,
  enCamino,
  entregado,
  cancelado;

  static EstadoPedido fromString(String valor) {
    final v = valor.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    switch (v) {
      case 'confirmado':
      case 'enpreparacion':
        return EstadoPedido.confirmado;
      case 'encamino':
        return EstadoPedido.enCamino;
      case 'entregado':
        return EstadoPedido.entregado;
      case 'cancelado':
        return EstadoPedido.cancelado;
      case 'pendiente':
      default:
        return EstadoPedido.pendiente;
    }
  }

  String get etiqueta {
    switch (this) {
      case EstadoPedido.pendiente:
        return 'Pendiente';
      case EstadoPedido.confirmado:
        return 'Confirmado';
      case EstadoPedido.enCamino:
        return 'En camino';
      case EstadoPedido.entregado:
        return 'Entregado';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }
}

/// Modelo de datos de Pedido para persistencia relacional en SQLite.
/// Cumple con la Sesión 7: Estado, Persistencia y Formularios (UNSAAC - Grupo 2).
class Pedido {
  final int? id;
  final String codigo;
  final DateTime fecha;
  final String clienteNombre;
  final String clienteTelefono;
  final String clienteCorreo;
  final String distrito;
  final String direccion;
  final String? referencia;
  final String metodoPago;
  final double total;
  final double subtotal;
  final double costoEnvio;
  final double descuento;
  final EstadoPedido estado;
  final String? notas;
  final double? latitud;
  final double? longitud;
  final String? fotoComprobantePath;
  final String resumenItems;
  final String modalidad;

  const Pedido({
    this.id,
    required this.codigo,
    required this.fecha,
    required this.clienteNombre,
    required this.clienteTelefono,
    required this.clienteCorreo,
    required this.distrito,
    required this.direccion,
    this.referencia,
    required this.metodoPago,
    required this.total,
    this.subtotal = 0.0,
    this.costoEnvio = 5.0,
    this.descuento = 0.0,
    this.estado = EstadoPedido.pendiente,
    this.notas,
    this.latitud,
    this.longitud,
    this.fotoComprobantePath,
    required this.resumenItems,
    this.modalidad = 'Delivery',
  });

  // Alias para retrocompatibilidad
  String get codigoOrden => codigo;
  String get itemsResumen => resumenItems;
  String? get rutaFoto => fotoComprobantePath;
  DateTime get creadoEn => fecha;

  /// Serialización a Map para inserción en SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'codigo': codigo,
      'fecha': fecha.toIso8601String(),
      'cliente_nombre': clienteNombre,
      'cliente_telefono': clienteTelefono,
      'cliente_correo': clienteCorreo,
      'distrito': distrito,
      'direccion': direccion,
      'referencia': referencia,
      'metodo_pago': metodoPago,
      'total': total,
      'subtotal': subtotal > 0 ? subtotal : (total > costoEnvio ? total - costoEnvio : total),
      'costo_envio': costoEnvio,
      'descuento': descuento,
      'estado': estado.name.toUpperCase(),
      'notas': notas,
      'latitud': latitud,
      'longitud': longitud,
      'foto_comprobante_path': fotoComprobantePath,
      'resumen_items': resumenItems,
    };
  }

  /// Deserialización desde Map proveniente de SQLite
  factory Pedido.fromMap(Map<String, dynamic> map) {
    final estadoRaw = (map['estado'] as String?) ?? 'PENDIENTE';
    final fechaRaw = map['fecha'] as String? ?? DateTime.now().toIso8601String();

    return Pedido(
      id: map['id'] as int?,
      codigo: (map['codigo'] as String?) ?? (map['codigo_orden'] as String?) ?? 'AS-000',
      fecha: DateTime.tryParse(fechaRaw) ?? DateTime.now(),
      clienteNombre: (map['cliente_nombre'] as String?) ?? '',
      clienteTelefono: (map['cliente_telefono'] as String?) ?? '',
      clienteCorreo: (map['cliente_correo'] as String?) ?? '',
      distrito: (map['distrito'] as String?) ?? 'Cusco Centro',
      direccion: (map['direccion'] as String?) ?? '',
      referencia: map['referencia'] as String?,
      metodoPago: (map['metodo_pago'] as String?) ?? 'Efectivo',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      costoEnvio: (map['costo_envio'] as num?)?.toDouble() ?? 5.0,
      descuento: (map['descuento'] as num?)?.toDouble() ?? 0.0,
      estado: EstadoPedido.fromString(estadoRaw),
      notas: map['notas'] as String?,
      latitud: (map['latitud'] as num?)?.toDouble(),
      longitud: (map['longitud'] as num?)?.toDouble(),
      fotoComprobantePath: (map['foto_comprobante_path'] as String?) ?? (map['ruta_foto'] as String?),
      resumenItems: (map['resumen_items'] as String?) ?? (map['items_resumen'] as String?) ?? '',
      modalidad: (map['modalidad'] as String?) ?? 'Delivery',
    );
  }

  /// Crea una copia del pedido con campos modificados
  Pedido copyWith({
    int? id,
    String? codigo,
    DateTime? fecha,
    String? clienteNombre,
    String? clienteTelefono,
    String? clienteCorreo,
    String? distrito,
    String? direccion,
    String? referencia,
    String? metodoPago,
    double? total,
    double? subtotal,
    double? costoEnvio,
    double? descuento,
    EstadoPedido? estado,
    String? notas,
    double? latitud,
    double? longitud,
    String? fotoComprobantePath,
    String? resumenItems,
    String? modalidad,
  }) {
    return Pedido(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      fecha: fecha ?? this.fecha,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      clienteTelefono: clienteTelefono ?? this.clienteTelefono,
      clienteCorreo: clienteCorreo ?? this.clienteCorreo,
      distrito: distrito ?? this.distrito,
      direccion: direccion ?? this.direccion,
      referencia: referencia ?? this.referencia,
      metodoPago: metodoPago ?? this.metodoPago,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      costoEnvio: costoEnvio ?? this.costoEnvio,
      descuento: descuento ?? this.descuento,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fotoComprobantePath: fotoComprobantePath ?? this.fotoComprobantePath,
      resumenItems: resumenItems ?? this.resumenItems,
      modalidad: modalidad ?? this.modalidad,
    );
  }
}
