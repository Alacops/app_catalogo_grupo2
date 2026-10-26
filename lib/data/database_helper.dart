import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/pedido.dart';

/// Gestor singleton de la base de datos SQLite para la aplicación Aroma Sagrado.
/// Implementa persistencia local conforme a la Sesión 7 de Desarrollo de Software 2 (UNSAAC).
class DatabaseHelper {
  static const String _nombreBd = 'pedidos_aroma_sagrado.db';
  static const int _versionBd = 1;
  static const String tablaPedidos = 'pedidos';

  // Singleton
  DatabaseHelper._();
  static final DatabaseHelper instancia = DatabaseHelper._();
  static DatabaseHelper get instance => instancia;

  Database? _baseDeDatos;

  Future<Database> get bd async {
    if (_baseDeDatos != null) return _baseDeDatos!;
    _baseDeDatos = await _inicializarBd();
    return _baseDeDatos!;
  }

  Future<Database> _inicializarBd() async {
    // Soporte para pruebas unitarias y entornos de escritorio FFI (Windows / Linux / macOS)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String rutaBd;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      try {
        final docDir = await getApplicationDocumentsDirectory();
        rutaBd = p.join(docDir.path, 'AromaSagrado', _nombreBd);
      } catch (_) {
        rutaBd = p.join(Directory.current.path, '.dart_tool', 'sqflite', _nombreBd);
      }
      final dir = Directory(p.dirname(rutaBd));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      final rutaBases = await getDatabasesPath();
      rutaBd = p.join(rutaBases, _nombreBd);
    }

    return await openDatabase(
      rutaBd,
      version: _versionBd,
      onCreate: _crearEsquema,
      onUpgrade: _actualizarEsquema,
    );
  }

  Future<void> _crearEsquema(Database db, int version) async {
    // 1. Tabla de pedidos con todos los campos requeridos por la Sesión 7
    await db.execute('''
      CREATE TABLE $tablaPedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        fecha TEXT NOT NULL,
        cliente_nombre TEXT NOT NULL,
        cliente_telefono TEXT NOT NULL,
        cliente_correo TEXT NOT NULL,
        distrito TEXT NOT NULL,
        direccion TEXT NOT NULL,
        referencia TEXT,
        metodo_pago TEXT NOT NULL,
        total REAL NOT NULL,
        subtotal REAL NOT NULL,
        costo_envio REAL NOT NULL,
        descuento REAL NOT NULL,
        estado TEXT NOT NULL DEFAULT 'PENDIENTE',
        notas TEXT,
        latitud REAL,
        longitud REAL,
        foto_comprobante_path TEXT,
        resumen_items TEXT NOT NULL
      )
    ''');

    // Índices para optimizar consultas por código, fecha y estado
    await db.execute(
      'CREATE INDEX idx_pedidos_codigo ON $tablaPedidos(codigo);',
    );
    await db.execute(
      'CREATE INDEX idx_pedidos_estado ON $tablaPedidos(estado);',
    );
    await db.execute(
      'CREATE INDEX idx_pedidos_fecha ON $tablaPedidos(fecha DESC);',
    );

    // Semillas demostrativas iniciales
    await _insertarSemillas(db);
  }

  Future<void> _insertarSemillas(Database db) async {
    final semillas = [
      Pedido(
        codigo: 'AS-2026-001',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        clienteNombre: 'Edmil Jampier Saire',
        clienteTelefono: '984123456',
        clienteCorreo: 'edmil.saire@unsaac.edu.pe',
        distrito: 'Cusco Centro',
        direccion: 'Calle Santa Clara 450',
        referencia: 'Frente al Mercado Central de San Pedro',
        metodoPago: 'Yape / Plin',
        total: 85.00,
        subtotal: 80.00,
        costoEnvio: 5.00,
        descuento: 0.00,
        estado: EstadoPedido.entregado,
        notas: 'Tueste medio para espresso',
        latitud: -13.5186,
        longitud: -71.9822,
        resumenItems: 'Café Geisha Especial (x2), Taza Cerámica (x1)',
      ),
      Pedido(
        codigo: 'AS-2026-002',
        fecha: DateTime.now().subtract(const Duration(hours: 18)),
        clienteNombre: 'Alain Armando Condori',
        clienteTelefono: '984654321',
        clienteCorreo: 'alain.condori@unsaac.edu.pe',
        distrito: 'Wanchaq',
        direccion: 'Av. Infancia 210',
        referencia: 'Cerca a la estación del tren',
        metodoPago: 'Transferencia BCP',
        total: 120.00,
        subtotal: 115.00,
        costoEnvio: 5.00,
        descuento: 0.00,
        estado: EstadoPedido.enCamino,
        notas: 'Molienda fina para prensa francesa',
        latitud: -13.5245,
        longitud: -71.9680,
        resumenItems: 'Café Bourbon Quillabamba (x3)',
      ),
      Pedido(
        codigo: 'AS-2026-003',
        fecha: DateTime.now().subtract(const Duration(hours: 3)),
        clienteNombre: 'Axel Aranibar Rojas',
        clienteTelefono: '984998877',
        clienteCorreo: 'axel.aranibar@unsaac.edu.pe',
        distrito: 'San Sebastián',
        direccion: 'Urb. Santa Rosa Mz. B Lt. 4',
        referencia: 'A espaldas de la Vía Expresa',
        metodoPago: 'Efectivo contraentrega',
        total: 45.00,
        subtotal: 40.00,
        costoEnvio: 5.00,
        descuento: 0.00,
        estado: EstadoPedido.pendiente,
        notas: 'Entregar a partir de las 5:00 PM',
        latitud: -13.5320,
        longitud: -71.9350,
        resumenItems: 'Café Typica Valle Sagrado (x1)',
      ),
    ];

    for (final pedido in semillas) {
      await db.insert(
        tablaPedidos,
        pedido.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _actualizarEsquema(
    Database db,
    int versionAnterior,
    int versionNueva,
  ) async {
    // Manejo de migraciones para futuras versiones de base de datos
  }

  /// Limpia y reinicializa la tabla de pedidos con los datos semilla
  Future<void> reiniciarBaseDeDatos() async {
    final db = await bd;
    await db.delete(tablaPedidos);
    await _insertarSemillas(db);
  }

  /// Cierra la base de datos
  Future<void> cerrar() async {
    if (_baseDeDatos != null && _baseDeDatos!.isOpen) {
      await _baseDeDatos!.close();
      _baseDeDatos = null;
    }
  }
}
