// Representa UN ítem de la lista de resultados del buscador.
// Viene del endpoint GET /api/materiales, que ya incluye el precio
// más bajo encontrado (mejorPrecio puede ser null si nadie lo reportó).
class MaterialResultado {
  final String id;
  final String nombre;
  final String categoria;
  final String unidadMedida;
  final double? mejorPrecio;
  final String? mejorFerreteria;
  final String? estado;

  MaterialResultado({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.unidadMedida,
    this.mejorPrecio,
    this.mejorFerreteria,
    this.estado,
  });

  // "factory" = un constructor especial que puede decidir CÓMO construir
  // el objeto (aquí, leyendo y transformando un Map JSON) en vez de
  // simplemente asignar los campos que le pasan directo.
  factory MaterialResultado.fromJson(Map<String, dynamic> json) {
    // El backend manda "mejorPrecio" como un objeto anidado, o null si
    // nadie ha reportado un precio todavía para este material.
    final mejorPrecioJson = json['mejorPrecio'] as Map<String, dynamic>?;

    return MaterialResultado(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      unidadMedida: json['unidadMedida'] as String,
      // "as num" porque JSON no distingue int/double; toDouble()
      // normaliza para que siempre sea double en Dart.
      mejorPrecio: mejorPrecioJson != null ? (mejorPrecioJson['valor'] as num).toDouble() : null,
      mejorFerreteria: mejorPrecioJson?['ferreteria'] as String?,
      estado: mejorPrecioJson?['estado'] as String?,
    );
  }
}
