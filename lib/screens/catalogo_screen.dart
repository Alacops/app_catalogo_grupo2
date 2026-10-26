import 'package:flutter/material.dart';

import '../data/catalogo_data.dart';
import '../models/producto.dart';
import '../widgets/banner_promocional.dart';
import '../widgets/cabecera_institucional.dart';
import '../widgets/filtro_categorias.dart';
import '../widgets/grilla_productos.dart';
import '../widgets/panel_emprendimiento_info.dart';
import '../widgets/seccion_interesar.dart';

/// ============================================================================
/// PANTALLA PRINCIPAL — CATÁLOGO con BÚSQUEDA y FILTROS funcionales
/// Estado LOCAL (setState): categoría seleccionada y texto de búsqueda.
/// UNSAAC (IF616BIN) — Grupo 2 (Saire Bustamante, Condori Contreras, Aranibar)
/// ============================================================================

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _categoria = 'Todos';
  String _busqueda = '';
  final TextEditingController _buscadorCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _mostrarBotonSubir = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final mostrar = _scrollCtrl.offset > 250;
      if (mostrar != _mostrarBotonSubir) {
        setState(() => _mostrarBotonSubir = mostrar);
      }
    });
  }

  /// Productos que cumplen el filtro de categoría y el texto de búsqueda.
  List<Producto> get _filtrados {
    final q = _busqueda.trim().toLowerCase();
    return CatalogoData.productos.where((p) {
      final coincideCategoria = _categoria == 'Todos' || p.categoria == _categoria;
      final coincideBusqueda = q.isEmpty ||
          p.nombre.toLowerCase().contains(q) ||
          p.categoria.toLowerCase().contains(q) ||
          p.origen.toLowerCase().contains(q);
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  @override
  void dispose() {
    _buscadorCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrados;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A1F2B),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aroma Sagrado · Cusco',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
            Text('Café Especial & Cacao Chuncho de La Convención',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'Historial de Pedidos (SQLite)',
            onPressed: () => Navigator.of(context).pushNamed('/pedidos'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes y Configuración',
            onPressed: () => Navigator.of(context).pushNamed('/ajustes'),
          ),
        ],
      ),
      floatingActionButton: _mostrarBotonSubir
          ? FloatingActionButton.small(
              backgroundColor: const Color(0xFF7A1F2B),
              foregroundColor: Colors.white,
              tooltip: 'Volver arriba',
              onPressed: () {
                _scrollCtrl.animateTo(
                  0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CabeceraInstitucional(),
            const BannerPromocional(),

            // Buscador (estado local)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _buscadorCtrl,
                onChanged: (v) => setState(() => _busqueda = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar café, cacao, origen…',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7A1F2B)),
                  suffixIcon: _busqueda.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Limpiar',
                          onPressed: () {
                            _buscadorCtrl.clear();
                            setState(() => _busqueda = '');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF7A1F2B), width: 1.5),
                  ),
                ),
              ),
            ),

            _tituloSeccion('Explorar por Categoría'),
            FiltroCategorias(
              categorias: CatalogoData.categorias,
              categoriaSeleccionada: _categoria,
              onSeleccion: (c) => setState(() => _categoria = c),
            ),

            _tituloSeccion('Catálogo de Productos (${filtrados.length})'),
            if (filtrados.isEmpty)
              _sinResultados()
            else
              GrillaProductos(productos: filtrados),

            const SizedBox(height: 12),
            _tituloSeccion('También te puede interesar'),
            const SeccionInteresar(productos: CatalogoData.productosInteresar),

            const SizedBox(height: 12),
            _tituloSeccion('Nuestra Historia y Origen'),
            const PanelEmprendimientoInfo(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3E2723),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _sinResultados() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          const Text(
            'No se encontraron productos',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          const Text(
            'Prueba con otra categoría o término de búsqueda.',
            style: TextStyle(fontSize: 12.5, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
