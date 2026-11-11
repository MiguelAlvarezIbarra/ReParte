# Pruebas de seguridad y de integración

**Resultado: todas pasaron.** Se ejecutaron el 10 de noviembre de 2026 contra el
proyecto real de Firebase (`reparte-a3c07`) en un Redmi Note 13 Pro con
Android 16. Antes se habían corrido en un Samsung Galaxy A51 con Android 13.

| Conjunto | Dónde | Resultado |
|---|---|---|
| Pruebas de integración (Firebase real) | `integration_test/`, en un teléfono | **10 de 10** aprobadas (5 min 14 s) |
| Pruebas unitarias y de pantallas | `test/` | **201** aprobadas |
| Análisis estático | `flutter analyze` | Sin problemas |
| GitHub Actions | [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) | Aprobado en cada PR (análisis y pruebas) |

Las cuentas de prueba no aparecen en este documento ni en el código: se leen de
`pruebas.env.json`, un archivo local fuera del repositorio.

## Cómo ejecutarlas

```bash
flutter analyze
flutter test
# con un teléfono Android conectado y el archivo pruebas.env.json:
flutter test integration_test --dart-define-from-file=pruebas.env.json
# solo las de seguridad:
flutter test integration_test/reglas_seguridad_test.dart --dart-define-from-file=pruebas.env.json
```

## 1. Autorización en el servidor (reglas de Firestore)

[`integration_test/reglas_seguridad_test.dart`](../../integration_test/reglas_seguridad_test.dart)
escribe **directo en Firestore**, sin pasar por la app, como lo haría alguien
que intenta saltarse los controles. Usa tres conexiones a la vez: una sin
sesión, una del donante y una de la asociación. Cada intento debe recibir
`permission-denied`.

| # | Intento | Esperado | Resultado |
|---|---|---|---|
| 1 | Sin sesión: leer las donaciones | Rechazado | ✅ Rechazado |
| 2 | Sin sesión: leer el perfil de un usuario | Rechazado | ✅ Rechazado |
| 3 | Sin sesión: leer los puntos de entrega | Rechazado | ✅ Rechazado |
| 4 | Sin sesión: publicar una donación | Rechazado | ✅ Rechazado |
| 5 | El donante se cambia el rol a asociación | Rechazado | ✅ Rechazado |
| 6 | La asociación se cambia el rol a donante | Rechazado | ✅ Rechazado |
| 7 | Una asociación publica una donación | Rechazado | ✅ Rechazado |
| 8 | El donante publica a nombre de otro usuario | Rechazado | ✅ Rechazado |
| 9 | Publicar una donación ya "entregada" | Rechazado | ✅ Rechazado |
| 10 | Publicar con −3 kg | Rechazado | ✅ Rechazado |
| 11 | Publicar con 0 kg | Rechazado | ✅ Rechazado |
| 12 | El donante reserva una donación | Rechazado | ✅ Rechazado |
| 13 | La asociación reserva a nombre de otra asociación | Rechazado | ✅ Rechazado |
| 14 | La asociación reserva y de paso cambia los kilos | Rechazado | ✅ Rechazado |
| 15 | La asociación reserva correctamente | Permitido | ✅ Permitido |
| 16 | El donante le quita la reserva | Rechazado | ✅ Rechazado |
| 17 | El donante cambia la asociación que reservó | Rechazado | ✅ Rechazado |
| 18 | El donante cancela una donación ya reservada | Rechazado | ✅ Rechazado |
| 19 | La asociación la marca como entregada | Permitido | ✅ Permitido |
| 20 | Modificar una donación ya entregada | Rechazado | ✅ Rechazado |
| 21 | Borrar una donación ya entregada | Rechazado | ✅ Rechazado |
| 22 | El donante corrige la descripción de su donación disponible | Permitido | ✅ Permitido |
| 23 | El donante cancela su donación disponible | Permitido | ✅ Permitido |

Antes de los intentos, la prueba revisa con una escritura inofensiva que las
reglas estén publicadas. Si no lo están, se detiene sin tocar los datos.

## 2. Autenticación

| Caso | Prueba | Resultado |
|---|---|---|
| Un usuario válido entra y la app reconoce su rol | `integration_test/auth_test.dart` | ✅ |
| Con credenciales incorrectas se muestra "Correo o contraseña incorrectos", sin detalles internos | `integration_test/auth_test.dart` | ✅ |
| Los códigos de error de Firebase se traducen a mensajes generales | `test/repositories/usuario_repository_test.dart` (`mensajeDeError`) | ✅ |
| Recuperar contraseña: un correo inválido no llega a Firebase, los errores se muestran claros y la respuesta es la misma exista o no la cuenta | `test/viewmodels/recuperar_contrasena_viewmodel_test.dart`, `test/views/login_view_test.dart` | ✅ |
| Sin sesión la app solo muestra el inicio de sesión | `test/views/puerta_acceso_test.dart` | ✅ |

## 3. Entradas inválidas y errores

| Caso | Prueba | Resultado |
|---|---|---|
| Correo con formato inválido, contraseña vacía o corta | `test/core/`, `test/views/login_view_test.dart`, `test/views/registro_view_test.dart` | ✅ |
| Kilos vacíos, no numéricos, en cero o negativos; caducidad en el pasado | `test/core/validadores_donacion_test.dart`, `test/views/publicar_donacion_view_test.dart` | ✅ |
| Si Firestore falla al guardar, se muestra el error y no se pierde lo escrito | `test/views/publicar_donacion_view_test.dart`, `test/repositories/` | ✅ |
| Sin conexión: aviso en pantalla y botón "Intentar de nuevo" | `test/views/errores_sin_conexion_test.dart` | ✅ |
| Si no se puede calcular la ruta (OSRM) se muestra un mensaje claro | `test/services/rutas_service_test.dart` | ✅ |

## 4. Funcionamiento de la integración

| Caso | Prueba | Resultado |
|---|---|---|
| Publicar una donación y leerla de Firestore | `integration_test/donaciones_test.dart` | ✅ |
| Reservar; un segundo intento de reserva es rechazado; marcar como entregada | `integration_test/donaciones_test.dart` | ✅ |
| Flujo completo H1 a H6 usando la app como una persona, incluida la notificación al donante | `integration_test/flujo_completo_test.dart` ([evidencia con capturas](flujo-completo.md)) | ✅ |

## Datos usados

- Cuentas de prueba ficticias, creadas solo para estas pruebas. Su contraseña
  no está en el repositorio.
- Donaciones con una marca de prueba (por ejemplo `T25-97711` o
  `[prueba de reglas T36]`). Al terminar quedan entregadas o canceladas, así que
  no aparecen como disponibles para nadie.
- Las capturas de [flujo-completo.md](flujo-completo.md) muestran solo las
  cuentas ficticias.
