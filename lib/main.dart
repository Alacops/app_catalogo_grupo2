import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/carrito_provider.dart';
import 'providers/favoritos_provider.dart';
import 'screens/main_screen.dart';

/// ============================================================================
/// PUNTO DE ENTRADA — PROYECTO INTEGRADOR: CATÁLOGO DE EMPRENDIMIENTO
/// Desarrollo de Software II (IF616BIN) — Semestre 2026-II — UNSAAC
///
/// Unidad II: Estado (provider + ChangeNotifier), persistencia de datos
/// (shared_preferences) y formularios (Form + validación).
///
/// Equipo de Trabajo: GRUPO 2
/// • Edmil Jampier Saire Bustamante (Código: 174449)
/// • Alain Armando Condori Contreras (Código: 021501)
/// • Axel Aranibar Rojas (Código: 220547)
/// ============================================================================

void main() {
  runApp(const AppCatalogoGrupo2());
}

class AppCatalogoGrupo2 extends StatelessWidget {
  const AppCatalogoGrupo2({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider inyecta el estado compartido (favoritos y carrito)
    // en todo el árbol de widgets.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: MaterialApp(
        title: 'Aroma Sagrado · Catálogo Cusco',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7A1F2B),
            primary: const Color(0xFF7A1F2B),
            secondary: const Color(0xFFC9971F),
            surface: const Color(0xFFF8FAFC),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF7A1F2B),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
