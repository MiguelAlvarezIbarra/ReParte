# ReParte

> La comida que sobra no se tira: se reparte.

Aplicación móvil que conecta a restaurantes y supermercados con
asociaciones que reparten alimentos, para reducir el desperdicio de
comida en buen estado.

## Estado del proyecto

**Sprint 1 — Base del proyecto (5 al 16 de octubre): terminado.**

Lo que ya funciona:

- Registro con correo y contraseña eligiendo el rol: **donante** o **asociación**.
- Inicio de sesión con validación de campos y mensajes de error en español.
- Cada rol llega a su pantalla principal: *Mis donaciones* (donante) o
  *Donaciones disponibles* (asociación).
- La sesión se mantiene al cerrar y abrir la app; botón para cerrar sesión.
- Base de datos en Cloud Firestore protegida con reglas de seguridad.

Siguiente: **Sprint 2 — Núcleo de donaciones** (publicar y listar donaciones, H2 y H3).

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
| Pruebas | `flutter_test`, `mockito`, `integration_test` |

Previsto para los siguientes sprints: Firebase Cloud Messaging (avisos) y
Google Maps (punto de entrega).

## Cómo ejecutarlo

Requisitos: Flutter instalado y un teléfono o emulador **Android 6.0 o superior**.

```bash
flutter pub get
flutter run
```

La app ya está conectada al proyecto de Firebase `reparte-a3c07`
(`android/app/google-services.json` y `lib/firebase_options.dart`).
La primera compilación tarda más porque descarga Gradle.

### Cuentas de prueba

| Rol | Correo | Contraseña |
|---|---|---|
| Donante | `prueba.donante@reparte.mx` | `reparte123` |
| Asociación | `prueba.asociacion@reparte.mx` | `reparte123` |

## Pruebas

```bash
flutter analyze                                # análisis estático
flutter test                                   # pruebas unitarias y de widgets
flutter test integration_test/auth_test.dart   # contra Firebase real, con un teléfono conectado
```

Estado actual en `main`: `flutter analyze` sin problemas y **44 pruebas aprobadas**.

| Carpeta | Qué prueba |
|---|---|
| `test/models/` | Conversión desde y hacia JSON de los modelos |
| `test/repositories/` | `UsuarioRepository` con servicios simulados (mockito) |
| `test/viewmodels/` | `LoginViewModel`: inicio de sesión, registro y sesión guardada |
| `test/views/` | Pantallas de acceso, validaciones y navegación por rol |
| `test/core/` | Validadores de correo y contraseña |
| `integration_test/` | Inicio de sesión real contra Firebase |

## Arquitectura

```text
Vista ──► ViewModel ──► Repositorio ──► Servicio ──► Firebase
```

Las dependencias van en una sola dirección: una vista conoce a su
ViewModel, el ViewModel a un repositorio y el repositorio a los
servicios. Nunca al revés. Solo los servicios usan el SDK de Firebase.

Patrones aplicados hasta ahora: **Repository**, **Inyección de dependencias**
(Provider), **Observer** (`ChangeNotifier`) y **Factory**
(`PantallaInicioFactory` elige la pantalla según el rol).

## Estructura del proyecto

```text
lib/
├── core/           Tema, constantes (colecciones) y validadores
├── models/         Usuario, Donacion y PuntoEntrega
├── services/       AuthService y FirestoreService: únicos que hablan con Firebase
├── repositories/   UsuarioRepository y DonacionRepository
├── viewmodels/     LoginViewModel, DonacionesViewModel y EstadoUI
├── views/
│   ├── auth/       Inicio de sesión y registro
│   ├── inicio/     Puerta de acceso y pantalla principal de cada rol
│   └── donaciones/ Lista de donaciones (Sprint 2)
├── widgets/        Componentes reutilizables
└── routes/         Nombres de las rutas de navegación
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
