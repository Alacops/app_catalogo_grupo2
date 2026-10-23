import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_catalogo_grupo2/main.dart';

void main() {
  setUp(() {
    // Mock de persistencia para las pruebas (favoritos/carrito vacíos).
    SharedPreferences.setMockInitialValues({});
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
