import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/catalogo_data.dart';
import '../widgets/grilla_productos.dart';

/// Pantalla de Ofertas con detección de movimiento (Acelerómetro - Sensores Plus).
/// Permite al usuario agitar el dispositivo físico (o presionar el botón de simulación)
/// para desbloquear cupones de descuento interactivos.
class OfertasScreen extends StatefulWidget {
  const OfertasScreen({super.key});

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {
  StreamSubscription<AccelerometerEvent>? _acelerometroSub;
  DateTime _ultimoShake = DateTime.now();
  bool _cuponDesbloqueado = false;
  final String _codigoCupon = 'CUSCO-SAGRADO-15';

  @override
  void initState() {
    super.initState();
    _iniciarEscuchaAcelerometro();
  }

  void _iniciarEscuchaAcelerometro() {
    try {
      _acelerometroSub = accelerometerEventStream().listen(
        (AccelerometerEvent evento) {
          // Magnitud vectorial de la aceleración
          final gX = evento.x / 9.81;
          final gY = evento.y / 9.81;
          final gZ = evento.z / 9.81;
          final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);

          // Umbral de detección de agitado
          if (gForce > 2.2) {
            final ahora = DateTime.now();
            if (ahora.difference(_ultimoShake).inMilliseconds > 1500) {
              _ultimoShake = ahora;
              _desbloquearCupon();
            }
          }
        },
        onError: (err) {
          debugPrint('Error en acelerómetro: $err');
        },
      );
    } catch (e) {
      debugPrint('Acelerómetro no disponible en este entorno: $e');
    }
  }

  @override
  void dispose() {
    // Liberación rigurosa de suscripción para evitar fugas de memoria
    _acelerometroSub?.cancel();
    super.dispose();
  }

  void _desbloquearCupon() {
    if (!mounted) return;
    setState(() => _cuponDesbloqueado = true);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.celebration, color: Colors.amber, size: 30),
            SizedBox(width: 8),
            Text('¡Cupón Desbloqueado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡El sensor de acelerómetro detectó tu movimiento! Disfruta de un 15% de descuento adicional en tu próximo pedido.',
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'CÓDIGO DE DESCUENTO:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _codigoCupon,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('¡GENIAL, GRACIAS!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ofertas = CatalogoData.productos
        .where((p) => p.esOferta || p.tieneDescuento)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas & Sensores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vibration_rounded),
            tooltip: 'Simular Agitado (Shake)',
            onPressed: _desbloquearCupon,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner interactivo del sensor Acelerómetro
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tema.colorScheme.primary,
                  tema.colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: tema.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.screen_rotation_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Agita tu dispositivo!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cuponDesbloqueado
                            ? 'Cupón activo: $_codigoCupon'
                            : 'Detección por acelerómetro de ofertas secretas.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: tema.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _desbloquearCupon,
                  child: const Text('Agitar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${ofertas.length} cafés cusqueños en promoción',
              style: tema.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: GrillaProductos(
              productos: ofertas,
              propioScroll: true,
            ),
          ),
        ],
      ),
    );
  }
}
