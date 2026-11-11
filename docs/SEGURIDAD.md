# Seguridad de ReParte

Este documento reúne los controles de seguridad de la app y dónde se pueden
verificar en el repositorio. Las pruebas que los comprueban y sus resultados
están en [pruebas/seguridad.md](pruebas/seguridad.md).

## 1. Secretos y credenciales

| Valor | ¿Es secreto? | Dónde está | Cómo se protege |
|---|---|---|---|
| Configuración de Firebase (`apiKey`, `appId`, `projectId`, `messagingSenderId`) | **No.** Firebase lo diseña como identificadores públicos que viajan dentro de la app | `android/app/google-services.json`, `lib/firebase_options.dart` | El acceso a los datos lo controlan las **reglas de Firestore** y **Firebase Authentication**, no la clave. Ver la sección 3 |
| Contraseña de las cuentas de prueba | **Sí** | Solo en `pruebas.env.json`, en la computadora de cada integrante | Archivo ignorado por git. En el repositorio solo está [`pruebas.env.example.json`](../pruebas.env.example.json) con valores ficticios. La contraseña se comparte por un canal privado del equipo |
| Contraseñas de los usuarios | **Sí** | En ningún lado de la app | Se envían por HTTPS a Firebase Authentication, que las guarda cifradas. La app nunca las guarda ni las escribe en registros |
| Llave para firmar el APK de release | **Sí** | `key.properties` y `*.jks` locales | Ignorados por git (`.gitignore` y `android/.gitignore`) |
| Sesión de Firebase CLI (para publicar reglas) | **Sí** | Perfil del usuario en su computadora | Nunca dentro del proyecto |

La app **no tiene servidor propio ni claves privadas de API**: no hay valores
que deban ir en variables de entorno para ejecutarla.

**Revisión del historial (10 nov 2026):** no se encontraron claves privadas,
tokens ni correos personales. La contraseña anterior de las cuentas de prueba
aparecía en archivos de prueba y en el README; se sacó del repositorio y **se
cambió** (la del historial ya no funciona).

## 2. `.gitignore` y archivos locales

Además de lo que Flutter genera (`build/`, `.dart_tool/`), se excluyen:
`.env`, `.env.*`, `pruebas.env.json`, `*.keystore`, `*.jks`, `key.properties`,
cuentas de servicio (`service-account*.json`) y los registros de Firebase
(`firebase-debug.log`, `firestore-debug.log`). Ver [`.gitignore`](../.gitignore).

## 3. Controles en el código y en la nube

| Control | Cómo se cumple | Dónde verificarlo |
|---|---|---|
| **Autenticación** | Correo y contraseña con Firebase Authentication. Sin sesión, la app solo muestra el inicio de sesión. Se puede recuperar la contraseña por correo | `lib/services/auth_service.dart`, `lib/views/inicio/puerta_acceso.dart` |
| **Autorización** | Reglas de Firestore en el servidor: cada colección exige sesión; cada quien edita solo lo suyo; el rol no se puede cambiar; solo un donante publica y solo una asociación reserva; entregar solo lo hacen el donante o la asociación que reservó | [`firestore.rules`](../firestore.rules) |
| **Validación de datos en el servidor** | Al publicar: estado `disponible`, sin asociación, kilos mayores a 0, descripción no vacía. Reservar y entregar solo pueden cambiar sus propios campos. Una donación entregada o cancelada ya no se modifica | `firestore.rules` (`publicacionValida`, `reservaValida`, `entregaValida`, `edicionDelDonante`) |
| **Validación en la app** | Formularios con validadores (correo, contraseña, kilos, fecha) antes de enviar nada | `lib/core/utilidades/validadores.dart` |
| **Una sola reserva** | La reserva se hace en una transacción de Firestore y además lo exige la regla | `lib/repositories/donacion_repository.dart` (`reservar`), `firestore.rules` |
| **Comunicación segura** | Todo viaja por HTTPS: Firebase usa TLS, y las demás URL se arman con `Uri.https` (OSRM, Google Maps) o son `https://` (mapas de OpenStreetMap). Android bloquea el tráfico sin cifrar porque la app apunta a una versión reciente del sistema (`targetSdk`) | `lib/services/rutas_service.dart`, `lib/services/navegacion_service.dart`, `lib/views/mapa/` |
| **Permisos mínimos (Android)** | Internet; ubicación (se pide solo cuando el usuario toca "Mi ubicación" o "Ver ruta"); notificaciones (se pide al entrar como donante). Nada más | `android/app/src/main/AndroidManifest.xml`, `lib/services/ubicacion_service.dart` |
| **Permisos mínimos (nube)** | Cualquier colección no listada en las reglas queda cerrada (`allow read, write: if false`). No se pueden borrar perfiles. GitHub Actions corre con permiso de solo lectura | `firestore.rules`, `.github/workflows/ci.yml` |
| **Errores sin datos sensibles** | Los errores de Firebase se traducen a mensajes generales en español ("Correo o contraseña incorrectos", "Sin conexión a internet"); no se muestran trazas ni códigos internos. Para no revelar qué correos están registrados, recuperar contraseña siempre responde lo mismo | `AuthService.mensajeDeError`, `lib/widgets/estado_error.dart`, `lib/views/auth/recuperar_contrasena_view.dart` |
| **Sin registros con datos personales** | La app no escribe correos, contraseñas ni tokens en la consola | Búsqueda de `print(` en `lib/`: sin resultados |

### Lectura de perfiles

Cualquier usuario con sesión puede leer el perfil de otro (nombre, correo,
rol y teléfono). Es necesario para el servicio: la asociación necesita el
contacto del donante para recoger la comida, y el donante ve qué asociación
reservó. Sin sesión no se puede leer ningún perfil.

### Pendiente recomendado

- **Restringir la clave de Firebase** en Google Cloud Console (APIs y servicios
  → Credenciales) para que solo la acepten la app Android `com.reparte.reparte`
  y las API que usa (Identity Toolkit, Cloud Firestore, Token Service).
- **Firebase App Check**, para que solo la app oficial pueda llamar a Firebase.

## 4. Dependencias y vulnerabilidades

- Las dependencias están en [`pubspec.yaml`](../pubspec.yaml), con las
  versiones exactas fijadas en `pubspec.lock`. Se instalan con
  `flutter pub get`.
- **Revisión del 10 nov 2026:** `flutter pub outdated` y `flutter pub upgrade`
  no reportaron avisos de seguridad. Se aplicaron todas las actualizaciones
  compatibles (por ejemplo `cloud_firestore` 6.3 → 6.10, `firebase_auth`
  6.4 → 6.7, `firebase_core` 4.7 → 4.15, `flutter_local_notifications`
  22.0 → 22.3). Después se volvieron a correr todas las pruebas.
- **Versiones mayores que no se aplicaron, y por qué:**
  - `flutter_local_notifications` 23 exige compilar con Android SDK 37, que
    todavía no soporta nuestra versión de Gradle (AGP 8.11).
  - Firebase 7 (`cloud_firestore`, `firebase_auth`) y `firebase_core` 5 traen
    cambios incompatibles. No se cambian a días de la entrega; Dependabot
    avisará si alguna versión de las que usamos tiene un problema de seguridad.
- **Dependabot** ([`.github/dependabot.yml`](../.github/dependabot.yml)) revisa
  cada semana los paquetes de Dart, Gradle y GitHub Actions.
- En GitHub están activados **Dependabot alerts**, **Dependabot security
  updates**, **Secret scanning** y **Push protection** (Settings → Advanced
  Security). Al 10 nov 2026 hay **0 alertas de Dependabot abiertas**.
- **GitHub Actions** ([`.github/workflows/ci.yml`](../.github/workflows/ci.yml))
  corre `flutter analyze`, `flutter test` y `flutter pub outdated` en cada PR
  hacia `develop` y `main`.

## 5. Si se encuentra una credencial

1. No copiarla ni probarla.
2. Avisar en privado al equipo y al docente con el archivo y el commit, sin el valor.
3. Cambiar la credencial de inmediato (la del historial deja de servir).
4. Sacarla del repositorio y mover el valor a un archivo local ignorado por git.
