/// Rol con el que se registra una persona en ReParte.
enum RolUsuario { donante, asociacion }

class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final RolUsuario rol;

  /// Telefono de contacto; mientras no hay chat, es como se coordinan.
  final String telefono;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.telefono = '',
  });

  bool get esDonante => rol == RolUsuario.donante;

  factory Usuario.fromMap(String id, Map<String, dynamic> map) => Usuario(
        id: id,
        nombre: map['nombre'] as String,
        correo: map['correo'] as String,
        rol: RolUsuario.values.firstWhere(
          (r) => r.name == map['rol'],
          orElse: () => RolUsuario.donante,
        ),
        telefono: map['telefono'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'correo': correo,
        'rol': rol.name,
        'telefono': telefono,
      };
}
