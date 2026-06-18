// Representa una ferretería, para elegirla en el paso 3 del wizard
// de reporte. Viene de GET /api/ferreterias.
class Ferreteria {
  final String id;
  final String nombre;
  final String direccion;
  final String sector;

  Ferreteria({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.sector,
  });

  factory Ferreteria.fromJson(Map<String, dynamic> json) {
    return Ferreteria(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      sector: json['sector'] as String,
    );
  }
}
