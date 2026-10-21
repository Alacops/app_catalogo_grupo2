# 🍫☕ Catálogo «Aroma Sagrado · Cusco»

Interfaz de usuario (UI) estática desarrollada en **Flutter** para un emprendimiento
local cusqueño de **café especial y cacao chuncho** de los valles de La Convención.

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

## 🎯 Alcance

Entrega **exclusivamente de UI estática** (`StatelessWidget`), sin lógica de negocio,
gestión de estado ni persistencia. Los datos provienen de una lista constante en memoria.

## ✨ Características de la interfaz

- **Cabecera institucional** con la ficha oficial del grupo.
- **Banner promocional** con `Stack` + `LinearGradient` para garantizar contraste.
- **Filtros por categoría** con `Wrap` + `FilterChip` (reflujo sin desbordamiento).
- **Rejilla adaptativa** con `LayoutBuilder` + `GridView.builder`:
  - 📱 `< 600 pt` → **2 columnas**
  - 📟 `600–839 pt` → **3 columnas**
  - 🖥️ `≥ 840 pt` → **4 columnas**
- **Carrusel horizontal** de recomendaciones con `ListView`.
- **Accesibilidad:** zonas táctiles de 48×48 dp, etiquetas semánticas y color con significado.

## 🗂️ Estructura

```
lib/
├── main.dart                     # MaterialApp + tema global
├── models/producto.dart          # Modelo inmutable
├── data/catalogo_data.dart       # Datos estáticos
├── screens/catalogo_screen.dart  # Pantalla principal
└── widgets/                      # Componentes reutilizables (DRY)
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
