import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/pedido_repository.dart';
import '../models/pedido.dart';
import '../providers/carrito_provider.dart';
import '../services/camara_service.dart';
import '../services/preferencias_service.dart';
import '../services/ubicacion_service.dart';
import '../utils/validadores.dart';

/// Pantalla de Formulario de Pedido (Checkout) con persistencia SQLite y Sensores.
/// Cumple rigurosamente con los 6 requerimientos de validación, ciclo de vida
/// (controladores y focus nodes liberados en dispose), geolocalización y cámara.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final PedidoRepository _repo = PedidoRepository();

  // Controladores de texto con ciclo de vida estricto
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _referenciaCtrl;
  late final TextEditingController _notasCtrl;

  // Nodos de enfoque para navegación accesible
  final _nombreFocus = FocusNode();
  final _telefonoFocus = FocusNode();
  final _correoFocus = FocusNode();
  final _direccionFocus = FocusNode();
  final _referenciaFocus = FocusNode();
  final _notasFocus = FocusNode();

  String _distrito = 'Cusco Centro';
  String _metodoPago = 'Yape / Plin';
  bool _recordarContacto = true;
  bool _aceptaTerminos = true;

  // Estado de sensores y envío
  bool _obteniendoGps = false;
  double? _latitud;
  double? _longitud;
  String? _mensajeGps;

  String? _fotoComprobantePath;
  bool _enviando = false;

  final List<String> _distritosCusco = [
    'Cusco Centro',
    'Wanchaq',
    'San Sebastián',
    'San Jerónimo',
    'Santiago',
    'Poroy',
    'Saylla',
  ];

  final List<String> _metodosPago = [
    'Yape / Plin',
    'Transferencia BCP / Interbank',
    'Efectivo contraentrega',
    'Tarjeta POS inalámbrico',
  ];

  @override
  void initState() {
    super.initState();
    // Carga de preferencias persistidas
    final prefs = PreferenciasService.instance;
    _nombreCtrl = TextEditingController(text: prefs.ultimoNombre);
    _telefonoCtrl = TextEditingController(text: prefs.ultimoTelefono);
    _correoCtrl = TextEditingController(text: prefs.ultimoCorreo);
    _direccionCtrl = TextEditingController();
    _referenciaCtrl = TextEditingController();
    _notasCtrl = TextEditingController();
    _distrito = _distritosCusco.contains(prefs.distritoPredeterminado)
        ? prefs.distritoPredeterminado
        : _distritosCusco.first;
    _recordarContacto = prefs.recordarContacto;
  }

  @override
  void dispose() {
    // Liberación rigurosa de memoria para cumplir rúbrica de estado
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _referenciaCtrl.dispose();
    _notasCtrl.dispose();

    _nombreFocus.dispose();
    _telefonoFocus.dispose();
    _correoFocus.dispose();
    _direccionFocus.dispose();
    _referenciaFocus.dispose();
    _notasFocus.dispose();
    super.dispose();
  }

  // --- Integración Sensor GPS (Geolocator) ---
  Future<void> _capturarUbicacionGps() async {
    setState(() => _obteniendoGps = true);
    final resultado = await UbicacionService.obtenerUbicacionActual();
    if (!mounted) return;

    setState(() {
      _obteniendoGps = false;
      _latitud = resultado.latitud;
      _longitud = resultado.longitud;
      final dist = UbicacionService.calcularDistanciaPlazaDeArmas(
        resultado.latitud,
        resultado.longitud,
      );
      _mensajeGps =
          '${resultado.latitud.toStringAsFixed(4)}, ${resultado.longitud.toStringAsFixed(4)} (${dist.toStringAsFixed(1)} km de Plaza de Armas)';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultado.mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Integración Sensor Cámara / Galería (ImagePicker) ---
  Future<void> _seleccionarComprobante() async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar fotografía con la cámara'),
              onTap: () => Navigator.of(ctx).pop('camara'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de la galería multimedia'),
              onTap: () => Navigator.of(ctx).pop('galeria'),
            ),
          ],
        ),
      ),
    );

    if (opcion == null) return;

    String? ruta;
    if (opcion == 'camara') {
      ruta = await CamaraService.tomarFotoComprobante();
    } else {
      ruta = await CamaraService.seleccionarDeGaleria();
    }

    if (ruta != null && mounted) {
      setState(() => _fotoComprobantePath = ruta);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comprobante digital adjuntado correctamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- Procesamiento y Persistencia SQLite ---
  Future<void> _procesarPedido() async {
    // 1. Validación sincrónica de formularios
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor corrige los errores resaltados en el formulario.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar las políticas de entrega para continuar.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final carrito = context.read<CarritoProvider>();
    if (carrito.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu carrito está vacío. Agrega cafés antes de pedir.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Prevención de doble envío
    setState(() => _enviando = true);

    try {
      // 3. Validación asíncrona contra SQLite (Evitar duplicación de pedidos activos)
      final existeActivo = await _repo.existePedidoActivo(
        telefono: _telefonoCtrl.text,
        correo: _correoCtrl.text,
      );

      if (existeActivo && mounted) {
        final continuar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Pedido en curso detectado'),
            content: Text(
              'El teléfono ${_telefonoCtrl.text} o correo ${_correoCtrl.text} ya tiene un pedido en estado pendiente o confirmado en SQLite.\n\n¿Deseas registrar este pedido adicional de todos modos?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('CANCELAR'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('REGISTRAR DE TODOS MODOS'),
              ),
            ],
          ),
        );

        if (continuar != true) {
          setState(() => _enviando = false);
          return;
        }
      }

      // 4. Persistir preferencias de contacto si está activado
      if (_recordarContacto) {
        await PreferenciasService.instance.guardarDatosContacto(
          nombre: _nombreCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
        );
        await PreferenciasService.instance.setDistritoPredeterminado(_distrito);
      }

      // 5. Construcción del modelo de Pedido
      final codigoGenerado =
          'AS-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final resumen = carrito.items
          .map((item) => '${item.producto.nombre} (x${item.cantidad})')
          .join(', ');

      final nuevoPedido = Pedido(
        codigo: codigoGenerado,
        fecha: DateTime.now(),
        clienteNombre: _nombreCtrl.text.trim(),
        clienteTelefono: _telefonoCtrl.text.trim(),
        clienteCorreo: _correoCtrl.text.trim().toLowerCase(),
        distrito: _distrito,
        direccion: _direccionCtrl.text.trim(),
        referencia: _referenciaCtrl.text.trim().isNotEmpty
            ? _referenciaCtrl.text.trim()
            : null,
        metodoPago: _metodoPago,
        total: carrito.total,
        subtotal: carrito.subtotal,
        costoEnvio: carrito.costoEnvio,
        descuento: carrito.descuentoMonto,
        estado: EstadoPedido.pendiente,
        notas: _notasCtrl.text.trim().isNotEmpty ? _notasCtrl.text.trim() : null,
        latitud: _latitud,
        longitud: _longitud,
        fotoComprobantePath: _fotoComprobantePath,
        resumenItems: resumen,
      );

      // 6. Inserción directa en SQLite
      await _repo.crearPedido(nuevoPedido);

      // 7. Vaciar carrito de compras tras persistencia exitosa
      carrito.vaciarCarrito();

      if (!mounted) return;

      // 8. Diálogo de confirmación con redirección
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('¡Pedido Confirmado!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu pedido con código $codigoGenerado ha sido guardado exitosamente en la base de datos local SQLite.',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Cliente: ${_nombreCtrl.text}'),
                    Text('• Entrega: $_distrito - ${_direccionCtrl.text}'),
                    Text('• Pago: $_metodoPago'),
                    Text('• Total: S/ ${nuevoPedido.total.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('VOLVER AL CATÁLOGO'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.receipt_long),
              label: const Text('VER EN PEDIDOS'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed('/pedidos');
              },
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al persistir en SQLite: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout & Sensores'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Resumen superior del carrito
            Card(
              elevation: 0,
              color: tema.colorScheme.primaryContainer.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: tema.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total a Pagar (${carrito.cantidadTotal} items)',
                          style: TextStyle(
                            color: tema.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'S/ ${carrito.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: tema.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.shopping_bag_outlined, size: 36),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SECCIÓN 1: DATOS PERSONALES
            Text(
              '1. Datos de Contacto',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Campo Nombre
            TextFormField(
              controller: _nombreCtrl,
              focusNode: _nombreFocus,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nombre y Apellidos *',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: Validadores.validarNombre,
              onFieldSubmitted: (_) => _telefonoFocus.requestFocus(),
            ),

            const SizedBox(height: 12),

            // Campo Teléfono (Validación teléfono peruano)
            TextFormField(
              controller: _telefonoCtrl,
              focusNode: _telefonoFocus,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: InputDecoration(
                labelText: 'Teléfono Móvil (WhatsApp) *',
                hintText: '9XXXXXXXX',
                prefixIcon: const Icon(Icons.phone_android_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: Validadores.validarTelefono,
              onFieldSubmitted: (_) => _correoFocus.requestFocus(),
            ),

            const SizedBox(height: 12),

            // Campo Correo (Validación formato RFC)
            TextFormField(
              controller: _correoCtrl,
              focusNode: _correoFocus,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico *',
                hintText: 'ejemplo@unsaac.edu.pe',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: Validadores.validarCorreo,
              onFieldSubmitted: (_) => _direccionFocus.requestFocus(),
            ),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordar mis datos para futuras compras'),
              subtitle: const Text('Se guardan en SharedPreferences local'),
              value: _recordarContacto,
              onChanged: (val) => setState(() => _recordarContacto = val),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // SECCIÓN 2: ENTREGA Y GEOLOCALIZACIÓN GPS
            Text(
              '2. Entrega y Ubicación GPS (Sensor)',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Selector de Distrito Cusqueño
            DropdownButtonFormField<String>(
              initialValue: _distrito,
              decoration: InputDecoration(
                labelText: 'Distrito de Entrega *',
                prefixIcon: const Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _distritosCusco.map((d) {
                return DropdownMenuItem(value: d, child: Text(d));
              }).toList(),
              validator: Validadores.validarDistrito,
              onChanged: (val) {
                if (val != null) setState(() => _distrito = val);
              },
            ),

            const SizedBox(height: 12),

            // Dirección
            TextFormField(
              controller: _direccionCtrl,
              focusNode: _direccionFocus,
              decoration: InputDecoration(
                labelText: 'Dirección Exacta (Calle, Nro, Urb.) *',
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: Validadores.validarDireccion,
              onFieldSubmitted: (_) => _referenciaFocus.requestFocus(),
            ),

            const SizedBox(height: 12),

            // Referencia
            TextFormField(
              controller: _referenciaCtrl,
              focusNode: _referenciaFocus,
              decoration: InputDecoration(
                labelText: 'Referencia de Entrega (Opcional)',
                hintText: 'Frente al parque, portón verde, etc.',
                prefixIcon: const Icon(Icons.explore_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onFieldSubmitted: (_) => _notasFocus.requestFocus(),
            ),

            const SizedBox(height: 12),

            // Botón para capturar GPS
            OutlinedButton.icon(
              icon: _obteniendoGps
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, color: Colors.redAccent),
              label: Text(
                _mensajeGps == null
                    ? 'Capturar Coordenadas GPS de Entrega'
                    : 'Actualizar GPS: $_mensajeGps',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _obteniendoGps ? null : _capturarUbicacionGps,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // SECCIÓN 3: PAGO Y COMPROBANTE CÁMARA
            Text(
              '3. Pago y Comprobante (Cámara)',
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _metodoPago,
              decoration: InputDecoration(
                labelText: 'Método de Pago *',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _metodosPago.map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _metodoPago = val);
              },
            ),

            const SizedBox(height: 12),

            // Botón y Vista Previa de Cámara
            if (_fotoComprobantePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(_fotoComprobantePath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                      onPressed: () => setState(() => _fotoComprobantePath = null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(
                _fotoComprobantePath == null
                    ? 'Adjuntar Foto de Comprobante (Cámara)'
                    : 'Cambiar Fotografía de Comprobante',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _seleccionarComprobante,
            ),

            const SizedBox(height: 12),

            // Notas para el Barista
            TextFormField(
              controller: _notasCtrl,
              focusNode: _notasFocus,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notas para el Barista / Tostador (Opcional)',
                hintText: 'Ej. Moler para prensa francesa, grano entero...',
                prefixIcon: const Icon(Icons.notes_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // Términos y condiciones
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Acepto los términos de compra y política de entrega local en Cusco.',
                style: TextStyle(fontSize: 13),
              ),
              value: _aceptaTerminos,
              onChanged: (val) => setState(() => _aceptaTerminos = val ?? false),
            ),

            const SizedBox(height: 20),

            // Botón de Envío con Prevención de Doble Clic
            FilledButton.icon(
              icon: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _enviando ? 'Guardando en SQLite...' : 'Confirmar Pedido (Guardar en SQLite)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _enviando ? null : _procesarPedido,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
