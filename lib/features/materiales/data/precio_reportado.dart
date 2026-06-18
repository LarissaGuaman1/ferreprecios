// Representa UNA fila en la pantalla de comparación completa
// (GET /api/materiales/:id/precios): un precio reportado en una
// ferretería específica.
class PrecioReportado {
  final String id;
  final double valor;
  final int confirmaciones;
  final String estado;
  final String ferreteriaNombre;
  final String ferreteriaSector;
  final String ferreteriaDireccion;

  PrecioReportado({
    required this.id,
    required this.valor,
    required this.confirmaciones,
    required this.estado,
    required this.ferreteriaNombre,
    required this.ferreteriaSector,
    required this.ferreteriaDireccion,
  });

  factory PrecioReportado.fromJson(Map<String, dynamic> json) {
    // Aquí "ferreteria" SÍ es obligatorio (nunca null): el backend
    // siempre hace populate() de la ferretería antes de responder.
    final ferreteria = json['ferreteria'] as Map<String, dynamic>;

    return PrecioReportado(
      id: json['id'] as String,
      valor: (json['valor'] as num).toDouble(),
      confirmaciones: json['confirmaciones'] as int,
      estado: json['estado'] as String,
      ferreteriaNombre: ferreteria['nombre'] as String,
      ferreteriaSector: ferreteria['sector'] as String,
      ferreteriaDireccion: ferreteria['direccion'] as String,
    );
  }
}
