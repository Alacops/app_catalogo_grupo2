import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_catalogo_grupo2/screens/catalogo_screen.dart';

/// Carpeta de salida de las capturas (relativa a la raíz del proyecto):
/// informe/capturas/
const String _carpetaSalida = 'informe/capturas';

/// Carga las fuentes reales de forma PORTABLE (sin rutas fijas de otra PC).
/// - MaterialIcons se resuelve desde el SDK de Flutter vía FLUTTER_ROOT.
/// - El texto usa Segoe UI (Windows) mapeado a la familia 'Roboto'.
Future<void> _cargarFuentesCompletas() async {
  // 1. Íconos Material desde el caché del SDK de Flutter (portable).
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    for (final nombre in const [
      'MaterialIcons-Regular.otf',
      'materialicons-regular.otf',
    ]) {
      final iconFile = File(
        '$flutterRoot/bin/cache/artifacts/material_fonts/$nombre',
      );
      if (iconFile.existsSync()) {
        final loader = FontLoader('MaterialIcons')
          ..addFont(Future.value(
              ByteData.sublistView(iconFile.readAsBytesSync())));
        await loader.load();
        break;
      }
    }
  }

  // 2. Fuente de texto (Segoe UI de Windows) mapeada a 'Roboto' y 'sans-serif'.
  final segoe = File(r'C:\Windows\Fonts\segoeui.ttf');
  if (segoe.existsSync()) {
    final bytes = segoe.readAsBytesSync();
    for (final familia in const ['Roboto', 'sans-serif']) {
      final loader = FontLoader(familia)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
  }
  final segoeBold = File(r'C:\Windows\Fonts\segoeuib.ttf');
  if (segoeBold.existsSync()) {
    final loader = FontLoader('Roboto')
      ..addFont(Future.value(
          ByteData.sublistView(segoeBold.readAsBytesSync())));
    await loader.load();
  }
}

/// Renderiza el catálogo en un ancho dado y guarda un PNG con toda la pantalla.
Future<void> _capturar(
  WidgetTester tester, {
  required Size physicalSize,
  required double devicePixelRatio,
  required String archivo,
}) async {
  tester.view.physicalSize = physicalSize;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GlobalKey key = GlobalKey();

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.android,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A1F2B),
          primary: const Color(0xFF7A1F2B),
          secondary: const Color(0xFFC9971F),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll(false),
          trackVisibility: WidgetStatePropertyAll(false),
        ),
      ),
      builder: (context, child) => ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: child!,
      ),
      home: RepaintBoundary(
        key: key,
        child: const CatalogoScreen(),
      ),
    ),
  );

  await tester.pump(const Duration(milliseconds: 600));

  await tester.runAsync(() async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final dir = Directory(_carpetaSalida);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('$_carpetaSalida/$archivo');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    // ignore: avoid_print
    print('Captura generada: ${file.absolute.path}');
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_cargarFuentesCompletas);

  // 1. Vista móvil: ancho lógico ~411 pt -> 2 columnas.
  testWidgets('Captura catálogo en vista móvil (2 columnas)',
      (WidgetTester tester) async {
    await _capturar(
      tester,
      physicalSize: const Size(1080, 4600),
      devicePixelRatio: 2.625,
      archivo: 'captura_movil_2col.png',
    );
  });

  // 2. Vista escritorio: ancho lógico ~960 pt -> 4 columnas.
  testWidgets('Captura catálogo en vista escritorio (4 columnas)',
      (WidgetTester tester) async {
    await _capturar(
      tester,
      physicalSize: const Size(1920, 2600),
      devicePixelRatio: 2.0,
      archivo: 'captura_escritorio_4col.png',
    );
  });
}
