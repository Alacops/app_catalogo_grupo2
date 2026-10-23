import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';

/// ============================================================================
/// FORMULARIO DE PEDIDO (CHECKOUT) — demostración de Formularios y validación
/// Usa Form + `GlobalKey<FormState>`, TextFormField con validators,
/// DropdownButtonFormField e inputFormatters. Al confirmar, vacía el carrito.
/// ============================================================================

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  static const _distritos = [
    'Cusco', 'Wanchaq', 'San Sebastián', 'San Jerónimo', 'Santiago', 'Poroy'
  ];
  String _distrito = 'Cusco';
  String _entrega = 'Delivery';
  String _pago = 'Efectivo';
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  bool get _esDelivery => _entrega == 'Delivery';

  void _enviar() {
    final formOk = _formKey.currentState!.validate();
    if (!formOk) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los términos para continuar.')),
      );
      return;
    }
    _mostrarConfirmacion();
  }

  Future<void> _mostrarConfirmacion() async {
    final carrito = context.read<CarritoProvider>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 44),
        title: const Text('¡Pedido confirmado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gracias, ${_nombreCtrl.text.trim()}.'),
            const SizedBox(height: 8),
            _filaResumen('Entrega', _esDelivery ? 'Delivery · $_distrito' : 'Recojo en tienda'),
            _filaResumen('Pago', _pago),
            _filaResumen('Productos', '${carrito.cantidadTotal} unidad(es)'),
            const Divider(height: 18),
            _filaResumen('Total', 'S/ ${carrito.total.toStringAsFixed(2)}', destacado: true),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7A1F2B)),
            onPressed: () {
              carrito.vaciar();
              Navigator.pop(ctx); // cierra el diálogo
              Navigator.popUntil(context, (route) => route.isFirst); // vuelve al inicio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tu pedido fue registrado con éxito.')),
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _filaResumen(String k, String v, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Colors.black54)),
          Text(v,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: destacado ? const Color(0xFF7A1F2B) : Colors.black87,
                fontSize: destacado ? 16 : 14,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = context.select<CarritoProvider, double>((c) => c.total);
    final unidades = context.select<CarritoProvider, int>((c) => c.cantidadTotal);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Datos del Pedido',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Resumen del pedido
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$unidades producto(s)',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Total: S/ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _titulo('Datos de contacto'),
            TextFormField(
              controller: _nombreCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _deco('Nombre completo', Icons.person_outline),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Ingresa tu nombre completo';
                if (t.length < 5) return 'El nombre es demasiado corto';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: _deco('Celular (9 dígitos)', Icons.phone_outlined),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Ingresa tu número de celular';
                if (!RegExp(r'^9\d{8}$').hasMatch(t)) {
                  return 'Debe tener 9 dígitos y empezar con 9';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _correoCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _deco('Correo electrónico', Icons.email_outlined),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.isEmpty) return 'Ingresa tu correo';
                final re = RegExp(r'^[\w.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
                if (!re.hasMatch(t)) return 'Correo no válido';
                return null;
              },
            ),

            const SizedBox(height: 20),
            _titulo('Entrega'),
            DropdownButtonFormField<String>(
              initialValue: _entrega,
              decoration: _deco('Modalidad', Icons.local_shipping_outlined),
              items: const [
                DropdownMenuItem(value: 'Delivery', child: Text('Delivery a domicilio')),
                DropdownMenuItem(value: 'Recojo', child: Text('Recojo en tienda')),
              ],
              onChanged: (v) => setState(() => _entrega = v ?? 'Delivery'),
            ),
            if (_esDelivery) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _distrito,
                decoration: _deco('Distrito', Icons.map_outlined),
                items: _distritos
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _distrito = v ?? 'Cusco'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccionCtrl,
                decoration: _deco('Dirección exacta', Icons.home_outlined),
                validator: (v) {
                  if (!_esDelivery) return null;
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Ingresa la dirección de entrega';
                  if (t.length < 6) return 'Dirección demasiado corta';
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),
            _titulo('Pago'),
            DropdownButtonFormField<String>(
              initialValue: _pago,
              decoration: _deco('Método de pago', Icons.payments_outlined),
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Yape', child: Text('Yape')),
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia bancaria')),
              ],
              onChanged: (v) => setState(() => _pago = v ?? 'Efectivo'),
            ),

            const SizedBox(height: 12),
            TextFormField(
              controller: _notasCtrl,
              maxLines: 2,
              decoration: _deco('Notas (opcional)', Icons.sticky_note_2_outlined),
            ),

            const SizedBox(height: 6),
            CheckboxListTile(
              value: _aceptaTerminos,
              onChanged: (v) => setState(() => _aceptaTerminos = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF7A1F2B),
              title: const Text('Acepto los términos y condiciones del pedido',
                  style: TextStyle(fontSize: 13)),
            ),

            const SizedBox(height: 10),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF7A1F2B),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _enviar,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar pedido',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Color(0xFF3E2723))),
      );

  InputDecoration _deco(String label, IconData icono) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: const Color(0xFF7A1F2B)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7A1F2B), width: 1.5),
        ),
      );
}
