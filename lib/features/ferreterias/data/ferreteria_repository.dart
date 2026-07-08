import '../../../core/services/api_service.dart';
import 'ferreteria_modelo.dart';

class FerreteriaRepository {
  final ApiService _api = ApiService.instance;

  Future<List<FerreteriaModelo>> listarFerreterias() async {
    final respuesta = await _api.get('/ferreterias');
    final lista = respuesta as List;
    return lista
        .map((e) => FerreteriaModelo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Devuelve null si el dueño todavía no registró su ferretería.
  Future<FerreteriaModelo?> obtenerMiFerreteria() async {
    try {
      final respuesta = await _api.get('/ferreterias/mia');
      return FerreteriaModelo.fromJson(respuesta as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.message.contains('Todavía no has')) return null;
      rethrow;
    }
  }

  // Crea o actualiza (upsert) la ferretería del dueño autenticado.
  Future<FerreteriaModelo> guardarMiFerreteria({
    required String nombre,
    required String direccion,
    required String sector,
    String? telefono,
    String? horario,
    String? descripcion,
  }) async {
    final body = <String, dynamic>{
      'nombre': nombre,
      'direccion': direccion,
      'sector': sector,
    };
    if (telefono != null && telefono.isNotEmpty) body['telefono'] = telefono;
    if (horario != null && horario.isNotEmpty) body['horario'] = horario;
    if (descripcion != null && descripcion.isNotEmpty) body['descripcion'] = descripcion;

    final respuesta = await _api.put('/ferreterias/mia', body);
    return FerreteriaModelo.fromJson(respuesta as Map<String, dynamic>);
  }

  // Envía el contenido del CSV al backend para importación masiva.
  // Devuelve { importados: N, errores: [...] }
  Future<Map<String, dynamic>> importarCatalogo(String csvContenido) async {
    final respuesta = await _api.post('/ferreterias/mia/catalogo', {'csv': csvContenido});
    return respuesta as Map<String, dynamic>;
  }

  // Sube la imagen a Cloudinary, luego actualiza la foto en la ferretería.
  Future<String> actualizarFoto(List<int> bytes, String nombreArchivo) async {
    final subida = await _api.postArchivo(
      '/uploads/foto',
      bytes: bytes,
      campoArchivo: 'foto',
      nombreArchivo: nombreArchivo,
    );
    final fotoUrl = subida['url'] as String;
    await _api.put('/ferreterias/mia/foto', {'fotoUrl': fotoUrl});
    return fotoUrl;
  }
}
