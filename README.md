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
| Sprint 3 — Reserva y avisos | 2 al 13 de noviembre | Terminado |
| Cierre y demostración | 16 al 20 de noviembre | En curso |

Lo que ya funciona:

- **Cuentas:** registro con correo y contraseña eligiendo el rol (**donante** o
  **asociación**), inicio de sesión, sesión que se mantiene, perfil y
  **recuperar la contraseña** por correo.
- **Donante:** publica una donación con descripción, kilos, fecha de caducidad y
  punto de entrega elegido en el mapa; ve *Mis donaciones* con su estado
  (activas e historial).
- **Asociación:** ve las donaciones disponibles en tiempo real, las busca, las ve
  en un **mapa**, abre el detalle, la **reserva** y ve *Mis reservas*.
- **Una sola reserva:** si dos asociaciones reservan la misma donación al mismo
  tiempo, solo una lo logra y la otra recibe el aviso de que ya no está disponible.
- **Aviso al donante:** le llega una notificación al teléfono cuando una
  asociación reserva su donación, con quién la reservó, qué y cuántos kilos.
- **Entrega:** el donante o la asociación marcan la donación como entregada y
  queda cerrada con su fecha y los kilos rescatados.
- **Cómo llegar:** muestra la ruta al punto de entrega dentro del mapa de la app
  (distancia y tiempo) o la abre en la app de mapas del teléfono.
- **Sin conexión:** avisa cuando el teléfono se queda sin red, muestra lo último
  guardado y permite reintentar cuando algo no carga.
- **Logo de ReParte** en el ícono de la app, la pantalla de carga, el inicio de
  sesión y las notificaciones.
- **Seguridad:** las reglas de Cloud Firestore exigen sesión, no dejan cambiar el
  rol, permiten publicar solo a donantes y reservar solo a asociaciones, validan
  los datos y protegen el ciclo de la donación (disponible → reservada → entregada).

Con esto queda completo el ciclo de una donación (historias H1 a H6), probado de
principio a fin en un teléfono real: ver [la prueba del flujo completo](docs/pruebas/flujo-completo.md).

Pendiente: foto de la donación al publicar (T34) y guardarla en la nube (T35),
corregir lo detectado en las pruebas (T26), APK de release (T27), guion de la
demostración (T28) y README con capturas (T29).

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
| Ruta dentro de la app | Servidor público de OSRM con `http` (sin API key) |
| Abrir la ruta en la app de mapas | `url_launcher` |
| Notificaciones | `flutter_local_notifications` |
| Detectar falta de conexión | `connectivity_plus` |
| Tipografía | Poppins (incluida en `assets/fonts`, licencia OFL) |
| Pruebas | `flutter_test`, `mockito`, `integration_test` |

Los avisos al donante se muestran con notificaciones del teléfono mientras la app
está abierta o en segundo plano. Para avisar con la app totalmente cerrada haría
falta Cloud Functions con Firebase Cloud Messaging, que requiere el plan Blaze.

## Cómo ejecutarlo

Requisitos: **Flutter 3.47 estable o superior** y un teléfono o emulador **Android 7.0 o superior**.

```bash
flutter pub get
flutter run
```

La app ya está conectada al proyecto de Firebase `reparte-a3c07`
(`android/app/google-services.json` y `lib/firebase_options.dart`).
La primera compilación tarda bastante porque descarga Gradle 8.14 y el NDK de Android.

Las reglas de seguridad están en `firestore.rules`. Si se cambian, se publican con
`firebase deploy --only firestore:rules --project reparte-a3c07`. El diseño del
correo de recuperación de contraseña se configura en Firebase Console: los pasos
están en [docs/correos](docs/correos/README.md).

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

# flujo completo H1 a H6 en el teléfono, guardando capturas en docs/pruebas/capturas
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/flujo_completo_test.dart
```

Estado actual en `main`: `flutter analyze` sin problemas, **201 pruebas
aprobadas** y **9 pruebas de integración** aprobadas en un Samsung A51 con
Android 13 (y en un Redmi Note 13 Pro con Android 16). Entre ellas están el
**flujo completo de las seis historias**, con 13 capturas como evidencia en
[docs/pruebas/flujo-completo.md](docs/pruebas/flujo-completo.md), y la **prueba
de seguridad**, que intenta escribir en Firestore lo que no se debe (cambiarse el
rol, publicar con 0 kilos, reservar siendo donante…) y comprueba que se rechace.

Ojo: `flutter test integration_test` reemplaza el APK de depuración por uno de
prueba. Para probar la app a mano después, usa `flutter run`.

| Carpeta | Qué prueba |
|---|---|
| `test/models/` | Conversión desde y hacia JSON y validaciones de los modelos |
| `test/repositories/` | Repositorios con Firestore simulado (mockito): guardar, consultar, reservar, doble reserva, entregar y fallas |
| `test/viewmodels/` | Inicio de sesión, recuperar contraseña, lista y búsqueda, detalle, reserva y entrega, publicar, mapa, ruta, *Mis donaciones* y avisos de reserva |
| `test/views/` | Pantallas: acceso, recuperar contraseña, logo, navegación por rol, barra inferior, lista, detalle, reservar, entregar, publicar, errores y sin conexión |
| `test/services/` | Ubicación y cálculo de la ruta |
| `test/core/` | Validadores y formatos |
| `integration_test/` | Contra Firebase real: inicio de sesión, publicar, reservar, doble reserva, entregar, el flujo completo H1 a H6 y las reglas de seguridad |

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
├── services/       Auth, Firestore, ubicación, rutas, notificaciones y conexión: los únicos que hablan con el exterior
├── repositories/   UsuarioRepository y DonacionRepository
├── viewmodels/     Lógica y estado de cada pantalla
├── views/
│   ├── auth/       Inicio de sesión y registro
│   ├── inicio/     Puerta de acceso e inicio de cada rol con su barra inferior
│   ├── donaciones/ Lista, detalle, publicar, reserva confirmada y mis donaciones
│   ├── mapa/       Elegir ubicación, mapa de donaciones y ruta al punto de entrega
│   └── perfil/     Datos de la cuenta
├── widgets/        Componentes reutilizables (tarjetas, etiquetas, encabezados)
└── routes/         Nombres de las rutas de navegación
assets/fonts/       Tipografía Poppins
docs/pruebas/       Resultados y capturas de la prueba del flujo completo
docs/correos/       Plantilla del correo para recuperar la contraseña
integration_test/   Pruebas contra Firebase real en un teléfono
test_driver/        Guarda las capturas de las pruebas en el teléfono
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
