import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';
import '../providers/favoritos_provider.dart';
import 'carrito_screen.dart';
import 'catalogo_screen.dart';
import 'favoritos_screen.dart';
import 'ofertas_screen.dart';

/// Contenedor principal con navegación inferior entre las secciones.
///
/// Usa un [IndexedStack] para conservar el estado de cada pestaña y
/// [Badge] para mostrar el número de favoritos y de ítems del carrito,
/// que se actualizan en tiempo real gracias a los providers.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const List<Widget> _pantallas = [
    CatalogoScreen(),
    OfertasScreen(),
    FavoritosScreen(),
    CarritoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // context.watch hace que el badge se reconstruya cuando cambia el estado.
    final favoritos = context.watch<FavoritosProvider>().cantidad;
    final enCarrito = context.watch<CarritoProvider>().cantidadTotal;

    return Scaffold(
      body: IndexedStack(index: _index, children: _pantallas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF7A1F2B),
        unselectedItemColor: Colors.black45,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            label: 'Ofertas',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: favoritos > 0,
              label: Text('$favoritos'),
              child: const Icon(Icons.favorite_border),
            ),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: enCarrito > 0,
              label: Text('$enCarrito'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
