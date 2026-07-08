import '../../../core/services/api_service.dart';
import '../../materiales/data/material_resultado.dart';
import 'ferreteria.dart';

class ReporteRepository {
  final ApiService _api = ApiService.instance;

  // Reusamos MaterialResultado (de la feature de materiales) para no
  // duplicar el mismo modelo: el paso 1 del wizard es, en el fondo,
  // el mismo buscador que ya construimos.
  Future<List<MaterialResultado>> buscarMateriales(String texto) async {
    final respuesta = await _api.get('/materiales?busqueda=$texto');
    return (respuesta as List)
        .map((item) => MaterialResultado.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Para cuando el material que el usuario quiere reportar no
  // aparece en la búsqueda.
  Future<MaterialResultado> crearMaterial({
    required String nombre,
    required String categoria,
    required String unidadMedida,
  }) async {
    final respuesta = await _api.post('/materiales', {
      'nombre': nombre,
      'categoria': categoria,
      'unidadMedida': unidadMedida,
    });
    return MaterialResultado.fromJson(respuesta as Map<String, dynamic>);
  }

  Future<List<Ferreteria>> listarFerreterias() async {
    final respuesta = await _api.get('/ferreterias');
    return (respuesta as List)
        .map((item) => Ferreteria.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Para cuando el usuario encontró un precio más barato en una
  // ferretería que todavía no está en la lista.
  Future<Ferreteria> crearFerreteria({
    required String nombre,
    required String direccion,
    required String sector,
  }) async {
    final respuesta = await _api.post('/ferreterias', {
      'nombre': nombre,
      'direccion': direccion,
      'sector': sector,
    });
    return Ferreteria.fromJson(respuesta as Map<String, dynamic>);
  }

  // Sube la foto y devuelve la URL pública de Cloudinary, la misma
  // que probamos con curl en el paso anterior.
  Future<String> subirFoto(List<int> bytes, String nombreArchivo) async {
    final respuesta = await _api.postArchivo(
      '/uploads/foto',
      bytes: bytes,
      campoArchivo: 'foto', // debe coincidir con upload.single('foto') del backend
      nombreArchivo: nombreArchivo,
    );
    return respuesta['url'] as String;
  }

  Future<String> crearReporte({
    required String materialId,
    required String ferreteriaId,
    required double precio,
    required String fotoUrl,
    required String marca,
    String? caracteristicas,
  }) async {
    final body = {
      'materialId': materialId,
      'ferreteriaId': ferreteriaId,
      'precio': precio,
      'fotoUrl': fotoUrl,
      'marca': marca,
      if (caracteristicas != null) 'caracteristicas': caracteristicas,
    };
    final respuesta = await _api.post('/reportes', body);
    return respuesta['mensaje'] as String;
  }
}
