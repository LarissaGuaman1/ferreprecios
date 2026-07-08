class FerreteriaModelo {
  final String id;
  final String nombre;
  final String direccion;
  final String sector;
  final String? telefono;
  final String? horario;
  final String? descripcion;
  final String? fotoUrl;
  final bool tieneDueno;
  final double? lat;
  final double? lng;

  const FerreteriaModelo({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.sector,
    this.telefono,
    this.horario,
    this.descripcion,
    this.fotoUrl,
    this.tieneDueno = false,
    this.lat,
    this.lng,
  });

  bool get tieneUbicacion => lat != null && lng != null;

  factory FerreteriaModelo.fromJson(Map<String, dynamic> json) {
    final ub = json['ubicacion'] as Map<String, dynamic>?;
    return FerreteriaModelo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      sector: json['sector'] as String,
      telefono: json['telefono'] as String?,
      horario: json['horario'] as String?,
      descripcion: json['descripcion'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
      tieneDueno: json['tieneDueno'] as bool? ?? false,
      lat: (ub?['lat'] as num?)?.toDouble(),
      lng: (ub?['lng'] as num?)?.toDouble(),
    );
  }

  FerreteriaModelo copyWith({
    String? nombre,
    String? direccion,
    String? sector,
    String? telefono,
    String? horario,
    String? descripcion,
    String? fotoUrl,
  }) {
    return FerreteriaModelo(
      id: id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      sector: sector ?? this.sector,
      telefono: telefono ?? this.telefono,
      horario: horario ?? this.horario,
      descripcion: descripcion ?? this.descripcion,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tieneDueno: tieneDueno,
      lat: lat,
      lng: lng,
    );
  }
}
