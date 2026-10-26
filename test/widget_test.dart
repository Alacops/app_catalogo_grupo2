import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_catalogo_grupo2/main.dart';
import 'package:app_catalogo_grupo2/services/preferencias_service.dart';

void main() {
  setUp(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await PreferenciasService.inicializar();
  });

  testWidgets('La app arranca y muestra el catálogo con navegación',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AppCatalogoGrupo2());
    await tester.pump(const Duration(milliseconds: 200));

    // Título del catálogo en la AppBar.
    expect(find.text('Aroma Sagrado · Cusco'), findsOneWidget);
    // Pestañas de la barra inferior.
    expect(find.text('Catálogo'), findsWidgets);
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Carrito'), findsOneWidget);
  });
}
