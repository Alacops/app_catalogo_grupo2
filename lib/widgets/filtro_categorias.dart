import 'package:flutter/material.dart';

/// ============================================================================
/// FILTRO DE CATEGORÍAS CON WRAP Y FILTERCHIP (Requerimiento 2)
/// Permite salto de línea fluido sin provocar desbordamiento horizontal
/// ============================================================================

class FiltroCategorias extends StatelessWidget {
  final List<String> categorias;
  final String categoriaSeleccionada;

  const FiltroCategorias({
    super.key,
    required this.categorias,
    this.categoriaSeleccionada = 'Todos',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: categorias.map((cat) {
          final bool isSelected = cat == categoriaSeleccionada;
          return FilterChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: null, // Stateless: interfaz estática
            selectedColor: const Color(0xFF7A1F2B),
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF3E2723),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? const Color(0xFF7A1F2B) : Colors.grey.shade300,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          );
        }).toList(),
      ),
    );
  }
}
