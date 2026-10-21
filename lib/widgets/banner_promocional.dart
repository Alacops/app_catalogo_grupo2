import 'package:flutter/material.dart';

/// ============================================================================
/// BANNER PROMOCIONAL SUPERIOR CON STACK Y DEGRADADO (Requerimiento 1)
/// Emplea Stack con StackFit.expand, imagen, degradado oscuro y textos legibles
/// ============================================================================

class BannerPromocional extends StatelessWidget {
  const BannerPromocional({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Imagen de fondo del cafetal cusqueño
            Image.network(
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF3E2723),
                  child: const Center(
                    child: Icon(Icons.coffee, size: 64, color: Colors.white24),
                  ),
                );
              },
            ),

            // 2. Degradado oscuro superpuesto para garantizar contraste tipográfico
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Badge superior de denominación de origen
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9971F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'ORIGEN CUSCO · 100% ORGÁNICO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Textos promocionales anclados en la parte inferior
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Cosecha Especial 2026',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Café & Cacao Fino de La Convención',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.eco, size: 14, color: Color(0xFF81C784)),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Directo de productores locales con comercio justo',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
