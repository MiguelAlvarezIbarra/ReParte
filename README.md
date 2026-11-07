# ReParte

> La comida que sobra no se tira: se reparte.

Aplicación móvil que conecta a restaurantes y supermercados con
asociaciones que reparten alimentos, para reducir el desperdicio de
comida en buen estado.

## Estado del proyecto

| Sprint | Fechas | Estado |
|---|---|---|
| Sprint 1 — Base del proyecto | 5 al 16 de octubre | Terminado |
| Sprint 2 — Núcleo de donaciones | 19 al 30 de octubre | Terminado |
| Sprint 3 — Reserva y avisos | 2 al 13 de noviembre | En curso |

Lo que ya funciona:

- **Cuentas:** registro con correo y contraseña eligiendo el rol (**donante** o
  **asociación**), inicio de sesión, sesión que se mantiene y perfil.
- **Donante:** publica una donación con descripción, kilos, fecha de caducidad y
  punto de entrega elegido en el mapa; ve *Mis donaciones* con su estado
  (activas e historial).
- **Asociación:** ve las donaciones disponibles en tiempo real, las busca, las ve
  en un **mapa**, abre el detalle, la **reserva** y ve *Mis reservas*.
- **Cómo llegar:** abre la ruta al punto de entrega en la app de mapas del teléfono.
- Base de datos en Cloud Firestore protegida con reglas de seguridad.

Pendiente del Sprint 3: evitar la doble reserva (T20), avisar al donante con
notificaciones (T21), marcar como entregada (T23), manejo de errores y falta de
conexión (T24) y la prueba completa en un teléfono (T25).

## Equipo

| Integrante | Rol |
|---|---|
| Miguel Ángel Álvarez Ibarra | Product Owner |
| Pedro Uriel Pérez Monzón | Dev Team / Líder Técnico |
| Claudio Ángel Huerta Ducoing | Scrum Master |

## Tecnología

| Uso | Herramienta |
|---|---|
| App móvil | Flutter (Dart) con arquitectura MVVM |
| Estado e inyección de dependencias | `provider` |
| Autenticación | Firebase Authentication (`firebase_auth`) |
| Base de datos | Cloud Firestore (`cloud_firestore`) |
| Mapas | `flutter_map` con OpenStreetMap y `latlong2` (sin API key) |
| Ubicación | `geolocator` y `geocoding` |
| Abrir la ruta en la app de mapas | `url_launcher` |
| Tipografía | Poppins (incluida en `assets/fonts`, licencia OFL) |
| Pruebas | `flutter_test`, `mockito`, `integration_test` |

Previsto: Firebase Cloud Messaging para los avisos al donante (T21).

## Cómo ejecutarlo

Requisitos: **Flutter 3.47 estable o superior** y un teléfono o emulador **Android 7.0 o superior**.

```bash
flutter pub get
flutter run
```

La app ya está conectada al proyecto de Firebase `reparte-a3c07`
(`android/app/google-services.json` y `lib/firebase_options.dart`).
La primera compilación tarda bastante porque descarga Gradle 8.14 y el NDK de Android.

### Cuentas de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Donante | `prueba.donante@reparte.mx` | `reparte123` |
| Asociación | `prueba.asociacion@reparte.mx` | `reparte123` |

## Pruebas

```bash
flutter analyze                 # análisis estático
flutter test                    # pruebas unitarias y de widgets
flutter test integration_test   # contra Firebase real, con un teléfono conectado
```

Estado actual en `main`: `flutter analyze` sin problemas, **162 pruebas
aprobadas** y 4 pruebas de integración aprobadas en un Samsung A51
(inicio de sesión, credenciales incorrectas, publicar y reservar).

Ojo: `flutter test integration_test` reemplaza el APK de depuración por uno de
prueba. Para probar la app a mano después, usa `flutter run`.

| Carpeta | Qué prueba |
|---|---|
| `test/models/` | Conversión desde y hacia JSON y validaciones de los modelos |
| `test/repositories/` | Repositorios con Firestore simulado (mockito): guardar, consultar, reservar y fallas |
| `test/viewmodels/` | Inicio de sesión, lista y búsqueda, detalle y reserva, publicar, mapa y *Mis donaciones* |
| `test/views/` | Pantallas: acceso, navegación por rol, barra inferior, lista, detalle, reservar y publicar |
| `test/services/` | Servicio de ubicación |
| `test/core/` | Validadores y formatos |
| `integration_test/` | Inicio de sesión, publicar y reservar contra Firebase real |

## Arquitectura

```text
Vista ──► ViewModel ──► Repositorio ──► Servicio ──► Firebase
```

Las dependencias van en una sola dirección: una vista conoce a su
ViewModel, el ViewModel a un repositorio y el repositorio a los
servicios. Nunca al revés. Solo los servicios usan el SDK de Firebase.

Patrones aplicados: **Repository**, **Inyección de dependencias** (Provider),
**Observer** (`ChangeNotifier` y los streams de Firestore en tiempo real) y
**Factory** (`PantallaInicioFactory` elige la pantalla según el rol).

## Estructura del proyecto

```text
lib/
├── core/           Tema (colores y tipografía), constantes y utilidades
├── models/         Usuario, Donacion y PuntoEntrega
├── services/       Auth, Firestore, ubicación y navegación: los únicos que hablan con el exterior
├── repositories/   UsuarioRepository y DonacionRepository
├── viewmodels/     Lógica y estado de cada pantalla
├── views/
│   ├── auth/       Inicio de sesión y registro
│   ├── inicio/     Puerta de acceso e inicio de cada rol con su barra inferior
│   ├── donaciones/ Lista, detalle, publicar, reserva confirmada y mis donaciones
│   ├── mapa/       Elegir ubicación y mapa de donaciones
│   └── perfil/     Datos de la cuenta
├── widgets/        Componentes reutilizables (tarjetas, etiquetas, encabezados)
└── routes/         Nombres de las rutas de navegación
assets/fonts/       Tipografía Poppins
firestore.rules     Reglas de seguridad de Firestore
```

## Flujo de trabajo

- Una tarea del tablero equivale a una rama y a un Pull Request.
- Ramas con el formato `tipo/descripcion`, por ejemplo `feature/T08-autenticacion`
  o `docs/readme-sprint-1`. Tipos: `feature`, `fix`, `docs` y `revert`.
- Commits con el mismo tipo al inicio: `feature: agrega la seleccion de rol en el registro`.
- Las ramas salen de `develop` y regresan ahí mediante PR, aprobado por un
  integrante distinto al autor.
- `main` solo recibe versiones estables, al terminar una funcionalidad principal.

## Enlaces

- Tablero: [GitHub Projects — @ReparTe Kanban](https://github.com/users/MiguelAlvarezIbarra/projects/1)
- Repositorio: [MiguelAlvarezIbarra/ReParte](https://github.com/MiguelAlvarezIbarra/ReParte)
