import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import 'inicio_asociacion_view.dart';
import 'inicio_donante_view.dart';

/// Patron Factory: decide en un solo lugar que pantalla principal
/// corresponde a cada rol. Un rol nuevo solo se agrega aqui.
class PantallaInicioFactory {
  static Widget crear(Usuario usuario) {
    switch (usuario.rol) {
      case RolUsuario.donante:
        return InicioDonanteView(usuario: usuario);
      case RolUsuario.asociacion:
        return InicioAsociacionView(usuario: usuario);
    }
  }
}
