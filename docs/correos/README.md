# Correos de ReParte

Firebase Authentication envía el correo para restablecer la contraseña (T37).
El diseño de ese correo vive en Firebase, no en la app. Aquí se guarda la
plantilla para no perderla y poder volver a pegarla.

## Cómo aplicar la plantilla

1. Entra a [Firebase Console](https://console.firebase.google.com/project/reparte-a3c07/authentication/emails)
   → **Authentication** → **Plantillas** → **Restablecimiento de contraseña** → ícono del lápiz.
2. Llena estos campos:
   - **Nombre del remitente:** `ReParte`
   - **Asunto:** `Restablece tu contraseña de ReParte`
   - **Mensaje:** el contenido de [`restablecer-contrasena.html`](restablecer-contrasena.html), sin el comentario del inicio.
3. Guarda.
4. Abajo de la lista de plantillas, en **Idioma de la plantilla**, elige **Español**.

Para probarla, usa "¿Olvidaste tu contraseña?" en la app con un correo real.

## Por qué puede llegar a spam

El correo sale de `noreply@reparte-a3c07.firebaseapp.com`, una dirección
compartida por muchos proyectos de Firebase. Gmail desconfía de ella, sobre
todo en proyectos nuevos. El nombre del remitente sí se puede cambiar
(arriba), pero **la dirección solo cambia con un dominio propio**:

1. Comprar un dominio (por ejemplo `reparte.com.mx`).
2. En **Plantillas** → **Personalizar dominio**, escribirlo y agregar en el
   proveedor del dominio los registros DNS que pide Firebase (verifican que el
   dominio es nuestro y autorizan a Firebase a enviar por él).
3. Cambiar el remitente a, por ejemplo, `noreply@reparte.com.mx`.

Con el dominio verificado los correos suelen llegar a la bandeja de entrada.
Mientras tanto, al marcar el correo como "No es spam" Gmail aprende a confiar
en él para esa cuenta.
