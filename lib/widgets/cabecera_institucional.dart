import 'package:flutter/material.dart';

/// ============================================================================
/// CABECERA INSTITUCIONAL — DATOS OFICIALES DEL GRUPO 2
/// Universidad Nacional de San Antonio Abad del Cusco (UNSAAC)
/// ============================================================================

class CabeceraInstitucional extends StatelessWidget {
  const CabeceraInstitucional({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7A1F2B).withValues(alpha: 0.15)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A1F2B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNIVERSIDAD NACIONAL DE SAN ANTONIO ABAD DEL CUSCO',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A1F2B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ingeniería Informática y de Sistemas · IF616BIN',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9971F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'GRUPO 2',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF946A00),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Integrantes del Proyecto Integrador:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Edmil Jampier Saire Bustamante (Cód. 174449)\n'
                      '• Alain Armando Condori Contreras (Cód. 021501)\n'
                      '• Axel Aranibar Rojas (Cód. 220547)',
                      style: TextStyle(fontSize: 11.5, height: 1.35, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Docente: Mtro. Ing. Yover Collantes Valer · Semestre 2026-II',
            style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
