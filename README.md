<div align="center">
  <img src="assets/icon.png" width="160" alt="Juegos Kids" />

  # Juegos Kids

  **Juegos educativos para niños de 3 a 7 años**

  Matemáticas · Lectura · Lógica · Memoria · Música · Arte

  <p>
    <img src="assets/fluent/1f522.svg" width="56" alt="Números" />
    <img src="assets/fluent/1f4da.svg" width="56" alt="Letras" />
    <img src="assets/fluent/1f9e0.svg" width="56" alt="Memoria" />
    <img src="assets/fluent/1f9e9.svg" width="56" alt="Lógica" />
    <img src="assets/fluent/1f3a8.svg" width="56" alt="Pintar" />
    <img src="assets/fluent/1f3b5.svg" width="56" alt="Música" />
    <img src="assets/fluent/2b50.svg" width="56" alt="Estrellas" />
  </p>
</div>

---

## Características

- **15 juegos** organizados en *Aprende*, *Juega y aprende* y *Crea*.
- **Perfiles infantiles** con avatar, edad y dificultad que se adapta automáticamente.
- **Zona padres** protegida con PIN: estadísticas por categoría, calendario de días jugados, meta diaria y límite de tiempo opcional.
- **Multijugador local** por turnos (Matías ↔ Michelle).
- **Tres estilos de iconos** intercambiables: Fluent (Microsoft), Twemoji y OpenMoji.
- **Voz personalizable**: grabá tu propia voz desde la app para reemplazar las instrucciones y celebraciones.
- **Audio**: sonidos pregrabados con fallback a TTS (`es-MX`).
- **Logros y tienda** de recompensas con puntos canjeables.

## Catálogo de juegos

### Aprende

| Juego | Descripción |
|---|---|
| ¿Dónde está? | Encuentra el objeto que se nombra entre varios. |
| Letras | Toca una letra para escucharla junto a una palabra ejemplo. |
| Números | Toca un número del 1 al 10 para escucharlo. |
| Colores | Identifica y escucha los colores básicos. |
| Formas | Reconoce círculo, cuadrado, triángulo y más. |
| Animales | Toca un animal para escuchar su nombre y sonido. |
| Trazar | Practica el trazo de letras con el dedo. |

### Juega y aprende

| Juego | Descripción |
|---|---|
| Contar | Cuenta objetos y elige el número correcto. |
| Sumar | Resuelve sumas con apoyo visual. |
| Parejas | Encuentra parejas iguales (memoria). |
| Lógica | Completa secuencias y patrones. |
| Sombras | Empareja la imagen con su sombra. |
| Clasificar | Agrupa objetos por categoría. |
| Letras Q. | Arrastra la letra inicial correcta a la imagen. |
| **Leer** *(nuevo)* | Lee la palabra que corresponde al dibujo. |

### Crea

| Juego | Descripción |
|---|---|
| Pintar | Pinta libremente con paleta de colores. |

## Estilos de icono

<table>
<tr>
<td align="center" width="180">
  <img src="assets/fluent/1f98a.svg" width="80" /><br/>
  <b>Fluent</b><br/>Moderno (Microsoft)
</td>
<td align="center" width="180">
  <img src="assets/twemoji/1f98a.svg" width="80" /><br/>
  <b>Twemoji</b><br/>Colorido
</td>
<td align="center" width="180">
  <img src="assets/openmoji/1F98A.svg" width="80" /><br/>
  <b>OpenMoji</b><br/>Plano
</td>
</tr>
</table>

Cambiá entre ellos desde **Zona padres → Estilo de iconos**.

## Stack técnico

- **Flutter** SDK `^3.11.5`
- `flutter_svg` — renderizado de iconos SVG
- `audioplayers` + `flutter_tts` — audio pregrabado con fallback a TTS
- `shared_preferences` — persistencia local de perfiles y progreso
- `record` + `permission_handler` — grabación de voz personalizada
- `flutter_launcher_icons` + `flutter_native_splash` — branding nativo

## Cómo compilar

```bash
flutter pub get
flutter run                    # desarrollo (USB / emulador)
flutter build apk --release    # APK de producción
```

El APK release se genera en:

```
build/app/outputs/flutter-apk/app-release.apk
```

## Estructura del proyecto

```
lib/
├── main.dart
├── theme.dart
├── screens/
│   ├── home_screen.dart            # selector de juegos
│   ├── zona_infantil_screen.dart   # selector de perfiles
│   ├── zona_padres_screen.dart     # estadísticas + ajustes
│   ├── grabaciones_screen.dart     # grabar voz propia
│   ├── logros_screen.dart
│   ├── tienda_screen.dart
│   └── games/                      # los 15 juegos
├── state/
│   ├── perfiles_service.dart       # perfiles + estilo iconos
│   ├── audio_service.dart          # audio + TTS fallback
│   ├── grabaciones_service.dart    # grabaciones del usuario
│   ├── dificultad.dart             # ajuste por edad
│   ├── jugadores.dart              # multijugador local
│   └── logros.dart
└── widgets/
    ├── juego_layout.dart           # marco común de cada juego
    ├── icon_kid.dart               # renderiza emoji según estilo
    ├── confeti.dart
    └── ...
assets/
├── audio/         # sonidos pregrabados (mp3)
├── fluent/        # iconos Microsoft Fluent (Color)
├── twemoji/       # iconos Twemoji
├── openmoji/      # iconos OpenMoji
└── fonts/         # Fredoka
```

## Licencias de assets

- **Fluent Emoji** — MIT · [github.com/microsoft/fluentui-emoji](https://github.com/microsoft/fluentui-emoji)
- **Twemoji** — CC-BY 4.0 · Twitter / X
- **OpenMoji** — CC BY-SA 4.0 · [openmoji.org](https://openmoji.org)
- **Fredoka** (fuente) — SIL Open Font License 1.1
