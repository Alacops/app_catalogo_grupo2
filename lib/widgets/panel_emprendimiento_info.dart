import 'package:flutter/material.dart';

/// ============================================================================
/// PANEL INFORMATIVO DEL EMPRENDIMIENTO LOCAL CUSQUEÑO
/// Muestra compromisos de Comercio Justo, Origen y Sostenibilidad
/// ============================================================================

class PanelEmprendimientoInfo extends StatelessWidget {
  const PanelEmprendimientoInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3E2723),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFFC9971F), size: 22),
              SizedBox(width: 8),
              Text(
                'Compromiso con Nuestra Tierra',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Cada compra apoya directamente a más de 45 familias cafetaleras y cacaoteras de Santa Teresa, Echarati y Ocobamba en los valles de La Convención, Cusco. Fomentamos prácticas agroecológicas que protegen la biodiversidad andina-amazónica.',
            style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSello(Icons.eco, '100% Orgánico'),
              _buildSello(Icons.handshake, 'Comercio Justo'),
              _buildSello(Icons.place, 'Origen Cusco'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSello(IconData icono, String texto) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: const Color(0xFFC9971F), size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          texto,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
