import 'package:flutter/material.dart';
import '../data/catalogo_data.dart';
import '../widgets/banner_promocional.dart';
import '../widgets/cabecera_institucional.dart';
import '../widgets/filtro_categorias.dart';
import '../widgets/panel_emprendimiento_info.dart';
import '../widgets/seccion_interesar.dart';
import '../widgets/tarjeta_producto.dart';

/// ============================================================================
/// PANTALLA PRINCIPAL — CATÁLOGO DE PRODUCTOS DE EMPRENDIMIENTO LOCAL
/// Proyecto Integrador 2 — Sesión 6 — UNSAAC (IF616BIN)
/// Equipo: Grupo 2 (Saire Bustamante, Condori Contreras, Aranibar Rojas)
/// ============================================================================

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A1F2B),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aroma Sagrado · Cusco',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
            ),
            Text(
              'Café Especial & Cacao Chuncho de La Convención',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Buscar producto',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
            tooltip: 'Carrito',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Ficha Académica Oficial del Grupo 2
            const CabeceraInstitucional(),

            // 2. Banner promocional con Stack y degradado (Requerimiento 1)
            const BannerPromocional(),

            // 3. Filtros por categoría con Wrap y FilterChip (Requerimiento 2)
            _seccion('Explorar por Categoría'),
            const FiltroCategorias(
              categorias: CatalogoData.categorias,
              categoriaSeleccionada: 'Todos',
            ),

            // 4. Rejilla principal adaptativa con LayoutBuilder y GridView (Requerimientos 3 y 4)
            _seccion('Catálogo de Productos de Temporada'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Comportamiento adaptativo exigido por el PDF oficial:
                  // - Móvil (< 600 pt): 2 columnas
                  // - Tableta (600 a 839 pt): 3 columnas
                  // - Escritorio (>= 840 pt): 4 columnas
                  final int crossAxisCount;
                  final double childAspectRatio;

                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 2;
                    childAspectRatio = 0.68;
                  } else if (constraints.maxWidth < 840) {
                    crossAxisCount = 3;
                    childAspectRatio = 0.72;
                  } else {
                    crossAxisCount = 4;
                    childAspectRatio = 0.75;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: CatalogoData.productos.length,
                    itemBuilder: (context, index) {
                      return TarjetaProducto(
                        producto: CatalogoData.productos[index],
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 5. Sección «También te puede interesar» con ListView horizontal (Requerimiento 5)
            _seccion('También te puede interesar'),
            const SeccionInteresar(
              productos: CatalogoData.productosInteresar,
            ),

            const SizedBox(height: 12),

            // 6. Panel de Compromiso de Origen y Comercio Justo
            _seccion('Nuestra Historia y Origen'),
            const PanelEmprendimientoInfo(),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF7A1F2B),
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Ofertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Mi Cuenta',
          ),
        ],
      ),
    );
  }

  /// ============================================================================
  /// ENCABEZADO DE SECCIÓN REUTILIZABLE (Requerimiento 6)
  /// Método privado para garantizar espaciado y tipografía consistente
  /// ============================================================================
  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
              letterSpacing: 0.2,
            ),
          ),
          const Text(
            'Ver todo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A1F2B),
            ),
          ),
        ],
      ),
    );
  }
}
