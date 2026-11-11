# Política de seguridad

## Versión que se mantiene

| Rama | Se atiende |
|---|---|
| `main` (versión estable) | Sí |
| `develop` y ramas `feature/*` | Solo durante el desarrollo |

## Cómo reportar un problema de seguridad

Si encuentras una vulnerabilidad o una posible credencial expuesta:

1. **No abras un issue público** ni la publiques en comentarios o pull requests.
2. Repórtala en privado desde la pestaña **Security → Report a vulnerability**
   de este repositorio, o con un mensaje privado al equipo.
3. Indica el archivo, la sección o el commit y cómo reproducir el problema.
   **No copies el valor de una clave, contraseña o token**; basta con su
   ubicación.
4. No pruebes ni reutilices credenciales que encuentres.

El equipo responde en un máximo de 3 días hábiles. Si se confirma una
credencial expuesta, se cambia de inmediato para que la del historial deje de
servir.

## Más información

Los controles de seguridad de la app, el manejo de secretos y las
dependencias están en [docs/SEGURIDAD.md](docs/SEGURIDAD.md). Las pruebas de
seguridad y sus resultados están en
[docs/pruebas/seguridad.md](docs/pruebas/seguridad.md).
