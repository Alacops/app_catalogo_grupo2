import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database_helper.dart';
import '../providers/tema_provider.dart';
import '../services/preferencias_service.dart';

/// Pantalla de Ajustes de la aplicación.
/// Permite alternar tema claro/oscuro, configurar preferencias persistidas con SharedPreferences,
/// reiniciar semillas de SQLite y visualizar información académica del Grupo 2 (UNSAAC).
class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _prefs = PreferenciasService.instance;
  late String _orden;
  late String _distrito;
  late bool _notificaciones;

  final List<String> _distritosCusco = [
    'Cusco Centro',
    'Wanchaq',
    'San Sebastián',
    'San Jerónimo',
    'Santiago',
    'Poroy',
    'Saylla',
  ];

  @override
  void initState() {
    super.initState();
    _orden = _prefs.ordenCatalogo;
    _distrito = _distritosCusco.contains(_prefs.distritoPredeterminado)
        ? _prefs.distritoPredeterminado
        : _distritosCusco.first;
    _notificaciones = _prefs.notificaciones;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final temaProvider = context.watch<TemaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes y Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SECCIÓN 1: APARIENCIA
          Text(
            'Apariencia y Tema',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    temaProvider.modoOscuro ? Icons.dark_mode : Icons.light_mode,
                    color: tema.colorScheme.primary,
                  ),
                  title: const Text('Modo Oscuro'),
                  subtitle: const Text('Alternar entre tema claro y oscuro (persiste en SharedPreferences)'),
                  value: temaProvider.modoOscuro,
                  onChanged: (val) => temaProvider.alternarTema(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 2: PREFERENCIAS DEL CATÁLOGO
          Text(
            'Preferencias de Compra',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.sort_rounded),
                    title: const Text('Orden por defecto del catálogo'),
                    trailing: DropdownButton<String>(
                      value: _orden,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'destacados', child: Text('Destacados')),
                        DropdownMenuItem(value: 'precio_asc', child: Text('Menor precio')),
                        DropdownMenuItem(value: 'precio_desc', child: Text('Mayor precio')),
                        DropdownMenuItem(value: 'calificacion', child: Text('Mejor puntuación')),
                      ],
                      onChanged: (nuevo) async {
                        if (nuevo != null) {
                          setState(() => _orden = nuevo);
                          await _prefs.setOrdenCatalogo(nuevo);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Distrito predeterminado'),
                    trailing: DropdownButton<String>(
                      value: _distrito,
                      underline: const SizedBox(),
                      items: _distritosCusco.map((d) {
                        return DropdownMenuItem(value: d, child: Text(d));
                      }).toList(),
                      onChanged: (nuevo) async {
                        if (nuevo != null) {
                          setState(() => _distrito = nuevo);
                          await _prefs.setDistritoPredeterminado(nuevo);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Notificaciones de cosecha y ofertas'),
                    value: _notificaciones,
                    onChanged: (val) async {
                      setState(() => _notificaciones = val);
                      await _prefs.setNotificaciones(val);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 3: GESTIÓN DE BASE DE DATOS LOCAL
          Text(
            'Mantenimiento SQLite',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restore_page_outlined, color: Colors.orange),
                  title: const Text('Reiniciar Base de Datos SQLite'),
                  subtitle: const Text('Restaura los 3 pedidos semilla demostrativos'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('¿Reiniciar base de datos?'),
                        content: const Text(
                          'Se restablecerán los pedidos a las semillas demostrativas iniciales de Cusco.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('CANCELAR'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('REINICIAR'),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      await DatabaseHelper.instancia.reiniciarBaseDeDatos();
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Base de datos SQLite reiniciada con éxito.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECCIÓN 4: INFORMACIÓN ACADÉMICA UNSAAC
          Text(
            'Información Académica',
            style: tema.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: tema.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.brown, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'UNSAAC · Ing. de Sistemas',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Desarrollo de Software II (IF616BIN)',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Docente: Mtro. Ing. Yover Collantes Valer'),
                  const SizedBox(height: 8),
                  const Text('Integrantes Grupo 2:'),
                  const SizedBox(height: 4),
                  const Text('• Edmil Jampier Saire Bustamante (210491)'),
                  const Text('• Alain Armando Condori Contreras (211339)'),
                  const Text('• Axel Aranibar Rojas (210935)'),
                  const SizedBox(height: 12),
                  const Text(
                    'Proyecto: Aroma Sagrado · Cusco (Sesión 07 - Unidad II)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
