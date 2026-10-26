import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/database_helper.dart';
import 'models/pedido.dart';
import 'models/producto.dart';
import 'providers/carrito_provider.dart';
import 'providers/favoritos_provider.dart';
import 'providers/tema_provider.dart';
import 'screens/ajustes_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/detalle_pedido_screen.dart';
import 'screens/detalle_producto_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/historial_pedidos_screen.dart';
import 'screens/main_screen.dart';
import 'screens/ofertas_screen.dart';
import 'services/preferencias_service.dart';

/// ============================================================================
/// PUNTO DE ENTRADA — PROYECTO INTEGRADOR: AROMA SAGRADO · CUSCO
/// Desarrollo de Software II (IF616BIN) — Semestre 2026-II — UNSAAC
///
/// Sesión 07: Estados, Persistencia SQLite, Formularios y Sensores.
///
/// Equipo de Trabajo: GRUPO 2
/// • Edmil Jampier Saire Bustamante (Código: 210491)
/// • Alain Armando Condori Contreras (Código: 211339)
/// • Axel Aranibar Rojas (Código: 210935)
/// Docente: Mtro. Ing. Yover Collantes Valer
/// ============================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de FFI para plataformas de escritorio (Windows, Linux, macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicialización de preferencias compartidas (SharedPreferences)
  await PreferenciasService.inicializar();

  // Inicialización y verificación de esquema SQLite
  await DatabaseHelper.instancia.bd;

  runApp(const AppCatalogoGrupo2());
}

class AppCatalogoGrupo2 extends StatelessWidget {
  const AppCatalogoGrupo2({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider inyecta los proveedores reactivos a nivel de aplicación
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemaProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: Consumer<TemaProvider>(
        builder: (context, temaProvider, child) {
          return MaterialApp(
            title: 'Aroma Sagrado · Café Cusqueño',
            debugShowCheckedModeBanner: false,
            themeMode: temaProvider.themeMode,

            // Tema Claro Artesanal Cusqueño
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF7A1F2B),
                primary: const Color(0xFF7A1F2B),
                secondary: const Color(0xFFC9971F),
                surface: const Color(0xFFF8FAFC),
                brightness: Brightness.light,
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

            // Tema Oscuro Imperial
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFB71C1C),
                primary: const Color(0xFFE57373),
                secondary: const Color(0xFFFFD54F),
                surface: const Color(0xFF1E1E1E),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade800),
                ),
              ),
            ),

            // Rutas centrales nombradas (Sesión 7: Navegación avanzada)
            initialRoute: '/',
            routes: {
              '/': (context) => const MainScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/pedidos': (context) => const HistorialPedidosScreen(),
              '/ajustes': (context) => const AjustesScreen(),
              '/ofertas': (context) => const OfertasScreen(),
              '/favoritos': (context) => const FavoritosScreen(),
              '/carrito': (context) => const CarritoScreen(),
            },

            // Enrutador dinámico para paso tipado de argumentos
            onGenerateRoute: (settings) {
              if (settings.name == '/producto/detalle') {
                final producto = settings.arguments as Producto?;
                return MaterialPageRoute(
                  builder: (context) => DetalleProductoScreen(producto: producto),
                );
              }
              if (settings.name == '/pedidos/detalle') {
                final pedido = settings.arguments as Pedido?;
                return MaterialPageRoute(
                  builder: (context) => DetallePedidoScreen(pedido: pedido),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
