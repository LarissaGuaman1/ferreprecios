import '../../../core/services/api_service.dart';
import 'perfil_resultado.dart';

class PerfilRepository {
  final ApiService _api = ApiService.instance;

  Future<PerfilResultado> obtenerPerfil() async {
    final respuesta = await _api.get('/usuarios/me');
    return PerfilResultado.fromJson(respuesta as Map<String, dynamic>);
  }

  // Primero sube la foto a Cloudinary (mismo endpoint que usan los
  // reportes de precio), y con la URL que devuelve actualiza el
  // perfil del usuario.
  Future<String> actualizarFoto(List<int> bytes, String nombreArchivo) async {
    final subida = await _api.postArchivo(
      '/uploads/foto',
      bytes: bytes,
      campoArchivo: 'foto',
      nombreArchivo: nombreArchivo,
    );
    final fotoUrl = subida['url'] as String;

    await _api.put('/usuarios/me/foto', {'fotoUrl': fotoUrl});
    return fotoUrl;
  }

  Future<String> actualizarNombre(String nombre) async {
    final respuesta = await _api.put('/usuarios/me/nombre', {'nombre': nombre});
    return (respuesta as Map<String, dynamic>)['nombre'] as String;
  }
}
