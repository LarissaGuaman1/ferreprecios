import '../../../core/services/api_service.dart';

// Sabe exactamente qué endpoints de autenticación existen en el backend
// y qué datos hay que mandarles. No conoce pantallas ni maneja estado:
// solo pide datos y los entrega a quien lo llame (AuthProvider).
class AuthRepository {
  // Usamos el singleton de ApiService en vez de crear uno nuevo,
  // para compartir el mismo token JWT con el resto de la app.
  final ApiService _api = ApiService.instance;

  // Llama a POST /auth/login. El backend, si las credenciales son
  // correctas, responde con algo como { "token": "...", "usuario": {...} }.
  // Devolvemos ese Map tal cual: el AuthProvider decide qué hacer con él.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final respuesta = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    // ApiService.post devuelve "dynamic" porque no sabe de antemano
    // qué endpoint la llamó. Aquí SÍ sabemos que /auth/login siempre
    // responde un objeto JSON (Map), así que lo confirmamos con "as".
    return respuesta as Map<String, dynamic>;
  }

  // Llama a POST /auth/register. Mismo patrón que login.
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String password,
  }) async {
    final respuesta = await _api.post('/auth/register', {
      'nombre': nombre,
      'email': email,
      'password': password,
    });
    return respuesta as Map<String, dynamic>;
  }
}
