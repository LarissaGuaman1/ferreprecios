class PrecioReportado {
  final String id;
  final double valor;
  final int confirmaciones;
  final String estado;
  final String? marca;
  final String? caracteristicas;
  final String? fotoUrl;
  final String ferreteriaNombre;
  final String ferreteriaSector;
  final String ferreteriaDireccion;

  PrecioReportado({
    required this.id,
    required this.valor,
    required this.confirmaciones,
    required this.estado,
    this.marca,
    this.caracteristicas,
    this.fotoUrl,
    required this.ferreteriaNombre,
    required this.ferreteriaSector,
    required this.ferreteriaDireccion,
  });

  factory PrecioReportado.fromJson(Map<String, dynamic> json) {
    final ferreteria = json['ferreteria'] as Map<String, dynamic>;

    return PrecioReportado(
      id: json['id'] as String,
      valor: (json['valor'] as num).toDouble(),
      confirmaciones: json['confirmaciones'] as int,
      estado: json['estado'] as String,
      marca: json['marca'] as String?,
      caracteristicas: json['caracteristicas'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      ferreteriaNombre: ferreteria['nombre'] as String,
      ferreteriaSector: ferreteria['sector'] as String,
      ferreteriaDireccion: ferreteria['direccion'] as String,
    );
  }
}
