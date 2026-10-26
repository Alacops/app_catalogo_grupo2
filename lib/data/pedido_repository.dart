import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../models/pedido.dart';
import 'database_helper.dart';

/// Repositorio de Pedidos que abstrae todas las operaciones CRUD contra SQLite.
/// Cumple con la regla arquitectónica de la Sesión 7: Cero sentencias SQL en la capa de interfaz.
class PedidoRepository {
  final DatabaseHelper _dbHelper;

  PedidoRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instancia;

  /// Inserta un nuevo pedido en la base de datos local SQLite.
  /// Retorna el id asignado autoincrementalmente.
  Future<int> crearPedido(Pedido pedido) async {
    final db = await _dbHelper.bd;
    return await db.insert(
      DatabaseHelper.tablaPedidos,
      pedido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Lista los pedidos registrados con soporte para filtros por estado,
  /// búsqueda por texto (código o cliente) y ordenamiento parametrizado.
  Future<List<Pedido>> obtenerPedidos({
    String? filtroEstado,
    String? busqueda,
    String ordenarPor = 'fecha DESC',
  }) async {
    final db = await _dbHelper.bd;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (filtroEstado != null &&
        filtroEstado.isNotEmpty &&
        filtroEstado.toUpperCase() != 'TODOS') {
      whereClauses.add('estado = ?');
      whereArgs.add(filtroEstado.toUpperCase());
    }

    if (busqueda != null && busqueda.trim().isNotEmpty) {
      whereClauses.add(
        '(codigo LIKE ? OR cliente_nombre LIKE ? OR cliente_telefono LIKE ?)',
      );
      final query = '%${busqueda.trim()}%';
      whereArgs.addAll([query, query, query]);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final registros = await db.query(
      DatabaseHelper.tablaPedidos,
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: ordenarPor,
    );

    return registros.map((map) => Pedido.fromMap(map)).toList();
  }

  /// Obtiene un pedido por su identificador primario.
  Future<Pedido?> obtenerPedidoPorId(int id) async {
    final db = await _dbHelper.bd;
    final registros = await db.query(
      DatabaseHelper.tablaPedidos,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (registros.isEmpty) return null;
    return Pedido.fromMap(registros.first);
  }

  /// Obtiene un pedido por su código único de seguimiento.
  Future<Pedido?> obtenerPedidoPorCodigo(String codigo) async {
    final db = await _dbHelper.bd;
    final registros = await db.query(
      DatabaseHelper.tablaPedidos,
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );

    if (registros.isEmpty) return null;
    return Pedido.fromMap(registros.first);
  }

  /// Actualiza los datos de un pedido existente.
  Future<int> actualizarPedido(Pedido pedido) async {
    if (pedido.id == null) {
      throw ArgumentError('El pedido debe tener un ID para ser actualizado');
    }
    final db = await _dbHelper.bd;
    return await db.update(
      DatabaseHelper.tablaPedidos,
      pedido.toMap(),
      where: 'id = ?',
      whereArgs: [pedido.id],
    );
  }

  /// Actualiza el estado de un pedido (PENDIENTE, CONFIRMADO, EN_CAMINO, ENTREGADO, CANCELADO).
  Future<int> actualizarEstado(int id, EstadoPedido nuevoEstado) async {
    final db = await _dbHelper.bd;
    return await db.update(
      DatabaseHelper.tablaPedidos,
      {'estado': nuevoEstado.name.toUpperCase()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Elimina un pedido y remueve el archivo físico de foto comprobante si existe.
  Future<int> eliminarPedido(int id) async {
    final pedido = await obtenerPedidoPorId(id);
    if (pedido?.fotoComprobantePath != null) {
      try {
        final archivoFoto = File(pedido!.fotoComprobantePath!);
        if (await archivoFoto.exists()) {
          await archivoFoto.delete();
        }
      } catch (_) {
        // Tolerancia a fallos si el archivo ya fue removido
      }
    }

    final db = await _dbHelper.bd;
    return await db.delete(
      DatabaseHelper.tablaPedidos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Validación asíncrona requerida por la Sesión 7:
  /// Verifica si el cliente ya tiene un pedido en curso ('PENDIENTE' o 'CONFIRMADO')
  /// con el mismo teléfono o correo para advertir y evitar duplicados accidentales.
  Future<bool> existePedidoActivo({
    required String telefono,
    required String correo,
  }) async {
    final db = await _dbHelper.bd;
    final resultado = await db.rawQuery('''
      SELECT COUNT(*) as total FROM ${DatabaseHelper.tablaPedidos}
      WHERE (cliente_telefono = ? OR cliente_correo = ?)
      AND estado IN ('PENDIENTE', 'CONFIRMADO')
    ''', [telefono.trim(), correo.trim().toLowerCase()]);

    final cantidad = Sqflite.firstIntValue(resultado) ?? 0;
    return cantidad > 0;
  }

  /// Devuelve un mapa con el conteo de pedidos agrupados por estado
  Future<Map<String, int>> contarPorEstado() async {
    final db = await _dbHelper.bd;
    final resultado = await db.rawQuery('''
      SELECT estado, COUNT(*) as cantidad
      FROM ${DatabaseHelper.tablaPedidos}
      GROUP BY estado
    ''');

    final mapa = <String, int>{};
    for (final fila in resultado) {
      final estado = fila['estado'] as String;
      final cantidad = fila['cantidad'] as int;
      mapa[estado] = cantidad;
    }
    return mapa;
  }
}
