import 'package:flutter/material.dart';
import 'screens/catalogo_screen.dart';

/// ============================================================================
/// PUNTO DE ENTRADA — PROYECTO INTEGRADOR 2: CATÁLOGO DE EMPRENDIMIENTO
/// Desarrollo de Software II (IF616BIN) — Semestre 2026-II — UNSAAC
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
    return MaterialApp(
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
      home: const CatalogoScreen(),
    );
  }
}
