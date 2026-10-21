import 'package:flutter_test/flutter_test.dart';
import 'package:app_catalogo_grupo2/main.dart';
import 'package:app_catalogo_grupo2/screens/catalogo_screen.dart';

void main() {
  testWidgets('Test de inicialización de la App del Catálogo Grupo 2', (WidgetTester tester) async {
    await tester.pumpWidget(const AppCatalogoGrupo2());
    expect(find.byType(CatalogoScreen), findsOneWidget);
  });
}
