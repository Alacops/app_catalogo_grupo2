import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_catalogo_grupo2/data/catalogo_data.dart';
import 'package:app_catalogo_grupo2/providers/carrito_provider.dart';
import 'package:app_catalogo_grupo2/providers/favoritos_provider.dart';
import 'package:app_catalogo_grupo2/screens/carrito_screen.dart';
import 'package:app_catalogo_grupo2/screens/catalogo_screen.dart';
import 'package:app_catalogo_grupo2/screens/checkout_screen.dart';
import 'package:app_catalogo_grupo2/screens/favoritos_screen.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_catalogo_grupo2/services/preferencias_service.dart';
import 'package:app_catalogo_grupo2/providers/tema_provider.dart';

import 'support/fake_network_images.dart';

/// Generador de capturas de evidencia para la Unidad II (estado, persistencia,
/// formularios). Pre-carga favoritos y carrito vía SharedPreferences mock y
/// sirve las fotos reales de los productos vía [FakeImageHttpOverrides].
const String _carpetaSalida = 'informe/capturas';

Future<void> _cargarFuentes() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    for (final nombre in const ['MaterialIcons-Regular.otf', 'materialicons-regular.otf']) {
      final f = File('$flutterRoot/bin/cache/artifacts/material_fonts/$nombre');
      if (f.existsSync()) {
        await (FontLoader('MaterialIcons')
              ..addFont(Future.value(ByteData.sublistView(f.readAsBytesSync()))))
            .load();
        break;
      }
    }
  }
  final segoe = File(r'C:\Windows\Fonts\segoeui.ttf');
  if (segoe.existsSync()) {
    final bytes = segoe.readAsBytesSync();
    for (final fam in const ['Roboto', 'sans-serif']) {
      await (FontLoader(fam)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    }
  }
  final segoeBold = File(r'C:\Windows\Fonts\segoeuib.ttf');
  if (segoeBold.existsSync()) {
    await (FontLoader('Roboto')
          ..addFont(Future.value(ByteData.sublistView(segoeBold.readAsBytesSync()))))
        .load();
  }
}

ThemeData _tema() => ThemeData(
      platform: TargetPlatform.android,
      fontFamily: 'Roboto',
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7A1F2B),
        primary: const Color(0xFF7A1F2B),
        secondary: const Color(0xFFC9971F),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );

/// Pre-carga el carrito (p1 x2, p4 x1) y favoritos (p3, p7) en el mock.
void _sembrarEstado() {
  final carrito = [
    {'producto': CatalogoData.productos[0].toJson(), 'cantidad': 2},
    {'producto': CatalogoData.productos[3].toJson(), 'cantidad': 1},
  ];
  SharedPreferences.setMockInitialValues({
    'favoritos_ids': <String>[
      CatalogoData.productos[2].id,
      CatalogoData.productos[6].id,
    ],
    'carrito_items': jsonEncode(carrito),
  });
}

Future<void> _capturar(
  WidgetTester tester, {
  required Widget pantalla,
  required Size physicalSize,
  required double dpr,
  required String archivo,
  Future<void> Function(WidgetTester)? interaccion,
}) async {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = dpr;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final key = GlobalKey();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _tema(),
        builder: (context, child) => ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
          child: child!,
        ),
        home: RepaintBoundary(key: key, child: pantalla),
      ),
    ),
  );

  // Deja que los providers carguen el estado sembrado.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));

  if (interaccion != null) await interaccion(tester);

  await tester.pump(const Duration(milliseconds: 300));

  // Dentro de runAsync la red simulada y la decodificación de las imágenes sí
  // se ejecutan; bombeamos varias veces para que los frames se reconstruyan ya
  // con las fotos cargadas antes de capturar.
  await tester.runAsync(() async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
      await Future<void>.delayed(const Duration(milliseconds: 60));
    }
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final dir = Directory(_carpetaSalida);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('$_carpetaSalida/$archivo');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    // ignore: avoid_print
    print('Captura: ${file.absolute.path}');
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await PreferenciasService.inicializar();
    HttpOverrides.global = FakeImageHttpOverrides();
    await _cargarFuentes();
  });

  testWidgets('u2 catalogo', (tester) async {
    _sembrarEstado();
    await _capturar(tester,
        pantalla: const CatalogoScreen(),
        physicalSize: const Size(1000, 4200),
        dpr: 2.4,
        archivo: 'u2_catalogo.png');
  });

  testWidgets('u2 favoritos', (tester) async {
    _sembrarEstado();
    await _capturar(tester,
        pantalla: const FavoritosScreen(),
        physicalSize: const Size(1000, 1700),
        dpr: 2.4,
        archivo: 'u2_favoritos.png');
  });

  testWidgets('u2 carrito', (tester) async {
    _sembrarEstado();
    await _capturar(tester,
        pantalla: const CarritoScreen(),
        physicalSize: const Size(1000, 1500),
        dpr: 2.4,
        archivo: 'u2_carrito.png');
  });

  testWidgets('u2 checkout con validacion', (tester) async {
    _sembrarEstado();
    await _capturar(tester,
        pantalla: const CheckoutScreen(),
        physicalSize: const Size(1000, 2500),
        dpr: 2.4,
        archivo: 'u2_checkout.png',
        interaccion: (t) async {
      // Toca "Confirmar Pedido (Guardar en SQLite)" con campos vacíos para mostrar las validaciones.
      final boton = find.text('Confirmar Pedido (Guardar en SQLite)');
      if (boton.evaluate().isNotEmpty) {
        await t.ensureVisible(boton);
        await t.pump();
        await t.tap(boton);
        await t.pump();
      }
    });
  });
}
