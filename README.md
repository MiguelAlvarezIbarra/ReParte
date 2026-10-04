# ReParte

Aplicación móvil que conecta a restaurantes y supermercados con
asociaciones que reparten alimentos, para reducir el desperdicio de
comida en buen estado.

## Equipo

| Integrante | Rol |
|---|---|
| Miguel Ángel Álvarez Ibarra | Product Owner |
| Pedro Uriel Pérez Monzón | Dev Team / Líder Técnico |
| Claudio Ángel Huerta Ducoing | Scrum Master |

## Tecnología

Flutter con arquitectura MVVM e integración con Firebase
(Authentication, Cloud Firestore y Cloud Messaging).

## Estructura del proyecto

lib/
├── core/ Tema, constantes y utilidades compartidas
├── models/ Clases de datos (Donacion, Usuario)
├── services/ Única capa que habla con Firebase, Maps o APIs
├── repositories/ Fuente única de verdad de cada tipo de dato
├── viewmodels/ Lógica y estado de cada pantalla
├── views/ Pantallas, agrupadas por módulo
├── widgets/ Componentes reutilizables
└── routes/ Nombres de las rutas de navegación


Las dependencias van en una sola dirección: una vista conoce a su
ViewModel, el ViewModel a un repositorio y el repositorio a los
servicios. Nunca al revés.

## Cómo ejecutarlo

```bash
flutter pub get
flutter run
```

## Flujo de trabajo

Una tarea del tablero equivale a una rama y a un Pull Request.
Las ramas de trabajo salen de `develop` y regresan ahí mediante PR.
`main` solo recibe versiones estables.