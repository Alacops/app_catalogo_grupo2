# 🍫☕ Catálogo «Aroma Sagrado · Cusco»

Aplicación en **Flutter** para un emprendimiento local cusqueño de **café especial
y cacao chuncho** de los valles de La Convención. Evolucionó de una UI estática
(Unidad I) a una app con **estado, persistencia y formularios** (Unidad II).

**Proyecto Integrador 02 — Desarrollo de Software II (IF616BIN)**
Universidad Nacional de San Antonio Abad del Cusco · Escuela Profesional de Ingeniería Informática y de Sistemas · Semestre 2026-II

---

## 👥 Grupo 2

| Integrante | Código |
|---|---|
| Edmil Jampier Saire Bustamante | 174449 |
| Alain Armando Condori Contreras | 021501 |
| Axel Aranibar Rojas | 220547 |

**Docente:** Mtro. Ing. Yover Collantes Valer

---

## 🧩 Unidad II — Estado, Persistencia y Formularios

- **Manejo de estado** con `provider` + `ChangeNotifier`:
  - `FavoritosProvider` — marcar/desmarcar favoritos.
  - `CarritoProvider` — carrito con cantidades, subtotales y total.
  - **Estado local** (`setState`) para la búsqueda y el filtro por categoría.
- **Persistencia** con `shared_preferences`: favoritos y carrito **sobreviven al cierre**
  de la app (ids como `StringList`; carrito serializado a JSON).
- **Formularios** con `Form` + `GlobalKey<FormState>`: checkout con `TextFormField`,
  `DropdownButtonFormField`, `inputFormatters` y validaciones (nombre, celular 9 dígitos,
  correo, dirección, términos).
- **Navegación** con `BottomNavigationBar` + `IndexedStack` y `Badge` en favoritos/carrito.

## ✨ Funcionalidades

- **Catálogo** con buscador y filtros por categoría funcionales.
- **Ofertas**, **Favoritos** y **Carrito** como pantallas dedicadas (con estados vacíos).
- **Checkout** con validación y confirmación de pedido (vacía el carrito al confirmar).
- Base de UI de la Unidad I: cabecera institucional, banner (`Stack` + `LinearGradient`),
  rejilla **adaptativa** (`LayoutBuilder` → 2/3/4 columnas), accesibilidad 48×48 dp.

## 🗂️ Estructura

```
lib/
├── main.dart                      # MultiProvider + MaterialApp + tema
├── models/
│   ├── producto.dart              # Modelo + toJson/fromJson
│   └── item_carrito.dart          # Línea de carrito (producto + cantidad)
├── data/catalogo_data.dart        # Datos + búsqueda por id
├── providers/
│   ├── favoritos_provider.dart    # Estado + persistencia de favoritos
│   └── carrito_provider.dart      # Estado + persistencia del carrito
├── screens/
│   ├── main_screen.dart           # Navegación inferior (IndexedStack)
│   ├── catalogo_screen.dart       # Búsqueda + filtros (setState)
│   ├── ofertas_screen.dart
│   ├── favoritos_screen.dart
│   ├── carrito_screen.dart        # Cantidades, total y checkout
│   └── checkout_screen.dart       # Formulario con validación
└── widgets/                       # Componentes reutilizables (DRY)
```

## ▶️ Cómo ejecutar

```bash
flutter pub get
flutter run -d chrome      # Web
# o
flutter run                # Dispositivo/emulador
```

## 📸 Generar capturas de evidencia

```bash
flutter test test/screenshot_generator_test.dart
```

Las imágenes se guardan en `informe/capturas/`.

## 📄 Documentación

El informe técnico completo (UI/UX) está en
[`informe/Informe_Tecnico_UI_Grupo2_IF616BIN.html`](informe/Informe_Tecnico_UI_Grupo2_IF616BIN.html).

---

> Paleta institucional: granate `#7A1F2B` · dorado `#C9971F` · marrón `#3E2723`
