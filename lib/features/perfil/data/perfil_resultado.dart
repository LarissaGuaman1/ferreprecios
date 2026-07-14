// Datos del usuario logueado, para la pantalla de Perfil.
// Viene del endpoint GET /api/usuarios/me.
class PerfilResultado {
  final String nombre;
  final String email;
  final int puntos;
  final String? fotoUrl;
  final DateTime miembroDesde;
  final int totalReportes;

  PerfilResultado({
    required this.nombre,
    required this.email,
    required this.puntos,
    required this.fotoUrl,
    required this.miembroDesde,
    required this.totalReportes,
  });

  factory PerfilResultado.fromJson(Map<String, dynamic> json) {
    return PerfilResultado(
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      puntos: json['puntos'] as int,
      fotoUrl: json['fotoUrl'] as String?,
      miembroDesde: DateTime.parse(json['miembroDesde'] as String),
      totalReportes: json['totalReportes'] as int,
    );
  }

  // Para actualizar solo la foto sin tener que rehacer todo el objeto
  // desde el backend (la usamos justo después de subir una foto nueva).
  PerfilResultado copyWith({String? fotoUrl, String? nombre}) {
    return PerfilResultado(
      nombre: nombre ?? this.nombre,
      email: email,
      puntos: puntos,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      miembroDesde: miembroDesde,
      totalReportes: totalReportes,
    );
  }
}
