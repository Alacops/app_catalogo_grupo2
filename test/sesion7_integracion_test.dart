import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_catalogo_grupo2/data/database_helper.dart';
import 'package:app_catalogo_grupo2/data/pedido_repository.dart';
import 'package:app_catalogo_grupo2/models/pedido.dart';
import 'package:app_catalogo_grupo2/services/preferencias_service.dart';
import 'package:app_catalogo_grupo2/services/ubicacion_service.dart';
import 'package:app_catalogo_grupo2/utils/validadores.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PreferenciasService.inicializar();
  });

  group('1. Pruebas Unitarias de Validadores (Sesión 7 - 6 Criterios)', () {
    test('Validación de Nombre Obligatorio y Longitud', () {
      expect(Validadores.validarNombre(null), contains('obligatorio'));
      expect(Validadores.validarNombre(''), contains('obligatorio'));
      expect(Validadores.validarNombre('Ed'), contains('al menos 3'));
      expect(Validadores.validarNombre('Edmil Jampier Saire'), isNull);
    });

    test('Validación de Teléfono Móvil Peruano (9 dígitos, inicia con 9)', () {
      expect(Validadores.validarTelefono(null), contains('obligatorio'));
      expect(Validadores.validarTelefono('884123456'), contains('inicia con 9'));
      expect(Validadores.validarTelefono('98412345'), contains('inicia con 9'));
      expect(Validadores.validarTelefono('9841234567'), contains('inicia con 9'));
      expect(Validadores.validarTelefono('984123456'), isNull);
    });

    test('Validación de Correo Electrónico RFC', () {
      expect(Validadores.validarCorreo(null), contains('obligatorio'));
      expect(Validadores.validarCorreo('correo_invalido'), contains('válido'));
      expect(Validadores.validarCorreo('usuario@unsaac.edu.pe'), isNull);
    });

    test('Validación de Selección Obligatoria de Distrito', () {
      expect(Validadores.validarDistrito(null), contains('Seleccione un distrito'));
      expect(Validadores.validarDistrito(''), contains('Seleccione un distrito'));
      expect(Validadores.validarDistrito('Wanchaq'), isNull);
    });

    test('Validación de Dirección de Entrega', () {
      expect(Validadores.validarDireccion(null), contains('obligatorio'));
      expect(Validadores.validarDireccion('Av.'), contains('al menos 5'));
      expect(Validadores.validarDireccion('Av. De La Cultura 733'), isNull);
    });
  });

  group('2. Pruebas de Persistencia Relacional SQLite (PedidoRepository CRUD)', () {
    late PedidoRepository repo;

    setUp(() async {
      repo = PedidoRepository(dbHelper: DatabaseHelper.instancia);
      await DatabaseHelper.instancia.reiniciarBaseDeDatos();
    });

    test('Listar semillas demostrativas iniciales', () async {
      final pedidos = await repo.obtenerPedidos();
      expect(pedidos.length, greaterThanOrEqualTo(3));
      expect(pedidos.any((p) => p.codigo == 'AS-2026-001'), isTrue);
    });

    test('Crear e insertar nuevo pedido en SQLite', () async {
      final nuevo = Pedido(
        codigo: 'AS-TEST-999',
        fecha: DateTime.now(),
        clienteNombre: 'Test Integración UNSAAC',
        clienteTelefono: '984000111',
        clienteCorreo: 'test@unsaac.edu.pe',
        distrito: 'San Sebastián',
        direccion: 'Calle Los Andes 123',
        metodoPago: 'Yape / Plin',
        total: 55.0,
        subtotal: 50.0,
        costoEnvio: 5.0,
        descuento: 0.0,
        estado: EstadoPedido.pendiente,
        resumenItems: 'Café Geisha (x1)',
      );

      final id = await repo.crearPedido(nuevo);
      expect(id, greaterThan(0));

      final obtenido = await repo.obtenerPedidoPorId(id);
      expect(obtenido, isNotNull);
      expect(obtenido!.codigo, equals('AS-TEST-999'));
      expect(obtenido.clienteNombre, equals('Test Integración UNSAAC'));
    });

    test('Validación Asíncrona: existePedidoActivo previene duplicados', () async {
      // El cliente Alain Condori tiene un pedido AS-2026-002 en estado enCamino/confirmado
      final existe = await repo.existePedidoActivo(
        telefono: '984654321',
        correo: 'alain.condori@unsaac.edu.pe',
      );
      // O Axel con pedido pendiente
      final existeAxel = await repo.existePedidoActivo(
        telefono: '984998877',
        correo: 'axel.aranibar@unsaac.edu.pe',
      );
      expect(existe || existeAxel, isTrue);

      final noExiste = await repo.existePedidoActivo(
        telefono: '999999999',
        correo: 'nadie@dominio.com',
      );
      expect(noExiste, isFalse);
    });

    test('Actualizar estado de pedido en SQLite', () async {
      final pedidos = await repo.obtenerPedidos();
      final primerPedido = pedidos.first;

      await repo.actualizarEstado(primerPedido.id!, EstadoPedido.entregado);

      final actualizado = await repo.obtenerPedidoPorId(primerPedido.id!);
      expect(actualizado!.estado, equals(EstadoPedido.entregado));
    });

    test('Eliminar pedido de SQLite', () async {
      final nuevo = Pedido(
        codigo: 'AS-PARA-BORRAR',
        fecha: DateTime.now(),
        clienteNombre: 'A Borrar',
        clienteTelefono: '984777888',
        clienteCorreo: 'borrar@unsaac.edu.pe',
        distrito: 'Cusco Centro',
        direccion: 'Calle Triunfo 100',
        metodoPago: 'Efectivo',
        total: 30.0,
        resumenItems: 'Cacao Chuncho (x1)',
      );

      final id = await repo.crearPedido(nuevo);
      expect(id, greaterThan(0));

      final filasAfectadas = await repo.eliminarPedido(id);
      expect(filasAfectadas, equals(1));

      final recuperado = await repo.obtenerPedidoPorId(id);
      expect(recuperado, isNull);
    });
  });

  group('3. Pruebas de PreferenciasService (SharedPreferences)', () {
    test('Persistencia y alternancia de modo oscuro', () async {
      final prefs = PreferenciasService.instance;
      expect(prefs.modoOscuro, isFalse);

      await prefs.setModoOscuro(true);
      expect(prefs.modoOscuro, isTrue);

      await prefs.setModoOscuro(false);
      expect(prefs.modoOscuro, isFalse);
    });

    test('Persistencia de datos de contacto del cliente', () async {
      final prefs = PreferenciasService.instance;
      await prefs.guardarDatosContacto(
        nombre: 'Edmil Saire',
        telefono: '984123456',
        correo: 'edmil@unsaac.edu.pe',
      );

      expect(prefs.ultimoNombre, equals('Edmil Saire'));
      expect(prefs.ultimoTelefono, equals('984123456'));
      expect(prefs.ultimoCorreo, equals('edmil@unsaac.edu.pe'));
    });
  });

  group('4. Pruebas de UbicacionService (Sensores y Geolocalización Cusco)', () {
    test('Cálculo de distancia a la Plaza de Armas del Cusco', () {
      // Coordenadas idénticas a la Plaza de Armas
      final distCero = UbicacionService.calcularDistanciaPlazaDeArmas(
        UbicacionService.latPlazaArmasCusco,
        UbicacionService.lngPlazaArmasCusco,
      );
      expect(distCero, closeTo(0.0, 0.01));

      // San Jerónimo (a aprox 9-11 km)
      final distSanJeronimo = UbicacionService.calcularDistanciaPlazaDeArmas(
        -13.5500,
        -71.8800,
      );
      expect(distSanJeronimo, greaterThan(5.0));
    });
  });
}
