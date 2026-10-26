# 🍫☕ Catálogo «Aroma Sagrado · Cusco»
### Sesión 07: Estados, Persistencia SQLite, Formularios y Sensores
Aplicación en **Flutter** para un emprendimiento local cusqueño de **café de especialidad y cacao chuncho** de los valles de La Convención y Valle Sagrado.

**Proyecto Integrador 02 — Desarrollo de Software II (IF616BIN)**  
Universidad Nacional de San Antonio Abad del Cusco (UNSAAC) · Escuela Profesional de Ingeniería Informática y de Sistemas · Semestre 2026-II  

---

## 👥 Equipo de Trabajo (Grupo 2)

| Integrante | Código | Correo Institucional |
|---|:---:|---|
| **Edmil Jampier Saire Bustamante** | 210491 | edmil.saire@unsaac.edu.pe |
| **Alain Armando Condori Contreras** | 211339 | alain.condori@unsaac.edu.pe |
| **Axel Aranibar Rojas** | 210935 | axel.aranibar@unsaac.edu.pe |

**Docente:** Mtro. Ing. Yover Collantes Valer  

---

## 🧩 Implementación Sesión 07 (Rúbrica 20 / 20 Puntos)

1. **Manejo de Estado y Controladores (4.0 pts):**
   - Inyección reactiva con `MultiProvider` (`TemaProvider`, `FavoritosProvider`, `CarritoProvider`).
   - Liberación estricta de memoria en el método `dispose()` de `TextEditingController`, `FocusNode`, `ScrollController` y suscripciones `StreamSubscription` a acelerómetro.
2. **Navegación Avanzada (3.0 pts):**
   - Rutas nombradas centralizadas (`'/'`, `'/checkout'`, `'/pedidos'`, `'/ajustes'`, `'/ofertas'`).
   - Rutas tipadas con paso de argumentos (`'/producto/detalle'`, `'/pedidos/detalle'`) y retorno de resultados con refresco reactivo.
3. **Persistencia Relacional SQLite (4.0 pts):**
   - Base de datos relacional local `pedidos_aroma_sagrado.db` con tabla `pedidos` indexada.
   - Patrón Repositorio en `PedidoRepository` (CRUD completo y validación asíncrona de duplicados).
   - Patrón Singleton en `DatabaseHelper` con soporte multiplataforma FFI.
   - `PreferenciasService` (`SharedPreferences`) para tema visual (claro / oscuro) y preferencias de contacto.
4. **Formularios y Validaciones (4.0 pts):**
   - Formulario de checkout con 6 validaciones (sincrónicas y asíncronas).
   - Prevención de doble envío (`_enviando = true` desactiva botón con spinner).
5. **Sensores de Hardware Móvil (2.0 pts):**
   - **GPS (`geolocator`):** Captura de coordenadas y cálculo de distancia a la Plaza de Armas del Cusco con degradación elegante.
   - **Cámara / Galería (`image_picker`):** Captura de foto de comprobante y persistencia local en `/comprobantes/`.
   - **Acelerómetro (`sensors_plus`):** Detección de sacudida (*shake gesture*) para desbloqueo de cupones con botón de simulación.
6. **Arquitectura Limpia (2.0 pts):**
   - 7 capas modulares (`models/`, `data/`, `services/`, `providers/`, `screens/`, `widgets/`, `utils/`). Cero sentencias SQL en la UI.
7. **Documentación Oficial (1.0 pt):**
   - Informe técnico de 6 páginas conforme al **Anexo C** (`informe/Informe_Unidad2_Grupo2_IF616BIN.pdf`).
   - Suite completa de 20 pruebas unitarias y de integración pasando al 100%.

---

## 🗂️ Estructura del Proyecto

```
lib/
├── main.dart                          # MultiProvider + SQLite FFI + SharedPreferences + Rutas
├── models/
│   ├── producto.dart                  # Modelo de café con serialización JSON
│   ├── item_carrito.dart              # Línea de compra reactiva
│   └── pedido.dart                    # Entidad relacional SQLite con toMap/fromMap y EstadoPedido
├── data/
│   ├── catalogo_data.dart             # Catálogo maestro de cafés cusqueños
│   ├── database_helper.dart           # Singleton SQLite, apertura resiliente y semillas iniciales
│   └── pedido_repository.dart         # CRUD SQLite y validación asíncrona de duplicados
├── services/
│   ├── preferencias_service.dart      # Wrapper singleton SharedPreferences
│   ├── ubicacion_service.dart         # Sensor GPS con Geolocator
│   └── camara_service.dart            # Sensor Cámara/Galería con ImagePicker
├── providers/
│   ├── tema_provider.dart             # Gestión de ThemeMode (Claro / Oscuro)
│   ├── favoritos_provider.dart        # Estado reactivo de favoritos
│   └── carrito_provider.dart          # Estado reactivo del carrito de compras
├── screens/
│   ├── main_screen.dart               # Contenedor principal con IndexedStack y Badges
│   ├── catalogo_screen.dart           # Catálogo con ScrollController y botón flotante
│   ├── detalle_producto_screen.dart   # Navegación tipada con tabs informativos
│   ├── checkout_screen.dart           # Formulario con validaciones, GPS, Cámara y SQLite
│   ├── historial_pedidos_screen.dart  # Historial SQLite reactivo con filtros
│   ├── detalle_pedido_screen.dart     # Detalle de pedido con foto y cambio de estado
│   ├── ofertas_screen.dart            # Acelerómetro con detección de shake
│   └── ajustes_screen.dart            # Modo oscuro, distritos y resiembra SQLite
├── widgets/                           # Tarjeta de producto con InkWell, banners y cabeceras
└── utils/validadores.dart             # Catálogo de validadores reutilizables
```

---

## 🚀 Ejecución y Pruebas

```powershell
# Obtener dependencias
flutter pub get

# Ejecutar pruebas (20/20 pasando)
flutter test

# Análisis estático (0 advertencias)
flutter analyze

# Iniciar aplicación en emulador o dispositivo
flutter run
```
