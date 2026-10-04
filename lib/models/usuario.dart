/// Rol con el que se registra una persona en ReParte.
enum RolUsuario { donante, asociacion }

class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final RolUsuario rol;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory Usuario.fromMap(String id, Map<String, dynamic> map) => Usuario(
        id: id,
        nombre: map['nombre'] as String,
        correo: map['correo'] as String,
        rol: RolUsuario.values.firstWhere(
          (r) => r.name == map['rol'],
          orElse: () => RolUsuario.donante,
        ),
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'correo': correo,
        'rol': rol.name,
      };
}
